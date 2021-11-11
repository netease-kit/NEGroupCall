import Rtc, {
  InitOptions,
  DeviceRes,
  DeviceItemRes,
  Devices,
  DataInfo,
  NetworkQuality,
  AudioQuality,
  Stat,
  VideoQuality,
  VideoFrame,
} from './base';
import logger from '@/utils/logger';

interface IElecStats {
  uid: number;
  tx_quality: NetworkQuality;
  rx_quality: NetworkQuality;
}

interface IElecConnectionState {
  state: 1 | 2 | 3 | 4 | 5;
  reason: 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11;
}

interface IRtcStats {
  up_rtt: number;
  tx_audio_kbitrate: number;
  rx_audio_kbitrate: number;
  tx_video_kbitrate: number;
  rx_video_kbitrate: number;
  [key: string]: any;
}

interface RtcStream {
  video: boolean;
  audio: boolean;
  getId: () => number;
  play?: (view: HTMLElement) => Promise<void>;
  setRemoteRenderMode?: (opt: any) => void;
  [key: string]: any;
}

interface IDevice {
  device_id: string;
  device_name: string;
  system_default_device: boolean;
}

const videoQualityMap = {
  [VideoQuality.VIDEO_QUALITY_1080p]: 4,
  [VideoQuality.VIDEO_QUALITY_720p]: 3,
  [VideoQuality.VIDEO_QUALITY_480p]: 2,
  [VideoQuality.VIDEO_QUALITY_180p]: 1,
};

const videoFrameMap = {
  [VideoFrame.CHAT_VIDEO_FRAME_RATE_5]: 7,
  [VideoFrame.CHAT_VIDEO_FRAME_RATE_10]: 10,
  [VideoFrame.CHAT_VIDEO_FRAME_RATE_15]: 15,
  [VideoFrame.CHAT_VIDEO_FRAME_RATE_20]: 24,
  [VideoFrame.CHAT_VIDEO_FRAME_RATE_25]: 30,
};

const audioQualityMap: { [key in AudioQuality]: number } = {
  speech_low_quality: 1,
  speech_standard: 2,
  music_standard: 3,
  standard_stereo: 4,
  high_quality: 5,
  high_quality_stereo: 6,
};

// @ts-ignore
const NERtcSDK = window.NERtcSDK;

class ElectronRtcImpl extends Rtc {
  public remoteStreams: RtcStream[] = [];
  private client: any = null;
  private rtt: string | number = '';
  private audioSendBitrate: number = 0;
  private videoSendBitrate: number = 0;
  private audioRecvBitrate: number = 0;
  private videoRecvBitrate: number = 0;
  private localView: HTMLElement | null = null;

  constructor(options: InitOptions) {
    super(options);
    this.client = new NERtcSDK.NERtcEngine();
    const res = this.client.initialize({
      app_key: options.appkey, // 设置appkey
      log_file_max_size_KBytes: 0, // 设置日志文件的大小上限，单位为 KB。如果设置为 0，则默认为 20 M
      // @ts-ignore
      log_dir_path: window.electronLogPath, // 设置日志目录
    });
    if (res !== 0) {
      logger.error('initialize fail');
      return;
    }
    logger.log('SDKVersion：', this.client.getVersion());
    this.addRtcListener();
  }

