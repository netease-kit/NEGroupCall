import WebRTC2 from '@/sdk/NIM_Web_WebRTC2_v3.7.0'
import axios from 'axios'
// import { getToken } from '@/utils'

type ChannelInfo = {
  avRoomUid: string;
  avRoomCid: string;
  avRoomCheckSum: string;
  avRoomCName: string;
}

type RoomMember = {
  nickName: string;
}

type RTCEvent = {
  uid: string;
  stream: any;
};

type Devices = {
  microphoneId?: string;
  cameraId?: string;
  speakerId?: string;
}

export type FeedbackParams = {
  feedback_type: number;
  content_type: number[];
  content: string;
}

export type UserInfo = {
  uid: string;
  nickName: string;
}

class RTC {
  public client: any = null
  public remoteUsers: UserInfo[] = []
  public localStream: any = null
  public remoteStreams: any[] = []
  public microphoneId = ''
  public cameraId = ''
  public speakerId = ''

  private uid: string = ''
  private nickName: string = ''
  private appkey: string = ''
  // private appSecret: string = ''
  // private token: string = ''
  private channelName: string = ''
  private channelId: string = ''
  private max: number = 4
  private onLocalStreamUpdate = () => {}
  private onRemoteStreamUpdate = (userId: string) => {}
  private onRemoteStreamSubscribed = (userId: string) => {}
  private onDisconnect = () => {}

  constructor(options: {
    appkey: string;
    // appSecret: string;
    channelName: string;
    nickName: string;
    max?: number;
    onLocalStreamUpdate(): void;
    onRemoteStreamUpdate(userId: string): void;
    onRemoteStreamSubscribed(userId: string): void;
    onDisconnect(): void;
  }) {
    for(const key in options) {
      if (options.hasOwnProperty(key)) {
        this[key] = options[key]
      }
    }
    this.client = WebRTC2.createClient({
      appkey: this.appkey,
      debug: true
    })

    // 加入房间
    this.client.on('peer-online', async (event: RTCEvent) => {
      try {
        const userId = event.uid;
        if (this.remoteUsers.every(item => item.uid !== userId) && this.remoteUsers.length < this.max - 1) {
          console.log(`[nrtc]: ${userId} 加入房间`);
          this.remoteUsers = this.remoteUsers.concat({nickName: '昵称丢失了', uid: userId})
          this.onRemoteStreamUpdate(event.uid)
          const { members } = await this.getUserInfoRequest(userId)
          this.remoteUsers = this.remoteUsers.map(item => item.uid === userId ? {...item, nickName: members[0].nickName} : {...item})
        }
      } catch (error) {
        console.log('[nrtc]: error in peer-online:', error)
      } finally {
        // 这里因为上面有个异步接口，导致remoteUsers和remoteStreams不同步
        // 因此在这边再调一次，保证页面可以渲染
        this.onRemoteStreamUpdate(event.uid)
      }
    })

    // 离开房间
    this.client.on('peer-leave', (event: RTCEvent) => {
      const userId = event.uid;
      console.log(`[nrtc]: ${userId} 离开房间`);
      this.remoteUsers = this.remoteUsers.filter(item => item.uid !== userId)
      this.remoteStreams = this.remoteStreams.filter(
        (item) => item.getId() !== userId
      )
      this.onRemoteStreamUpdate(userId)
    });

    // 收到远端订阅的通知
    this.client.on('stream-added', async (event: RTCEvent) => {
      const stream = event.stream;
      const userId = stream.getId();
      if (this.remoteStreams.some(item => item.getId() === userId)) {
        console.log('[nrtc]: 收到已订阅的远端发布，需要更新', stream);
        this.remoteStreams = this.remoteStreams.map(item => item.getId() === userId ? stream : item);
        await this.rtcSubscribe(stream);
        this.onRemoteStreamUpdate(userId);
      } else if (this.remoteStreams.length < this.max - 1) {
        console.log('[nrtc]: 收到新的远端发布消息', stream)
        this.remoteStreams = this.remoteStreams.concat(stream)
        await this.rtcSubscribe(stream);
        this.onRemoteStreamUpdate(userId);
      } else {
        console.log('[nrtc]: 房间人数已满')
      }
    })

    // 收到远端停止订阅的通知
    this.client.on('stream-removed', (event: RTCEvent) => {
      const stream = event.stream
      const userId = stream.getId()
      stream.stop();
      this.remoteStreams = this.remoteStreams.map(item => item.getId() === userId ? stream : item);
      console.log('[nrtc]: 远端流停止订阅，需要更新', userId, stream)
      this.onRemoteStreamUpdate(userId)
    });

    // 收到远端的流，准备播放
    this.client.on('stream-subscribed', (event: RTCEvent) => {
      const stream = event.stream;
      const userId = stream.getId();
      console.log('[nrtc]: 收到远端的流，准备播放', userId, stream, this.remoteUsers, this.remoteStreams);
      this.onRemoteStreamSubscribed(userId);
    });

    // 收到房间关闭的消息
    this.client.on('channel-closed', () => {
      this.onDisconnect();
    })
  }

