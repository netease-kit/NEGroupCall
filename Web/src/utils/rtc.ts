import * as WebRTC2 from '@/assets/NIM_Web_WebRTC2_v4.1.0.js';
import axios from 'axios';
import config from '@/config';
import logger from '@/utils/logger';
import { Quality } from '@/components/RtcOptModal';
import { checkBrowser } from '@/utils';
// import { getToken } from '@/utils'

type ChannelInfo = {
  avRoomUid: number;
  avRoomCid: string;
  avRoomCheckSum: string;
  avRoomCName: string;
};

type RoomMember = {
  nickName: string;
};

type RTCEvent = {
  uid: number;
  stream: any;
};

type Devices = {
  microphoneId?: string;
  cameraId?: string;
  speakerId?: string;
};

export type DataInfo = {
  rtt: string;
  audioSendBitrate: number;
  videoSendBitrate: number;
  audioRecvBitrate: number;
  videoRecvBitrate: number;
};

export type Stat = {
  uid: number;
  uplinkNetworkQuality: 0 | 1 | 2 | 3 | 4 | 5;
  downlinkNetworkQuality: 0 | 1 | 2 | 3 | 4 | 5;
};

export type Evts = {
  prevState: 'DISCONNECTED' | 'CONNECTING' | 'CONNECTED' | 'DISCONNECTING';
  curState: 'DISCONNECTED' | 'CONNECTING' | 'CONNECTED' | 'DISCONNECTING';
};

export type FeedbackParams = {
  feedback_type: number;
  content_type: number[];
  content: string;
};

export type UserInfo = {
  uid: number;
  nickName: string;
};

class RTC {
  public client: any = null;
  public remoteUsers: UserInfo[] = [];
  public localStream: any = null;
  public remoteStreams: any[] = [];
  public microphoneId = '';
  public cameraId = '';
  public speakerId = '';

  private uid?: number;
  private nickName: string = '';
  private options: {
    resolution: number;
    frameRate: number;
    audioQuality: Quality;
    openCamera: boolean;
    openMic: boolean;
  } = {
    resolution: WebRTC2.VIDEO_QUALITY_720p,
    frameRate: WebRTC2.CHAT_VIDEO_FRAME_RATE_15,
    audioQuality: 'speech_low_quality',
    openCamera: true,
    openMic: true,
  };
  private appkey: string = '';
  // private appSecret: string = ''
  // private token: string = ''
  private channelName: string = '';
  private channelId: string = '';
  private max: number = 4;
  private onLocalStreamUpdate = () => {};
  private onRemoteStreamUpdate = () => {};
  private onRemoteStreamSubscribed = (userId: number) => {};
  private onDisconnect = () => {};
  private onNetworkQuality = (stats: Stat[]) => {};
  private onConnectionState = (evt: Evts) => {};