  public addRtcListener() {
    logger.log('addRtcListener');
    // 本端加入房间
    this.client.on('onJoinChannel', this._onJoinChannel.bind(this));
    // 本端离开房间，释放资源
    this.client.on('onLeaveChannel', this._onLeaveChannel.bind(this));
    // 远端用户加入房间
    this.client.on('onUserJoined', this._onUserJoined.bind(this));
    // 远端用户离开房间
    this.client.on('onUserLeft', this._onUserLeft.bind(this));
    // 远端用户开启音频的事件
    this.client.on('onUserAudioStart', this._onUserAudioStart.bind(this));
    // 远端用户停用音频回调
    this.client.on('onUserAudioStop', this._onUserAudioStop.bind(this));
    // 远端用户开启视频回调
    this.client.on('onUserVideoStart', this._onUserVideoStart.bind(this));
    // 远端用户停用视频回调
    this.client.on('onUserVideoStop', this._onUserVideoStop.bind(this));
    // 监听上下行网络质量
    this.client.on('onNetworkQuality', this._onNetworkQuality.bind(this));
    // 服务器连接断开
    this.client.on('onDisconnect', this._onDisconnect.bind(this));
    // 网络状态改变
    this.client.on(
      'onConnectionStateChange',
      this._onConnectionStateChange.bind(this),
    );
    // 通话统计回调
    this.client.on('onRtcStats', this._onRtcStats.bind(this));
  }

  public removeRtcListener() {
    this.client.off('onJoinChannel', this._onJoinChannel.bind(this));
    this.client.off('onLeaveChannel', this._onLeaveChannel.bind(this));
    this.client.off('onUserJoined', this._onUserJoined.bind(this));
    this.client.off('onUserLeft', this._onUserLeft.bind(this));
    this.client.off('onUserAudioStart', this._onUserAudioStart.bind(this));
    this.client.off('onUserAudioStop', this._onUserAudioStop.bind(this));
    this.client.off('onUserVideoStart', this._onUserVideoStart.bind(this));
    this.client.off('onUserVideoStop', this._onUserVideoStop.bind(this));
    this.client.off('onNetworkQuality', this._onNetworkQuality.bind(this));
    this.client.off('onDisconnect', this._onDisconnect.bind(this));
    this.client.off(
      'onConnectionStateChange',
      this._onConnectionStateChange.bind(this),
    );
    this.client.off('onRtcStats', this._onRtcStats.bind(this));
    // this.client.removeAllListeners();
  }

  public async join() {
    logger.log('join');
    try {
      const {
        avRoomUid,
        avRoomCid,
        avRoomCheckSum,
        avRoomCName,
      } = await this.sendJoinChannelRequest();
      this.uid = avRoomUid;
      this.channelId = avRoomCid;

      const token = avRoomCheckSum; // 如果是非安全模式，置为null
      // 获取并设置设备
      const {
        audioIn = [],
        audioOut = [],
        video = [],
      } = await this.getDevices();
      if (!audioIn.length) {
        throw { msg: '获取到的麦克风列表为空' };
      }
      if (!audioOut.length) {
        throw { msg: '获取到的扬声器列表为空' };
      }
      if (!video.length) {
        throw { msg: '获取到的摄像头列表为空' };
      }
      // 初始化设备id
      this.microphoneId =
        audioIn.find((item) => item.isDefault)?.deviceId ||
        this.client.getRecordDevice();
      this.speakerId =
        audioOut.find((item) => item.isDefault)?.deviceId ||
        this.client.getPlayoutDevice();
      this.cameraId =
        video.find((item) => item.isDefault)?.deviceId ||
        this.client.getVideoDevice();
      // 打开或关闭设备
      this.enableLocalVideo(this.options.openCamera);
      this.enableLocalAudio(this.options.openMic);
      // 赋值本地流
      this.localStream = true;
      // 设置播放容器
      this.onLocalStreamUpdate();
      // 设置视频参数
      const res = this.client.setVideoConfig({
        max_profile: videoQualityMap[this.options.resolution as number],
        width: 0,
        height: 0,
        crop_mode: 0,
        framerate: videoFrameMap[this.options.frameRate as number],
        min_framerate: 0,
        bitrate: 0,
        min_bitrate: 0,
        degradation_preference: 3,
      });
      if (res === 0) {
        logger.log('setVideoConfig success');
      } else {
        logger.error('setVideoConfig fail');
        throw 'setVideoConfig fail';
      }
      // 设置音频参数
      if (this.options.audioQuality) {
        const res = this.client.setAudioProfile(
          audioQualityMap[this.options.audioQuality] || 0,
          0,
        );
        if (res === 0) {
          logger.log('setAudioProfile success');
        } else {
          logger.error('setAudioProfile fail');
          throw 'setAudioProfile fail';
        }
      }
      const joinRes = this.client.joinChannel(token, avRoomCName, this.uid);
      if (joinRes === 0) {
        logger.log('joinChannel success');
      } else {
        logger.error('joinChannel fail');
        throw 'joinChannel fail';
      }
    } catch (error) {
      logger.error('join fail: ', error);
      return Promise.reject(error);
    }
  }

