import config from '@/config';
import axios from 'axios';

export enum VideoQuality {
  VIDEO_QUALITY_180p = 2,
  VIDEO_QUALITY_480p = 4,
  VIDEO_QUALITY_720p = 8,
  VIDEO_QUALITY_1080p = 16,
}

export enum VideoFrame {
  CHAT_VIDEO_FRAME_RATE_NORMAL = 0,
  CHAT_VIDEO_FRAME_RATE_5 = 1,
  CHAT_VIDEO_FRAME_RATE_10 = 2,
  CHAT_VIDEO_FRAME_RATE_15 = 3,
  CHAT_VIDEO_FRAME_RATE_20 = 4,
  CHAT_VIDEO_FRAME_RATE_25 = 5,
}

export type AudioQuality =
  | 'speech_low_quality'
  | 'speech_standard'
  | 'music_standard'
  | 'standard_stereo'
  | 'high_quality'
  | 'high_quality_stereo';

export type ChannelInfo = {
  avRoomUid: number;
  avRoomCid: string;
  avRoomCheckSum: string;
  avRoomCName: string;
};

export type RoomMember = {
  nickName: string;
};

export type Devices = {
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

export type NetworkQuality = 0 | 1 | 2 | 3 | 4 | 5 | 6;

export type Stat = {
  uid: number;
  uplinkNetworkQuality: NetworkQuality;
  downlinkNetworkQuality: NetworkQuality;
};

export type DeviceItemRes = {
  label: string;
  deviceId: string;
  isDefault: boolean;
};

export type DeviceRes = {
  audioIn?: DeviceItemRes[];
  audioOut?: DeviceItemRes[];
  video?: DeviceItemRes[];
};

export type ConnectionState =
  | 'DISCONNECTED'
  | 'CONNECTING'
  | 'CONNECTED'
  | 'DISCONNECTING';

export type FeedbackParams = {
  feedback_type: number;
  content_type: number[];
  content: string;
};

export type UserInfo = {
  uid: number;
  nickName: string;
};

export interface InitOptions {
  appkey: string;
  // appSecret: string;
  channelName: string;
  nickName: string;
  options?: {
    resolution: number;
    frameRate: number;
    audioQuality: AudioQuality;
    openCamera: boolean;
    openMic: boolean;
  };
  max?: number;
  onLocalStreamUpdate(): void;
  onRemoteStreamUpdate(): void;
  onRemoteStreamSubscribed(userId: number): void;
  onDisconnect(): void;
  onNetworkQuality(stats: Stat[]): void;
  onConnectionDisconnected(): void;
}

abstract class Rtc {
  remoteUsers: UserInfo[] = [];
  localStream: any = null;
  microphoneId = '';
  cameraId = '';
  speakerId = '';

  uid?: number;
  nickName: string = '';
  options: {
    resolution?: number;
    frameRate?: number;
    audioQuality?: AudioQuality;
    openCamera: boolean;
    openMic: boolean;
  } = {
    resolution: undefined,
    frameRate: undefined,
    audioQuality: undefined,
    openCamera: false,
    openMic: false,
  };
  appkey: string = '';
  // appSecret: string = ''
  // token: string = ''
  channelName: string = '';
  channelId: string = '';
  max: number = 4;
  onLocalStreamUpdate = () => {};
  onRemoteStreamUpdate = () => {};
  onRemoteStreamSubscribed = (userId: number) => {};
  onDisconnect = () => {};
  onNetworkQuality = (stats: Stat[]) => {};
  onConnectionDisconnected = () => {};

  constructor(options: InitOptions) {
    for (const key in options) {
      if (options.hasOwnProperty(key)) {
        this[key] = options[key];
      }
    }
  }

  abstract addRtcListener(): void;
  abstract removeRtcListener(): void;
  abstract join(): Promise<void>;
  abstract setupLocalView(view: HTMLElement): Promise<void>;
  abstract setupRemoteView(userId: number, view: HTMLElement): Promise<void>;
  abstract setLocalVideoSize(view: HTMLElement): void;
  abstract setRemoteVideoSize(userId: number, view: HTMLElement): void;
  abstract enableLocalVideo(enabled: boolean, deviceId?: string): Promise<void>;
  abstract enableLocalAudio(enabled: boolean, deviceId?: string): Promise<void>;
  abstract getDevices(): Promise<DeviceRes>;
  abstract changeDevice(type: keyof Devices, deviceId: string): Promise<void>;
  abstract getInfo(): Promise<DataInfo>;
  abstract leave(): Promise<void>;
  abstract destroy(): void;

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

  public sendJoinChannelRequest() {
    return this.sendRequest<ChannelInfo>('/mpVideoCall/room/anonymousJoin', {
      mpRoomId: this.channelName,
      nickName: this.nickName,
      clientType: 6,
    });
  }

  public getUserInfoRequest(userId: number) {
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

export default Rtc;
