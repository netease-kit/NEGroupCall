import config from '../../../config/index';
import { logger } from '../../../components/nertc-room/utils/logger.js';
import { prevent } from '../../../utils/index'
const app = getApp();

Page({
  data: {
    channelName: "",
    nickName: "",
    openCamera: true,
    openMicrophone: true,
    showOpt: false,
    resolution: 'HD',
    audioQuality: 'high',
    videoWidth: 360,
    videoHeight: 640,
    minBitrate: 600,
    maxBitrate: 900,
    resolutionArray: [
      { value: 'FHD', title: '超清' },
      { value: 'HD', title: '高清' },
      { value: 'SD', title: '标清' },
    ],
    audioQualityArray: [
      { value: 'high', title: '高' },
      { value: 'low', title: '低' },
    ],
    debug: false,
  },
  changeHandler(e) {
    const key = e.currentTarget.dataset.key
    this.setData({
      [key]: e.detail.value
    }, () => {
      if ('resolution' === key) {
        switch (this.data.resolution) {
          case 'FHD':
            this.setData({
              videoWidth: 720,
              videoHeight: 1280,
              minBitrate: 1500,
              maxBitrate: 2000,
            })
            break
          case 'SD':
            this.setData({
              videoWidth: 360,
              videoHeight: 640,
              minBitrate: 600,
              maxBitrate: 900,
            })
            break
          case 'HD':
            this.setData({
              videoWidth: 540,
              videoHeight: 960,
              minBitrate: 1000,
              maxBitrate: 1500,
            })
            break
          default:
            break
        }
      }
    })
  },
  joinRoom: prevent(function() {
    if (!this.data.channelName) {
      wx.showToast({
        title: '请填写房间号',
        icon: 'none',
        duration: 2000,
      })
      return;
    }
    if (!/^\d{1,12}$/.test(this.data.channelName)) {
      wx.showToast({
        title: '仅支持12位及以下纯数字',
        icon: 'none',
        duration: 2000,
      })
      return;
    }
    if (this.data.nickName && !/^[\u4e00-\u9fa5\da-zA-Z]{1,12}$/.test(this.data.nickName)) {
      wx.showToast({
        title: '仅支持12位及以下文本、字母及数字组合',
        icon: 'none',
        duration: 2000,
      })
      return;
    }

    const nickName = this.data.nickName || `用户${Math.ceil(Math.random() * 1000000)}`
    wx.request({
      method: 'post',
      url: `${config.baseUrl}/mpVideoCall/room/anonymousJoin`,
      header: {
        'Content-Type': 'application/json; charset=utf-8',
      },
      data: {
        mpRoomId: this.data.channelName,
        nickName,
        clientType: 7,
      },
      success: ({ data }) => {
        if (data.code !== 200) {
          const title = data.code === 2001 ? '本应用为测试产品，每个频道最多4人' : '加入失败'
          logger.error(data.msg);
          wx.showToast({
            title,
            icon: 'none',
            duration: 2000,
          })
          return
        }
        const {
          avRoomUid,
          avRoomCid,
          avRoomCheckSum,
          avRoomCName,
        } = data.data;
        const url = '/pages/group-call/room/room';
        const queryParams = {
          originChannelName: this.data.channelName,
          channelName: avRoomCName,
          uid: avRoomUid,
          channelId: avRoomCid,
          token: avRoomCheckSum,
          nickName,
          openCamera: this.data.openCamera,
          openMicrophone: this.data.openMicrophone,
          resolution: this.data.resolution,
          audioQuality: this.data.audioQuality,
          videoWidth: this.data.videoWidth,
          videoHeight: this.data.videoHeight,
          minBitrate: this.data.minBitrate,
          maxBitrate: this.data.maxBitrate,
          debug: this.data.debug,
        };
        const finalUrl = Object.keys(queryParams).reduce((prev, cur) => {
          return `${prev}${prev === url ? '?' : '&'}${cur}=${queryParams[cur]}`
        }, url)
        logger.log(finalUrl);
        wx.navigateTo({ url: finalUrl })
      },
      fail: (err) => {
        logger.error(err);
        const title = err.code && err.code === 2001 ? '本应用为测试产品，每个频道最多4人' : (err.msg || '加入失败')
        wx.showToast({
          title,
          icon: 'none',
          duration: 2000,
        })
      }
    })
  }, 2000),
  onBack: prevent(function() {
    wx.navigateBack({
      delta: 1,
      complete: () => {
        this.isBacking = false
      }
    })
  }, 2000),
  /**
   * 生命周期函数--监听页面加载
   * @param {*} options 配置项
   */
  onLoad: function (options) {},
  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady: function () {},
  /**
   * 生命周期函数--监听页面显示
   */
  onShow: function () {
    wx.setKeepScreenOn({
      keepScreenOn: true,
    });
  },
  /**
   * 生命周期函数--监听页面隐藏
   */
  onHide: function () {},
  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function () {},
});
