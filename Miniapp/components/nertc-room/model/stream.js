// 一个stream 对应一个 player
import { DEFAULT_PLAYER_CONFIG } from '../common/constants.js'

class Stream {
  constructor(options) {
    Object.assign(this, DEFAULT_PLAYER_CONFIG, {
      uid: '', // 该stream 关联的userID
      isVisible: true, // 手Q初始化时不能隐藏 puser和player 否则黑屏。iOS 微信初始化时不能隐藏，否则同层渲染失败，player会置顶
      isPlaying: false,
      volume: 0, // 音量大小 0～100
      playerContext: undefined, // playerContext 依赖component context来获取，目前只能在渲染后获取
      netQualityLevel: 0, // 网络质量
      netQualityIcon: '', // 网络质量图标
      videoBitrate: null, // 视频输出比特率
      audioBitrate: null, // 音频输出比特率
    }, options)
  }
  setProperty(options) {
    Object.assign(this, options)
  }
  play() {
    if (this.playerContext) {
      this.playerContext.play()
      this.isPlaying = true
    }
  }
  replay() {
    if (this.playerContext) {
      if (this.isPlaying) {
        this.isPlaying = false
        this.playerContext.stop({
          complete: () => {
            this.playerContext.play()
            this.isPlaying = true
          }
        })
      } else {
        this.playerContext.play()
        this.isPlaying = true
      }
    }
  }
  reset() {
    if (this.playerContext) {
      this.playerContext.stop()
      this.playerContext = undefined
    }
    Object.assign(this, DEFAULT_PLAYER_CONFIG, {
      uid: '', // 该stream 关联的userID
      isVisible: true,
      isPlaying: false,
      volume: 0, // 音量大小 0～100
      playerContext: undefined,
      netQualityLevel: 0, // 网络质量
      netQualityIcon: '', // 网络质量图标
      videoBitrate: null, // 视频输出比特率
      audioBitrate: null, // 音频输出比特率
    })
  }
}

export default Stream
