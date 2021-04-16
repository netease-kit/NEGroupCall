import { DEFAULT_PUSHER_CONFIG } from '../common/constants.js'
import { logger } from '../utils/logger'

class Pusher {
  constructor(options) {
    Object.assign(this, DEFAULT_PUSHER_CONFIG, {
      isVisible: true, // 手Q初始化时不能隐藏 puser和player 否则黑屏
      isFullScreen: false, // 是否全屏
      isListener: false, // 是否追随者
      listenerIndex: null, // 追随者序号，用以渲染
      netQualityLevel: 0, // 网络质量
      netQualityIcon: '', // 网络质量图标
      videoFPS: null, // 视频帧率
      videoBitrate: null, // 视频输出比特率
      audioBitrate: null, // 音频输出比特率
    }, options)
  }
  /**
   * 通过wx.createLivePusherContext 获取<live-pusher> context
   * @param {Object} context 组件上下文
   * @returns {Object} livepusher context
   */
  getPusherContext(context) {
    if (!this.pusherContext) {
      this.pusherContext = wx.createLivePusherContext(context)
    }
    return this.pusherContext
  }
  reset() {
    logger.log('Pusher reset', this.pusherContext)
    if (this.pusherContext) {
      // 2020/09/23 安卓端华为小米机型发现，安卓原生返回键，退房失败。
      // 会触发detached生命周期，调用到该方法，puhserContext.stop()调用不成功，但是清空url后，客户端调用的退房方法就会不生效
      // 这里做出改动，只有stop调用成功后，才会清空url，保持组件卸载流程的完整性，调用不成功的情况将由微信客户端兜底清除
      this.pusherContext.stop({
        success: () => {
          logger.log('Pusher pusherContext.stop()')
          Object.assign(this, DEFAULT_PUSHER_CONFIG, {
            isVisible: true,
            isFullScreen: false,
            isListener: false,
            listenerIndex: null, // 追随者序号，用以渲染
            netQualityLevel: 0, // 网络质量
            netQualityIcon: '', // 网络质量图标
            videoFPS: null, // 视频帧率
            videoBitrate: null, // 视频输出比特率
            audioBitrate: null, // 音频输出比特率
          })
        },
      })
      this.pusherContext = null
    }
  }
}

export default Pusher
