import { logger } from '../../../components/nertc-room/utils/logger'
import config from '../../../config/index'

const TAG_NAME = 'ROOM'

Page({
  data: {
    rtcConfig: {}
  },
  /**
   * 生命周期函数--监听页面加载
   * @param {*} options 配置项
   */
  onLoad: function(options) {
    // 将String 类型的 true false 转换成 boolean
    Object.getOwnPropertyNames(options).forEach((key) => {
      if (options[key] === 'true') {
        options[key] = true
      }
      if (options[key] === 'false') {
        options[key] = false
      }
      if (options[key] === 'undefined') {
        options[key] = undefined
      }
      if (['videoHeight', 'videoWidth', 'maxBitrate', 'minBitrate', 'uid'].includes(key)) {
        options[key] = Number(options[key])
      }
    })
    options.appkey = config.appkey
    logger.log(TAG_NAME, 'room onload', options)
    wx.showModal({
      title: '温馨提示',
      content: '本应用为测试产品、请勿商用。单次通话最长10分钟，每个频道最多4人'
    })
    this.nertcComponent = this.selectComponent('#nertc-component')
    this.setData({
      rtcConfig: options
    }, () => {
      this.nertcComponent.enterRoom({
        channelName: this.data.rtcConfig.channelName,
        token: this.data.rtcConfig.token,
        uid: this.data.rtcConfig.uid,
      }).catch(() => {
        wx.showToast({
          title: '加入房间失败',
          icon: 'none',
          duration: 2000,
        })
      })
    })
  },

  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady: function() {
    logger.log(TAG_NAME, 'room ready')
  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow: function() {
    logger.log(TAG_NAME, 'room show')
  },

  /**
   * 生命周期函数--监听页面隐藏
   */
  onHide: function() {
    logger.log(TAG_NAME, 'room hide')
  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function() {
    logger.log(TAG_NAME, 'room unload')
  },

  /**
   * 页面相关事件处理函数--监听用户下拉动作
   */
  onPullDownRefresh: function() {

  },

  /**
   * 页面上拉触底事件的处理函数
   */
  onReachBottom: function() {

  },
})