  public async join() {
    try {
      const {
        avRoomUid,
        avRoomCid,
        avRoomCheckSum,
        avRoomCName
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
        token: avRoomCheckSum
      })
      await this.initAndPlayLocalStream()
      await this.client.publish(this.localStream)
    } catch (error) {
      return Promise.reject(error);
    }
  }

  public async setupLocalView(view: HTMLElement) {
    if (!this.localStream) {
      return Promise.reject('内部错误：localStream is null');
    }
    try {
      await this.localStream.play(view)
      this.localStream.setLocalRenderMode({
        // 设置视频窗口大小
        width: view.clientWidth,
        height: view.clientHeight,
        cut: false, // 是否裁剪
      })
    } catch (error) {
      return Promise.reject('播放本地视频失败：' + error)
    }
  }

  public async setupRemoteView(userId: string, view: HTMLElement) {
    const remoteStream = this.remoteStreams.find(
      (item) => item.getId() === userId
    );
    if (!remoteStream) {
      return Promise.reject('内部错误：remoteStream is null');
    }
    try {
      await remoteStream.play(view);
      remoteStream.setRemoteRenderMode({
        // 设置视频窗口大小
        width: view.clientWidth,
        height: view.clientHeight,
        cut: false, // 是否裁剪
      });
    } catch (error) {
      return Promise.reject('播放远端视频失败：' + error);
    }
  }

  public async enableLocalVideo(enabled: boolean, deviceId?: string) {
    if (!this.localStream) {
      return Promise.reject('内部错误：localStream is null');
    }
    try {
      await this.localStream[enabled ? 'open' : 'close']({
        type: 'video',
        deviceId
      })
      if (deviceId) {
        this.cameraId = deviceId;
      }
      // if (!enabled) {
      //   this.cameraId = ''
      // } else {
      //   this.cameraId = (await this.getDevices()).video[0].deviceId
      // }
    } catch (error) {
      return Promise.reject(error)
    }
  }

  public async muteLocalAudio(mute: boolean, deviceId?: string) {
    if (!this.localStream) {
      return Promise.reject('内部错误：localStream is null');
    }
    try {
      await this.localStream[mute ? 'open' : 'close']({
        type: 'audio',
        deviceId
      })
      if (deviceId) {
        this.microphoneId = deviceId
      }
      // if (!mute) {
      //   this.microphoneId = ''
      // } else {
      //   this.microphoneId = await (await this.getDevices()).audioIn[0].deviceId
      // }
    } catch (error) {
      return Promise.reject(error)
    }
  }

  public async getDevices() {
    try {
      const deviceMap = await WebRTC2.getDevices()
      const res: {audioIn?: any, audioOut?: any, video?: any} = {};
      for(const key in deviceMap) {
        if (deviceMap.hasOwnProperty(key)) {
          res[key] = deviceMap[key]
        }
      }
      return res
    } catch (error) {
      return Promise.reject(error)
    }
  }

  public async changeDevice(type: keyof Devices, deviceId: string) {
    try {
      switch (type) {
        case 'microphoneId':
          if (this.microphoneId === deviceId) {
            return Promise.reject('无效切换')
          }
          try {
            await this.muteLocalAudio(false)
          } catch (error) {
            // 忽略
          }
          await this.muteLocalAudio(true, deviceId)
          this.onLocalStreamUpdate()
          break;
        case 'cameraId':
          if (this.cameraId === deviceId) {
            return Promise.reject('无效切换')
          }
          try {
            await this.enableLocalVideo(false)
          } catch (error) {
            // 忽略
          }
          await this.enableLocalVideo(true, deviceId)
          this.onLocalStreamUpdate()
          break;
        case 'speakerId':
          if (this.speakerId === deviceId) {
            return Promise.reject('无效切换')
          }
          await this.selectSpeakers(deviceId)
          this.onLocalStreamUpdate()
          break;
      }
    } catch (error) {
      return Promise.reject(error)
    }
  }

  public async leave() {
    try {
      await this.client.leave()
      console.log('[nrtc]: leave success')
    } catch (error) {
      console.log('[nrtc]: leave fail', error)
    } finally {
      this.destroy()
    }
  }

  public sendFeedbackRequest(params: FeedbackParams) {
    return axios.post('https://statistic.live.126.net/statics/report/feedback/demoSuggest', {
      data: JSON.stringify({
        ...params,
        feedback_source: '多人视频通话Demo',
        type: 1,
        uid: this.uid,
        cid: this.channelId,
        appkey: this.appkey,
      })
    }, {
      headers: {
        'Content-Type': "application/json; charset=utf-8"
      }
    })
  }

  private async initAndPlayLocalStream() {
    try {
      // 初始化本地的Stream实例，用于管理本端的音视频流
      this.localStream = WebRTC2.createStream({
        uid: this.uid,
        audio: true,
        video: true,
        screen: false,
      })
      //设置本地视频质量
      this.localStream.setVideoProfile({
        resolution: WebRTC2.VIDEO_QUALITY_720p, //设置视频分辨率
        frameRate: WebRTC2.CHAT_VIDEO_FRAME_RATE_15, //设置视频帧率
      })
      //设置本地音频质量
      this.localStream.setAudioProfile('speech_low_quality')
      // 初始化
      await this.localStream.init()
      // 指定一个默认的设备
      const { audioIn, audioOut, video } = await this.getDevices()
      this.microphoneId = audioIn[0].deviceId
      this.cameraId = video[0].deviceId
      this.speakerId = audioOut[0].deviceId
      // 触发回调
      this.onLocalStreamUpdate()
    } catch (error) {
      return Promise.reject(error)
    }
  }

  private async rtcSubscribe(stream: any) {
    stream.setSubscribeConfig({
      audio: true,
      video: true,
    });
    try {
      await this.client.subscribe(stream);
      console.log('[nrtc]: 订阅成功');
    } catch (error) {
      console.log('[nrtc]: 订阅失败：', error);
      return Promise.reject(error);
    }
  }

  private sendJoinChannelRequest() {
    return this.sendRequest<ChannelInfo>('/mpVideoCall/room/anonymousJoin', {
      mpRoomId: this.channelName,
      nickName: this.nickName,
      clientType: 6,
    })
  }

  private async selectSpeakers(speakerId: string) {
    const map = this.client.adapterRef?.audioHelperMap;
    if(!map || !speakerId) return
    this.speakerId = speakerId;
    for (const item in map) {
      if (map[item] && map[item].audioDomHelper && map[item].audioDomHelper.audioDom) {
        await this._selectSpeakers(map[item].audioDomHelper.audioDom, speakerId)
      }
    }
  }

  private async _selectSpeakers(element: any, speakerId: string) {
    if (element && element.sinkId === undefined) {
      return
    }

    try {
      await element.setSinkId(speakerId)
      this.speakerId = speakerId
    } catch(e) {
      return Promise.reject(e);
    }
  }

  private getUserInfoRequest(userId: string) {
    return this.sendRequest<{members: RoomMember[]}>('/mpVideoCall/room/info', {
      mpRoomId: this.channelName,
      avRoomUid: userId,
    })
  }

  private async sendRequest<T = any>(url: string, data: any): Promise<T> {
    try {
      const baseUrl = 'https://yiyong.netease.im'
      const res = await axios.post(`${baseUrl}${url}`, data, {
        headers: {
          'Content-Type': "application/json; charset=utf-8"
        },
      })
      if (res.data.code === 200) {
        return res.data.data
      }
      return Promise.reject(res.data)
    } catch (error) {
      return Promise.reject(error)
    }
  }

  private destroy() {
    this.localStream.destroy()
    WebRTC2.destroy()
    this.client = null
    this.remoteUsers = []
    this.localStream = null
    this.remoteStreams = []
    this.microphoneId = ''
    this.cameraId = ''
    this.speakerId = ''

    this.uid = ''
    this.nickName = ''
    this.appkey = ''
    // private appSecret: string = ''
    // private token: string = ''
    this.channelName = ''
    this.channelId = ''
    this.max = 4
    this.onLocalStreamUpdate = () => {}
    this.onRemoteStreamUpdate = (userId: string) => {}
    this.onRemoteStreamSubscribed = (userId: string) => {}
    this.onDisconnect = () => {}
  }
}

export default RTC;