  public async setupLocalView(view: HTMLElement) {
    const res = this.client.setupLocalVideoCanvas({
      view,
      mode: 0,
    });
    if (res === 0) {
      this.localView = view;
      logger.log('setupLocalVideoCanvas success');
    } else {
      logger.error('setupLocalVideoCanvas fail');
    }
  }

  public async setupRemoteView(userId: number, view: HTMLElement) {
    const res = this.client.setupRemoteVideoCanvas(userId, {
      mode: 0,
      view,
    });
    if (res === 0) {
      logger.log('setupRemoteVideoCanvas success', userId);
    } else {
      logger.error('setupRemoteVideoCanvas fail');
    }
  }

  public setLocalVideoSize(view: HTMLElement) {
    logger.log('setLocalVideoSize: ', 'no implement');
  }

  public setRemoteVideoSize(userId: number, view: HTMLElement) {
    logger.log('setRemoteVideoSize: ', 'no implement');
  }

  public async enableLocalVideo(enabled: boolean, deviceId?: string) {
    if (deviceId) {
      this.setVideoDevice(deviceId);
    }
    if (this.localView) {
      // SDK需要手动设置canvas来更新页面上的canvas
      const res = this.client.setupLocalVideoCanvas({
        view: enabled ? this.localView : null,
        mode: 0,
      });
      if (res === 0) {
        logger.log('setupLocalVideoCanvas in enableLocalVideo success');
      } else {
        logger.error('setupLocalVideoCanvas in enableLocalVideo fail');
      }
    }
    const res = this.client.enableLocalVideo(enabled);
    if (res === 0) {
      logger.log('enableLocalVideo success');
    } else {
      logger.error('enableLocalVideo fail');
    }
  }

  public async enableLocalAudio(enabled: boolean, deviceId?: string) {
    if (deviceId) {
      this.setAudioInDevice(deviceId);
    }
    const res = this.client.enableLocalAudio(enabled);
    if (res === 0) {
      logger.log('enableLocalAudio success');
    } else {
      logger.error('enableLocalAudio fail');
    }
  }

  public async getDevices(): Promise<DeviceRes> {
    const audioOut: IDevice[] = this.client.enumeratePlayoutDevices();
    const audioIn: IDevice[] = this.client.enumerateRecordDevices();
    const video: IDevice[] = this.client.enumerateVideoCaptureDevices();

    const transformHandler = (arr: IDevice[]): DeviceItemRes[] => {
      return arr.map((item) => ({
        label: item.device_name,
        deviceId: item.device_id,
        isDefault: item.system_default_device,
      }));
    };

    return {
      audioOut: transformHandler(audioOut),
      audioIn: transformHandler(audioIn),
      video: transformHandler(video),
    };
  }

  public async changeDevice(type: keyof Devices, deviceId: string) {
    switch (type) {
      case 'microphoneId':
        if (this.microphoneId === deviceId) {
          return Promise.reject('无效切换');
        }
        this.setAudioInDevice(deviceId);
        this.onLocalStreamUpdate();
        break;
      case 'cameraId':
        if (this.cameraId === deviceId) {
          return Promise.reject('无效切换');
        }
        this.setVideoDevice(deviceId);
        this.onLocalStreamUpdate();
        break;
      case 'speakerId':
        if (this.speakerId === deviceId) {
          return Promise.reject('无效切换');
        }
        this.setAudioOutDevice(deviceId);
        this.onLocalStreamUpdate();
        break;
    }
  }