  constructor(options: {
    appkey: string;
    // appSecret: string;
    channelName: string;
    nickName: string;
    options?: {
      resolution: number;
      frameRate: number;
      audioQuality: Quality;
      openCamera: boolean;
      openMic: boolean;
    };
    max?: number;
    onLocalStreamUpdate(): void;
    onRemoteStreamUpdate(): void;
    onRemoteStreamSubscribed(userId: number): void;
    onDisconnect(): void;
    onNetworkQuality(stats: Stat[]): void;
    onConnectionState(evt: Evts): void;
  }) {
    for (const key in options) {
      if (options.hasOwnProperty(key)) {
        this[key] = options[key];
      }
    }
    this.client = WebRTC2.createClient({
      appkey: this.appkey,
      debug: true,
    });
    logger.log('createClient');

    // 加入房间
    this.client.on('peer-online', async (event: RTCEvent) => {
      try {
        const userId = event.uid;
        if (
          this.remoteUsers.every((item) => item.uid !== userId) &&
          this.remoteUsers.length < this.max - 1
        ) {
          logger.log(`[nrtc]: ${userId} 加入房间`);
          this.remoteUsers = this.remoteUsers.concat({
            nickName: '昵称丢失了',
            uid: userId,
          });
          this.onRemoteStreamUpdate();
          const { members } = await this.getUserInfoRequest(userId);
          this.remoteUsers = this.remoteUsers.map((item) =>
            item.uid === userId
              ? { ...item, nickName: members[0].nickName }
              : { ...item },
          );
        }
      } catch (error) {
        logger.log('[nrtc]: error in peer-online:', error);
      } finally {
        // 这里因为上面有个异步接口，导致remoteUsers和remoteStreams不同步
        // 因此在这边再调一次，保证页面可以渲染
        this.onRemoteStreamUpdate();
      }
    });

    // 离开房间
    this.client.on('peer-leave', (event: RTCEvent) => {
      const userId = event.uid;
      logger.log(`[nrtc]: ${userId} 离开房间`);
      this.remoteUsers = this.remoteUsers.filter(
        (item) => item.uid && item.uid !== userId,
      );
      this.remoteStreams = this.remoteStreams.filter(
        (item) => item.getId() && item.getId() !== userId,
      );
      this.onRemoteStreamUpdate();
    });

    // 收到远端订阅的通知
    this.client.on('stream-added', async (event: RTCEvent) => {
      const stream = event.stream;
      const userId = stream.getId();
      if (this.remoteStreams.some((item) => item.getId() === userId)) {
        logger.log('[nrtc]: 收到已订阅的远端发布，需要更新', stream);
        this.remoteStreams = this.remoteStreams.map((item) =>
          item.getId() === userId ? stream : item,
        );
        await this.rtcSubscribe(stream);
        this.onRemoteStreamUpdate();
      } else if (this.remoteStreams.length < this.max - 1) {
        logger.log('[nrtc]: 收到新的远端发布消息', stream);
        this.remoteStreams = this.remoteStreams.concat(stream);
        await this.rtcSubscribe(stream);
        this.onRemoteStreamUpdate();
      } else {
        logger.log('[nrtc]: 房间人数已满');
      }
    });

    // 收到远端停止订阅的通知
    this.client.on('stream-removed', (event: RTCEvent) => {
      const stream = event.stream;
      const userId = stream.getId();
      stream.stop();
      this.remoteStreams = this.remoteStreams.map((item) =>
        item.getId() === userId ? stream : item,
      );
      logger.log('[nrtc]: 远端流停止订阅，需要更新', userId, stream);
      this.onRemoteStreamUpdate();
    });

    // 收到远端的流，准备播放
    this.client.on('stream-subscribed', (event: RTCEvent) => {
      const stream = event.stream;
      const userId = stream.getId();
      logger.log(
        '[nrtc]: 收到远端的流，准备播放',
        userId,
        stream,
        this.remoteUsers,
        this.remoteStreams,
      );
      this.onRemoteStreamSubscribed(userId);
    });

    // 监听上下行网络质量
    this.client.on('network-quality', (stats: Stat[]) => {
      this.onNetworkQuality(stats);
    });

    // 收到房间关闭的消息
    this.client.on('channel-closed', () => {
      this.onDisconnect();
    });

    // 监听与服务器的连接状态
    this.client.on('connection-state-change', (evt: Evts) => {
      this.onConnectionState(evt);
      logger.log(evt.prevState, evt.curState);
    });
  }

