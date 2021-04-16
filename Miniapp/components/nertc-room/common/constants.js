export const EVENT = {
  ERROR: 'error',
  STREAM_ADDED: 'stream-added', // 通知应用程序已添加远端音视频流
  STREAM_REMOVED: 'stream-removed', // 通知应用程序已删除远端音视频流
  SYNC_DONE: 'syncDone', // 通知应用程序更新后的推流地址和拉流地址
  CLIENT_LEAVE: 'clientLeave', // 通知应用程序有人离开房间
  CLIENT_JOIN: 'clientJoin', // 通知应用程序有人加入房间
  CLIENT_UPDATE: 'clientUpdate', // 通知应用程序有人更新
  KICKED: 'kicked', // 通知应用程序自己被踢出
  OPEN: 'open', // 通知应用程序socket建立成功
  DISCONNECT: 'disconnect', // 通知应用程序音视频socket关闭
  WILLRECONNECT: 'willreconnect', // 通知应用程序信令准备重连
  SENDCOMMANDOVERTIME: 'sendCommandOverTime', // 通知应用程序发送命令超时
  LIVEROOMCLOSE: 'liveRoomClose', // 通知应用程序房间被解散
  MUTE_AUDIO: 'mute-audio', // 远端mute了自己的audio
  UNMUTE_AUDIO: 'unmute-audio', // 远端unmute了自己的audio
  MUTE_VIDEO: 'mute-video', // 远端mute了自己的video
  UNMUTE_VIDEO: 'unmute-video', // 远端unmute了自己的video
}

export const DEFAULT_COMPONENT_CONFIG = {
  appkey: '',
  channelName: '',
  token: '',
  mode: 0,
  uid: null,
  debug: false,
  openCamera: false,
  openMicrophone: false,
  resolution: 'SD',
  audioQuality: 'low',
  videoWidth: 360,
  videoHeight: 640,
  minBitrate: 600,
  maxBitrate: 900,
}

export const DEFAULT_PUSHER_CONFIG = {
  url: '',
  mode: 'RTC',
  autopush: true, // 自动推送
  enableCamera: false, // 是否开启摄像头
  enableMic: false, // 是否开启麦克风
  enableAgc: false, // 是否开启音频自动增益
  enableAns: false, // 是否开启音频噪声抑制
  enableEarMonitor: false, // 是否开启耳返（目前只在iOS平台有效）
  enableAutoFocus: true, // 是否自动对焦
  enableZoom: false, // 是否支持调整焦距
  minBitrate: 600, // 最小码率
  maxBitrate: 900, // 最大码率
  videoWidth: 360, // 视频宽（若设置了视频宽高就会忽略aspect）
  videoHeight: 640, // 视频高（若设置了视频宽高就会忽略aspect）
  beautyLevel: 0, // 美颜，取值范围 0-9 ，0 表示关闭
  whitenessLevel: 0, // 美白，取值范围 0-9 ，0 表示关闭
  videoOrientation: 'vertical', // vertical horizontal
  videoAspect: '9:16', // 宽高比，可选值有 3:4,9:16
  frontCamera: 'front', // 前置或后置摄像头，可选值：front，back
  enableRemoteMirror: false, // 设置推流画面是否镜像，产生的效果会表现在 live-player
  localMirror: 'disable', // auto:前置摄像头镜像，后置摄像头不镜像（系统相机的表现）enable:前置摄像头和后置摄像头都镜像 disable: 前置摄像头和后置摄像头都不镜像
  enableBackgroundMute: false, // 进入后台时是否静音
  audioQuality: 'high', // 高音质(48KHz)或低音质(16KHz)，可选值：high，low
  audioVolumeType: 'voicecall', // 声音类型 可选值： media: 媒体音量，voicecall: 通话音量
  audioReverbType: 0, // 音频混响类型 0: 关闭 1: KTV 2: 小房间 3:大会堂 4:低沉 5:洪亮 6:金属声 7:磁性
  waitingImage: 'https://yx-web-nosdn.netease.im/quickhtml%2Fassets%2Fyunxin%2Fdefault%2Fgroupcall%2FLark20210401-161321.jpeg', // 当微信切到后台时的垫片图片
  waitingImageHash: '',
  beautyStyle: 'smooth', // 美颜类型，取值有：smooth: 光滑 、nature: 自然
  filter: 'standard', // standard: 标准 pink: 粉嫩 nostalgia: 怀旧 blues: 蓝调 romantic: 浪漫  cool: 清凉 fresher: 清新 solor: 日系 aestheticism: 唯美 whitening:美白 cerisered: 樱红
}

export const DEFAULT_PLAYER_CONFIG = {
  mode: 'RTC',
  autoplay: true, // 7.0.9 必须设置为true，否则 Android 有概率调用play()失败
  muteAudio: true, // 默认不拉取音频，需要手动订阅，如果要快速播放，需要设置false
  muteVideo: true, // 默认不拉取视频，需要手动订阅，如果要快速播放，需要设置false
  orientation: 'vertical', // 画面方向 vertical horizontal
  objectFit: 'contain', // 填充模式，可选值有 contain，fillCrop
  enableBackgroundMute: false, // 进入后台时是否静音（已废弃，默认退台静音）
  minCache: 0.2, // 最小缓冲区，单位s（RTC 模式推荐 0.2s）
  maxCache: 0.8, // 最大缓冲区，单位s（RTC 模式推荐 0.8s）
  soundMode: 'speaker', // 声音输出方式 ear speaker
  enableRecvMessage: 'false', // 是否接收SEI消息
  autoPauseIfNavigate: true, // 当跳转到其它小程序页面时，是否自动暂停本页面的实时音视频播放
  autoPauseIfOpenNative: true, // 当跳转到其它微信原生页面时，是否自动暂停本页面的实时音视频播放
}