  public async getInfo(): Promise<DataInfo> {
    return {
      rtt: this.rtt + '',
      audioSendBitrate: this.audioSendBitrate,
      audioRecvBitrate: this.audioRecvBitrate,
      videoSendBitrate: this.videoSendBitrate,
      videoRecvBitrate: this.videoRecvBitrate,
    };
  }

  public async leave() {
    const res = this.client.leaveChannel();
    if (res === 0) {
      logger.log('leaveChannel success');
    } else {
      logger.error('leaveChannel fail');
    }
    this.destroy();
  }

  private _onJoinChannel() {
    logger.log('_onJoinChannel', this);
  }

  private _onLeaveChannel() {
    logger.log('_onLeaveChannel');
  }

  private async _onUserJoined(uid: number, userName: string) {
    logger.log('_onUserJoined: ', uid, userName);
    try {
      if (
        this.remoteUsers.every((item) => item.uid !== uid) &&
        this.remoteUsers.length < this.max - 1
      ) {
        this.remoteUsers = this.remoteUsers.concat({
          nickName: '昵称丢失了',
          uid,
        });
        this.onRemoteStreamUpdate();
        const { members } = await this.getUserInfoRequest(uid);
        this.remoteUsers = this.remoteUsers.map((item) =>
          item.uid === uid
            ? { ...item, nickName: members[0].nickName }
            : { ...item },
        );
      }
    } catch (error) {
      logger.log('error in onUserJoined:', error);
    } finally {
      // 这里因为上面有个异步接口，导致remoteUsers和remoteStreams不同步
      // 因此在这边再调一次，保证页面可以渲染
      this.onRemoteStreamUpdate();
    }
  }

  private _onUserLeft(uid: number, reason: number) {
    logger.log('_onUserLeft: ', uid, reason);
    this.remoteUsers = this.remoteUsers.filter(
      (item) => item.uid && item.uid !== uid,
    );
    this.remoteStreams = this.remoteStreams.filter(
      (item) => item.getId() && item.getId() !== uid,
    );
    this.onRemoteStreamUpdate();
  }

  private _onUserAudioStart(uid: number) {
    logger.log('_onUserAudioStart', uid);
    if (this.remoteStreams.some((item) => item.getId() === uid)) {
      this.remoteStreams = this.remoteStreams.map((item) =>
        item.getId() === uid
          ? {
              ...item,
              audio: true,
            }
          : item,
      );
    } else {
      this.remoteStreams.push({
        video: false,
        audio: true,
        getId: () => uid,
      });
    }
    this.onRemoteStreamUpdate();
  }

  private _onUserAudioStop(uid: number) {
    logger.log('_onUserAudioStop: ', uid);
    if (this.remoteStreams.some((item) => item.getId() === uid)) {
      this.remoteStreams = this.remoteStreams.map((item) =>
        item.getId() === uid
          ? {
              ...item,
              audio: false,
            }
          : item,
      );
    }
    this.onRemoteStreamUpdate();
  }

  private _onUserVideoStart(uid: number) {
    logger.log('_onUserVideoStart', uid);
    if (this.remoteStreams.some((item) => item.getId() === uid)) {
      this.remoteStreams = this.remoteStreams.map((item) =>
        item.getId() === uid
          ? {
              ...item,
              video: true,
            }
          : item,
      );
    } else {
      this.remoteStreams.push({
        video: true,
        audio: false,
        getId: () => uid,
      });
    }
    this.onRemoteStreamUpdate();
    this.onRemoteStreamSubscribed(uid);
    const res = this.client.subscribeRemoteVideoStream(uid, 0, true);
    if (res === 0) {
      logger.log('subscribeRemoteVideoStream success', uid);
    } else {
      logger.error('subscribeRemoteVideoStream fail', uid);
    }
  }