  public async join() {
    try {
      const {
        avRoomUid,
        avRoomCid,
        avRoomCheckSum,
        avRoomCName,
      } = await this.sendJoinChannelRequest();
      this.uid = avRoomUid;
      this.channelId = avRoomCid;
      // if (this.appSecret) {
      //   this.token = await getToken({uid: this.uid, appkey: this.appkey, appSecret: this.appSecret, channelName: this.channelName})
      // } else {
      //   this.token = ''
      // }
      await this.client.join({
        channelName: avRoomCName,
        uid: this.uid,
        token: avRoomCheckSum, // 如果是非安全模式, token: ''
      });
      if (this.options.openCamera || this.options.openMic) {
        await this.initAndPlayLocalStream({
          audio: this.options.openMic,
          video: this.options.openCamera,
        });
        await this.client.publish(this.localStream);
      }
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public async setupLocalView(view: HTMLElement) {
    if (!this.localStream) {
      return Promise.reject('内部错误：localStream is null');
    }
    try {
      await this.localStream.play(view);
      this.setLocalVideoSize(view);
    } catch (error) {
      return Promise.reject('播放本地视频失败：' + error);
    }
  }

  public async setupRemoteView(userId: number, view: HTMLElement) {
    const remoteStream = this.remoteStreams.find(
      (item) => item.getId() === userId,
    );
    if (!remoteStream) {
      return Promise.reject('内部错误：remoteStream is null');
    }
    try {
      await remoteStream.play(view);
      this.setRemoteVideoSize(userId, view);
    } catch (error) {
      return Promise.reject('播放远端视频失败：' + error);
    }
  }

  public setLocalVideoSize(view: HTMLElement) {
    if (!this.localStream) {
      throw '内部错误：localStream is null';
    }
    this.localStream.setLocalRenderMode({
      // 设置视频窗口大小
      width: view.clientWidth,
      height: view.clientHeight,
      cut: false, // 是否裁剪
    });
  }

  public setRemoteVideoSize(userId: number, view: HTMLElement) {
    const remoteStream = this.remoteStreams.find(
      (item) => item.getId() === userId,
    );
    if (!remoteStream) {
      throw '内部错误：remoteStream is null';
    }
    remoteStream.setRemoteRenderMode({
      // 设置视频窗口大小
      width: view.clientWidth,
      height: view.clientHeight,
      cut: false, // 是否裁剪
    });
  }

  public async enableLocalVideo(enabled: boolean, deviceId?: string) {
    if (!this.localStream) {
      if (!enabled) {
        return Promise.reject('内部错误：localStream is null');
      }
      await this.initAndPlayLocalStream({
        audio: false,
        video: true,
      });
      await this.client.publish(this.localStream);
      return Promise.resolve();
    }
    try {
      await this.localStream[enabled ? 'open' : 'close']({
        type: 'video',
        deviceId,
      });
      if (deviceId) {
        this.cameraId = deviceId;
      }
      // if (!enabled) {
      //   this.cameraId = ''
      // } else {
      //   this.cameraId = (await this.getDevices()).video[0].deviceId
      // }
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public async enableLocalAudio(enabled: boolean, deviceId?: string) {
    if (!this.localStream) {
      if (!enabled) {
        return Promise.reject('内部错误：localStream is null');
      }
      await this.initAndPlayLocalStream({
        audio: true,
        video: false,
      });
      await this.client.publish(this.localStream);
      return Promise.resolve();
    }
    try {
      await this.localStream[enabled ? 'open' : 'close']({
        type: 'audio',
        deviceId,
      });
      if (deviceId) {
        this.microphoneId = deviceId;
      }
      // if (!mute) {
      //   this.microphoneId = ''
      // } else {
      //   this.microphoneId = await (await this.getDevices()).audioIn[0].deviceId
      // }
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public async getDevices() {
    try {
      const deviceMap = await WebRTC2.getDevices();
      const res: { audioIn?: any; audioOut?: any; video?: any } = {};
      for (const key in deviceMap) {
        if (deviceMap.hasOwnProperty(key)) {
          res[key] = deviceMap[key];
        }
      }
      return res;
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public async changeDevice(type: keyof Devices, deviceId: string) {
    try {
      switch (type) {
        case 'microphoneId':
          if (this.microphoneId === deviceId) {
            return Promise.reject('无效切换');
          }
          try {
            await this.enableLocalAudio(false);
          } catch (error) {
            // 忽略
          }
          await this.enableLocalAudio(true, deviceId);
          this.onLocalStreamUpdate();
          break;
        case 'cameraId':
          if (this.cameraId === deviceId) {
            return Promise.reject('无效切换');
          }
          try {
            await this.enableLocalVideo(false);
          } catch (error) {
            // 忽略
          }
          await this.enableLocalVideo(true, deviceId);
          this.onLocalStreamUpdate();
          break;
        case 'speakerId':
          if (this.speakerId === deviceId) {
            return Promise.reject('无效切换');
          }
          // await this.selectSpeakers(deviceId);
          await this.localStream.setAudioOutput(deviceId);
          this.speakerId = deviceId;
          this.onLocalStreamUpdate();
          break;
      }
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public async getInfo(): Promise<DataInfo> {
    try {
      const res = await Promise.allSettled([
        this.client.getTransportStats(),
        this.client.getLocalAudioStats(),
        this.client.getLocalVideoStats(),
        this.client.getRemoteAudioStats(),
        this.client.getRemoteVideoStats(),
      ]);
      logger.log('getInfo success: ', res);
      const audioArr = Object.values(
        res[3].status === 'fulfilled' ? res[3].value : '',
      );
      const videoArr = Object.values(
        res[4].status === 'fulfilled' ? res[4].value : '',
      );
      const audioRecv = audioArr.map((item: any) => {
        return item.RecvBitrate;
      });
      const videoRecv = videoArr.map((item: any) => {
        return item.RecvBitrate;
      });
      let audioSum = 0;
      let videoSum = 0;
      audioRecv.forEach((item) => {
        audioSum += item;
      });
      videoRecv.forEach((item) => {
        videoSum += item;
      });
      const audio = Math.floor(audioSum / audioRecv.length);
      const video = Math.floor(videoSum / videoRecv.length);
      return {
        rtt: res[0].status === 'fulfilled' ? res[0].value.txRtt : '-',
        audioSendBitrate:
          res[1].status === 'fulfilled' && res[1].value[0]
            ? res[1].value[0].SendBitrate
            : 0,
        videoSendBitrate:
          res[2].status === 'fulfilled' && res[2].value[0]
            ? res[2].value[0].SendBitrate
            : 0,
        audioRecvBitrate: audio ? audio : 0,
        videoRecvBitrate: video ? video : 0,
      };
    } catch (err) {
      logger.log('getInfo failed: ', err);
      return Promise.reject(err);
    }
  }

  public async leave() {
    try {
      await this.client.leave();
      logger.log('[nrtc]: leave success');
    } catch (error) {
      logger.log('[nrtc]: leave fail', error);
    } finally {
      this.destroy();
    }
  }

  public sendFeedbackRequest(params: FeedbackParams) {
    return axios.post(
      'https://statistic.live.126.net/statics/report/feedback/demoSuggest',
      {
        data: JSON.stringify({
          ...params,
          feedback_source: '多人视频通话Demo',
          type: 1,
          uid: this.uid,
          cid: this.channelId,
          appkey: this.appkey,
        }),
      },
      {
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      },
    );
  }

  public destroy() {
    try {
      this.localStream.destroy();
      this.client.destroy();
    } catch (error) {
      //
    }
    this.client.removeAllListeners();
    this.client = null;
    this.remoteUsers = [];
    this.localStream = null;
    this.remoteStreams = [];
    this.microphoneId = '';
    this.cameraId = '';
    this.speakerId = '';

    this.uid = undefined;
    this.nickName = '';
    this.appkey = '';
    this.options = {
      resolution: WebRTC2.VIDEO_QUALITY_720p,
      frameRate: WebRTC2.CHAT_VIDEO_FRAME_RATE_15,
      audioQuality: 'speech_low_quality',
      openCamera: true,
      openMic: true,
    };
    // private appSecret: string = ''
    // private token: string = ''
    this.channelName = '';
    this.channelId = '';
    this.max = 4;
    this.onLocalStreamUpdate = () => {};
    this.onRemoteStreamUpdate = () => {};
    this.onRemoteStreamSubscribed = (userId: number) => {};
    this.onNetworkQuality = (stats: Stat[]) => {};
    this.onDisconnect = () => {};
    this.onConnectionState = (evt: Evts) => {};
  }

  private async initAndPlayLocalStream(params: {
    audio: boolean;
    video: boolean;
  }) {
    try {
      // 初始化本地的Stream实例，用于管理本端的音视频流
      this.localStream = WebRTC2.createStream({
        uid: this.uid,
        audio: params.audio,
        video: params.video,
        screen: false,
        client: this.client,
      });
      // 设置本地视频质量
      this.localStream.setVideoProfile({
        resolution: this.options.resolution, // 设置视频分辨率
        frameRate: this.options.frameRate, // 设置视频帧率
      });
      // 设置本地音频质量
      this.localStream.setAudioProfile(this.options.audioQuality);
      // 初始化
      await this.localStream.init();
      // 指定一个默认的设备
      const {
        audioIn = [],
        audioOut = [],
        video = [],
      } = await this.getDevices();
      if (!audioIn.length) {
        throw { msg: '获取到的麦克风列表为空' };
      }
      if (!audioOut.length && !checkBrowser('safari')) {
        throw { msg: '获取到的扬声器列表为空' };
      }
      if (!video.length) {
        throw { msg: '获取到的摄像头列表为空' };
      }
      this.microphoneId = audioIn[0]?.deviceId || '';
      this.cameraId = video[0]?.deviceId || '';
      this.speakerId = audioOut[0]?.deviceId || '';
      // 触发回调
      this.onLocalStreamUpdate();
    } catch (error) {
      return Promise.reject(error);
    }
  }

  private async rtcSubscribe(stream: any) {
    stream.setSubscribeConfig({
      audio: true,
      video: true,
    });
    try {
      await this.client.subscribe(stream);
      logger.log('[nrtc]: 订阅成功');
    } catch (error) {
      logger.log('[nrtc]: 订阅失败：', error);
      return Promise.reject(error);
    }
  }

  private sendJoinChannelRequest() {
    return this.sendRequest<ChannelInfo>('/mpVideoCall/room/anonymousJoin', {
      mpRoomId: this.channelName,
      nickName: this.nickName,
      clientType: 6,
    });
  }

  private getUserInfoRequest(userId: number) {
    return this.sendRequest<{ members: RoomMember[] }>(
      '/mpVideoCall/room/info',
      {
        mpRoomId: this.channelName,
        avRoomUid: userId,
      },
    );
  }

  private async sendRequest<T = any>(url: string, data: any): Promise<T> {
    try {
      const baseUrl = config.baseUrl;
      const res = await axios.post(`${baseUrl}${url}`, data, {
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      });
      if (res.data.code === 200) {
        return res.data.data;
      }
      return Promise.reject(res.data);
    } catch (error) {
      return Promise.reject(error);
    }
  }
}

export default RTC;