  private _onUserVideoStop(uid: number) {
    logger.log('_onUserVideoStop', uid);
    if (this.remoteStreams.some((item) => item.getId() === uid)) {
      this.remoteStreams = this.remoteStreams.map((item) =>
        item.getId() === uid
          ? {
              ...item,
              video: false,
            }
          : item,
      );
    }
    this.onRemoteStreamUpdate();
    this.setupRemoteView(uid, null as any);
    const res = this.client.subscribeRemoteVideoStream(uid, 0, false);
    if (res === 0) {
      logger.log('subscribeRemoteVideoStream success');
    } else {
      logger.error('subscribeRemoteVideoStream fail');
    }
  }

  private _onNetworkQuality(uc: number, stats: IElecStats[]) {
    // logger.log('_onNetworkQuality', uc, stats);
    this.onNetworkQuality(
      stats.map((item) => ({
        uid: item.uid,
        uplinkNetworkQuality: item.tx_quality,
        downlinkNetworkQuality: item.rx_quality,
      })),
    );
  }

  private _onDisconnect() {
    logger.log('_onDisconnect');
    this.onDisconnect();
  }

  private _onConnectionStateChange(evt: IElecConnectionState) {
    // logger.log('onConnectionStateChange', evt);
    if (evt.state === 5) {
      this.onConnectionDisconnected();
    }
  }

  private _onRtcStats(stats: IRtcStats) {
    this.rtt = stats.up_rtt;
    this.audioSendBitrate = stats.tx_audio_kbitrate;
    this.audioRecvBitrate = stats.rx_audio_kbitrate;
    this.videoSendBitrate = stats.tx_video_kbitrate;
    this.videoRecvBitrate = stats.rx_video_kbitrate;
  }

  public destroy() {
    this.rtt = '';
    this.audioSendBitrate = 0;
    this.videoSendBitrate = 0;
    this.audioRecvBitrate = 0;
    this.videoRecvBitrate = 0;

    this.removeRtcListener();
    this.client.release();
    this.client = null;
    this.remoteUsers = [];
    this.localStream = null;
    this.remoteStreams = [];
    this.microphoneId = '';
    this.cameraId = '';
    this.speakerId = '';

    this.localView = null;
    this.uid = undefined;
    this.nickName = '';
    this.appkey = '';
    this.options = {
      resolution: undefined,
      frameRate: undefined,
      audioQuality: undefined,
      openCamera: false,
      openMic: false,
    };
    this.channelName = '';
    this.channelId = '';
    this.max = 4;
    this.onLocalStreamUpdate = () => {};
    this.onRemoteStreamUpdate = () => {};
    this.onRemoteStreamSubscribed = (uid: number) => {};
    this.onNetworkQuality = (stats: Stat[]) => {};
    this.onDisconnect = () => {};
    this.onConnectionDisconnected = () => {};
  }

  private setVideoDevice(deviceId: string) {
    const res = this.client.setVideoDevice(deviceId);
    if (res === 0) {
      this.cameraId = deviceId;
      logger.log('setVideoDevice success: ', deviceId);
      return;
    }
    logger.error('setVideoDevice fail: ', deviceId);
  }

  private setAudioInDevice(deviceId: string) {
    const res = this.client.setRecordDevice(deviceId);
    if (res === 0) {
      this.microphoneId = deviceId;
      logger.log('setAudioInDevice success: ', deviceId);
      return;
    }
    logger.error('setAudioInDevice fail: ', deviceId);
  }

  private setAudioOutDevice(deviceId: string) {
    const res = this.client.setPlayoutDevice(deviceId);
    if (res === 0) {
      this.speakerId = deviceId;
      logger.log('setAudioOutDevice success: ', deviceId);
      return;
    }
    logger.error('setAudioOutDevice fail: ', deviceId);
  }
}

export default ElectronRtcImpl;
