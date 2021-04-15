import YunXinMiniappSDK from './resources/sdk/NERTC_Miniapp_SDK_for_WeChat_v4.1.0'
import UserController from './controllers/user-controller.js'
import Pusher from './model/pusher.js'
import { EVENT, DEFAULT_COMPONENT_CONFIG } from './common/constants.js'
import Event from './utils/event.js'
import * as ENV from './utils/env'
import { prevent } from '../../utils/index.js'
import { logger } from './utils/logger.js'
import config from '../../config/index'

const TAG_NAME = 'NERTC-ROOM'

// const netStatusIconMap = {
//   0: './resources/images/signal-grey.png',
//   1: './resources/images/signal-green.png',
//   2: './resources/images/signal-green.png',
//   3: './resources/images/signal-yellow.png',
//   4: './resources/images/signal-red.png',
//   5: './resources/images/signal-red.png',
//   6: './resources/images/signal-grey.png',
// }

Component({
  properties: {
    config: {
      type: Object,
      value: {
        appkey: '',
        channelName: '', // 服务端返回的channelName
        token: '',
        uid: null,
        debug: false,
        // 以下是录制相关，暂不支持
        // rtmpRecord: 0,
        // recordAudio: 0,
        // recordVideo: 0,
        // recordType: null,
        // liveEnable: null,

        originChannelName: '', // 用户填写的channelName
        openCamera: false,
        openMicrophone: false,
        resolution: null,
        audioQuality: null,
        videoWidth: null,
        videoHeight: null,
        minBitrate: null,
        maxBitrate: null,
      },
      observer: function(newVal, oldVal) {
        this._propertyObserver({
          name: 'config',
          newVal,
          oldVal,
        })
      },
    },
  },
  data: {
    pusher: null,
    userList: [],
    debug: false,
    cameraPosition: '', // 摄像头位置，用于debug
    moreToolsVisible: false, // 更多工具是否显示
    beautyVisible: false, // 美颜弹窗是否显示
    statusVisible: false, // 数据弹窗是否显示
    nickName: '', // 本端用户昵称

    playerVideoBitrate: null,
    playerAudioBitrate: null,
    beautyIndex: 0,
    beautyStyleArray: [
      { value: 'smooth', label: '光滑' },
      { value: 'nature', label: '自然' },
      { value: 'close', label: '关闭' },
    ],
    filterIndex: 0,
    filterArray: [
      { value: 'standard', label: '标准' },
      { value: 'pink', label: '粉嫩' },
      { value: 'nostalgia', label: '怀旧' },
      // { value: 'blues', label: '蓝调' },
      // { value: 'romantic', label: '浪漫' },
      // { value: 'cool', label: '清凉' },
      // { value: 'fresher', label: '清新' },
      { value: 'solor', label: '日系' },
      { value: 'aestheticism', label: '唯美' },
      { value: 'whitening', label: '美白' },
      // { value: 'cerisered', label: '樱红' },
    ],
  },
  lifetimes: {
    created: function() {
      // 在组件实例刚刚被创建时执行
      logger.log(TAG_NAME, 'created', ENV)
    },
    attached: function() {
      // 在组件实例进入页面节点树时执行
      logger.log(TAG_NAME, 'attached')
      this._init()
    },
    ready: function() {
      // 在组件在视图层布局完成后执行
      logger.log(TAG_NAME, 'ready')
    },
    detached: function() {
      // 在组件实例被从页面节点树移除时执行
      logger.log(TAG_NAME, 'detached')
      // 停止所有拉流，并重置数据
      this.exitRoom(false)
    },
    error: function(error) {
      // 每当组件方法抛出错误时执行
      logger.log(TAG_NAME, 'error', error)
    },
  },
  pageLifetimes: {
    show: function() {
      // 组件所在的页面被展示时执行
      logger.log(TAG_NAME, 'show status:', this.status)
      if (this.status.isPending) {
        // 经历了 5000 挂起事件
        this.status.isPending = false
        // 修复iOS 最小化触发5000事件后，音频推流失败的问题
        // if (ENV.IS_IOS && this.data.pusher.enableMic) {
        //   this.unpublishLocalAudio().then(()=>{
        //     this.publishLocalAudio()
        //   })
        // }
        // 经历了 5001 浮窗关闭事件，小程序底层会自动退房，恢复小程序时组件需要重新进房
        // 重新进房
        this.enterRoom({
          channelName: this.data.config.channelName,
          token: this.data.config.token,
          uid: this.data.config.uid,
        })
      }
      this.status.pageLife = 'show'
    },
    hide: function() {
      // 组件所在的页面被隐藏时执行
      logger.log(TAG_NAME, 'hide')
      this.status.pageLife = 'hide'
    },
    resize: function(size) {
      // 组件所在的页面尺寸变化时执行
      logger.log(TAG_NAME, 'resize', size)
    },
  },
  methods: {
    _init() {
      logger.log(TAG_NAME, '_init')
      this.userController = new UserController(this)
      this._emitter = new Event()
      this._initStatus()
      this._keepScreenOn()
    },
    _initStatus() {
      this.status = {
        hasExit: false, // 标记是否已经退出
        isPush: false, // 推流状态
        isPending: false, // 挂起状态，触发5000事件标记为true，onShow后标记为false
        pageLife: '', // 页面生命周期 hide, show
        isOnHideAddStream: false, // onHide后有新增Stream
      }
      this._isFullScreen = false // 是否全屏模式
      this._lastTapTime = 0 // 点击时间戳 用于判断双击事件
      this._beforeLastTapTime = 0 // 点击时间戳 用于判断双击事件
      this._lastTapCoordinate = { x: 0, y: 0 } // 点击时的坐标
    },
    _initRtc({ debug, appkey }) {
      logger.log(TAG_NAME, '_initRtc')
      const client = YunXinMiniappSDK.Client({
        debug,
        appkey,
      })
      client.init()

      // 注册监听
      client.on(EVENT.ERROR, this._onG2Error.bind(this))
      client.on(EVENT.STREAM_ADDED, this._onStreamAdded.bind(this))
      client.on(EVENT.STREAM_REMOVED, this._onStreamRemoved.bind(this))
      client.on(EVENT.SYNC_DONE, this._onSyncDone.bind(this))
      client.on(EVENT.CLIENT_LEAVE, this._onClientLeave.bind(this))
      client.on(EVENT.CLIENT_JOIN, this._onClientJoin.bind(this))
      client.on(EVENT.CLIENT_UPDATE, this._onClientUpdate.bind(this))
      client.on(EVENT.MUTE_AUDIO, this._onAudioMuteChange.bind(this, true))
      client.on(EVENT.UNMUTE_AUDIO, this._onAudioMuteChange.bind(this, false))
      client.on(EVENT.MUTE_VIDEO, this._onVideoMuteChange.bind(this, true))
      client.on(EVENT.UNMUTE_VIDEO, this._onVideoMuteChange.bind(this, false))
      client.on(EVENT.KICKED, this._onKicked.bind(this))
      client.on(EVENT.OPEN, this._onOpen.bind(this))
      client.on(EVENT.DISCONNECT, this._onDisconnect.bind(this))
      client.on(EVENT.WILLRECONNECT, this._onWillReconnect.bind(this))
      client.on(EVENT.SENDCOMMANDOVERTIME, this._onSendCommandOverTime.bind(this))
      client.on(EVENT.LIVEROOMCLOSE, this._onLiveRoomClose.bind(this))

      this.client = client
    },
    /**
     * 监听组件属性变更，外部变更组件属性时触发该监听
     * @param {Object} data newVal，oldVal
     */
     _propertyObserver(data) {
       logger.log(TAG_NAME, '_propertyObserver', data, this.data.config)
       if (data.name === 'config') {
        const config = Object.assign({}, DEFAULT_COMPONENT_CONFIG, data.newVal)
        if (!config.appkey) {
          return
        }
        // 初始化sdk
        this._initRtc({
          debug: config.debug,
          appkey: config.appkey,
        })
        // 独立设置与音视频无关的参数
        this.setData({
          debug: config.debug,
          nickName: config.nickName,
        })
        this._setPusherConfig({
          enableCamera: config.openCamera,
          enableMic: config.openMicrophone,
          audioQuality: config.audioQuality,
          minBitrate: config.minBitrate,
          maxBitrate: config.maxBitrate,
          videoWidth: config.videoWidth,
          videoHeight: config.videoHeight,
        })
       }
     },

     //  _______             __        __  __
    //  |       \           |  \      |  \|  \
    //  | $$$$$$$\ __    __ | $$____  | $$ \$$  _______
    //  | $$__/ $$|  \  |  \| $$    \ | $$|  \ /       \
    //  | $$    $$| $$  | $$| $$$$$$$\| $$| $$|  $$$$$$$
    //  | $$$$$$$ | $$  | $$| $$  | $$| $$| $$| $$
    //  | $$      | $$__/ $$| $$__/ $$| $$| $$| $$_____
    //  | $$       \$$    $$| $$    $$| $$| $$ \$$     \
    //   \$$        \$$$$$$  \$$$$$$$  \$$ \$$  \$$$$$$$

    /**
     * 进房
     * @param {Object} params
     * @returns {Promise}
     */
    enterRoom(params) {
      logger.log(TAG_NAME, 'enterRoom', params);
      return new Promise((resolve, reject) => {
        if (!this._checkParam(params)) {
          reject('缺少必要参数')
          return
        }
        this.client.join(params)
          .then(() => {
            logger.log(TAG_NAME, 'enterRoom: join success')
            return this.client.publish()
          })
          .then(url => {
            logger.log(TAG_NAME, 'enterRoom: publish success', url)
            const pusher = Object.assign(this.data.pusher, { url })
            this.setData({
              pusher
            }, () => {
              logger.log(TAG_NAME, 'enterRoom success', this.data.pusher)
              this._pusherStart()
              this.status.isPush = true
              resolve()
            })
          })
          .catch(error => {
            logger.error(TAG_NAME, 'enterRoom fail: ', error);
            reject(error)
          })
      })
    },
     /**
     * 退房，停止推流和拉流，并重置数据
     * @param {Boolean} needBack
     * @returns {Promise}
     */
    exitRoom(needBack = true) {
      if (this.status.hasExit) {
        return
      }
      this.status.hasExit = true
      logger.log(TAG_NAME, 'exitRoom')
      this.client.leave().then(() => {
        logger.log(TAG_NAME, 'exitRoom success')
        this._resetState()
      }).catch(err => {
        // 该错误可以忽略
        // logger.log(TAG_NAME, 'exitRoom fail: ', err)
        this._resetState()
      })
      if (needBack) {
        wx.navigateBack({
          delta: 1,
        })
      }
    },
    /**
     * 开启摄像头
     * @returns {Promise}
     */
    publishLocalVideo() {
      // 设置 pusher enableCamera
      logger.log(TAG_NAME, 'publishLocalVideo 开启摄像头')
      return this.client.publish('video').then(url => {
        logger.log(TAG_NAME, 'publishVideo success', url)
        return this._setPusherConfig({ url, enableCamera: true })
      }).then(() => {
        this._pusherStart()
      })
    },
     /**
     * 关闭摄像头
     * @returns {Promise}
     */
    unpublishLocalVideo() {
      logger.log(TAG_NAME, 'unpublshLocalVideo 关闭摄像头')
      return this.client.unpublish('video').then(url => {
        logger.log(TAG_NAME, 'unpublishVideo success', url)
        return this._setPusherConfig({ enableCamera: false })
      })
    },
    /**
     * 开启麦克风
     * @returns {Promise}
     */
    publishLocalAudio() {
      // 设置 pusher enableCamera
      logger.log(TAG_NAME, 'publishLocalAudio 开启麦克风')
      return this.client.publish('audio').then(url => {
        logger.log(TAG_NAME, 'publishAudio success', url)
        return this._setPusherConfig({ url, enableMic: true })
      }).then(() => {
        this._pusherStart()
      })
    },
    /**
     * 关闭麦克风
     * @returns {Promise}
     */
    unpublishLocalAudio() {
      // 设置 pusher enableCamera
      logger.log(TAG_NAME, 'unpublshLocalAudio 关闭麦克风')
      return this.client.unpublish('audio').then(url => {
        logger.log(TAG_NAME, 'unpublishAudio success', url)
        return this._setPusherConfig({ enableMic: false })
      })
    },
    /**
     * 切换前后摄像头
     */
    switchCamera() {
      if (!this.data.cameraPosition) {
        // this.data.pusher.cameraPosition 是初始值，不支持动态设置
        this.data.cameraPosition = this.data.pusher.frontCamera
      }
      logger.log(TAG_NAME, 'switchCamera', this.data.cameraPosition)
      this.data.cameraPosition = this.data.cameraPosition === 'front' ? 'back' : 'front'
      this.setData({
        cameraPosition: this.data.cameraPosition,
      }, () => {
        logger.log(TAG_NAME, 'switchCamera success', this.data.cameraPosition)
      })
      // wx 7.0.9 不支持动态设置 pusher.frontCamera ，只支持调用 API switchCamer() 设置，这里修改 cameraPosition 是为了记录状态
      this.data.pusher.getPusherContext().switchCamera()
    },
    /**
     * 切换本端视频全屏
     * @returns {Promise}
     */
    togglePusherFullScreen() {
      logger.log(TAG_NAME, 'togglePusherFullScreen')
      return this._togglePusherFullScreen()
    },
    /**
     * 切换远端视频全屏
     * @param {Object} params uid
     * @returns {Promise}
     */
    togglePlayerFullScreen(params) {
      logger.log(TAG_NAME, 'togglePlayerFullScreen', params)
      const { uid } = params
      const user = this.userController.getUser(uid)
      if (!user) {
        return Promise.reject(TAG_NAME, 'togglePlayerFullScreen', 'remoteUser is not found')
      }
      if (user.isFullScreen) {
        this._setPusherNormal()
        this.userController.getAllUser().forEach(item => {
          this._setPlayerNormal(item.uid)
        })
        this._isFullScreen = false
      } else {
        this._setPusherListener()
        this.userController.getAllUser().forEach(item => {
          if (item.uid === uid) {
            this._setPlayerFullScreen(item.uid)
          } else {
            this._setPlayerListener(item.uid)
          }
        })
        this._sortPlayerListenerIndex()
        this._isFullScreen = true
      }
      return this._setList()
    },
    on(eventCode, handler, context) {
      this._emitter.on(eventCode, handler, context)
    },
    off(eventCode, handler) {
      this._emitter.off(eventCode, handler)
    },

    // ______             __                                              __
    // |      \           |  \                                            |  \
    //  \$$$$$$ _______  _| $$_     ______    ______   _______    ______  | $$
    //   | $$  |       \|   $$ \   /      \  /      \ |       \  |      \ | $$
    //   | $$  | $$$$$$$\\$$$$$$  |  $$$$$$\|  $$$$$$\| $$$$$$$\  \$$$$$$\| $$
    //   | $$  | $$  | $$ | $$ __ | $$    $$| $$   \$$| $$  | $$ /      $$| $$
    //  _| $$_ | $$  | $$ | $$|  \| $$$$$$$$| $$      | $$  | $$|  $$$$$$$| $$
    // |   $$ \| $$  | $$  \$$  $$ \$$     \| $$      | $$  | $$ \$$    $$| $$
    //  \$$$$$$ \$$   \$$   \$$$$   \$$$$$$$ \$$       \$$   \$$  \$$$$$$$ \$$
    /**
     * 设置推流参数并触发页面渲染更新
     * @param {Object} config live-pusher 的配置
     * @returns {Promise}
     */
    _setPusherConfig(config) {
      return new Promise((resolve) => {
        let pusher
        if (!this.data.pusher) {
          pusher = new Pusher(config)
        } else {
          pusher = Object.assign(this.data.pusher, config)
        }
        this.setData({
          pusher,
        }, () => {
          resolve(config)
        })
      })
    },
    _getUserInfo(uid) {
      return new Promise((resolve, reject) => {
        wx.request({
          method: 'post',
          url: `${config.baseUrl}/mpVideoCall/room/info`,
          header: {
            'Content-Type': 'application/json; charset=utf-8',
          },
          data: {
            mpRoomId: this.data.config.originChannelName + '',
            avRoomUid: uid
          },
          success: ({ data }) => {
            if (data.code !== 200) {
              logger.log(TAG_NAME, '_getUserInfo faild: ', data.msg)
              reject(data.msg)
              return
            }
            logger.log(TAG_NAME, '_getUserInfo success', data)
            resolve(data.data)
          },
          fail: (err) => {
            logger.log(TAG_NAME, '_getUserInfo faild: ', err)
            reject(err)
          }
        })
      })
    },
    _setList() {
      return new Promise(resolve => {
        this.setData({
          userList: this.userController.getAllUser()
        }, () => {
          resolve()
        })
      })
    },
    _resetState() {
      if (this.data.pusher) {
        this.data.pusher.reset()
      }
      this.status.isPush = false
      this.status.isPending = false
      this.status.pageLife = ''
      this.status.isOnHideAddStream = false
      this._isFullScreen = false
      this.userController.reset()
      this.setData({
        pusher: null,
        userList: [],
      })
      this.client.destroy()
    },
    _onG2Error(err) {
      logger.error(TAG_NAME, '_onG2Error', err)
    },
    async _onStreamAdded (data) {
      logger.log(TAG_NAME, '_onStreamAdded', data)
      try {
        const { uid, mediaType } = data
        const res = await this.client.subscribe(uid, mediaType)
        logger.log(TAG_NAME, '_onStreamAdded', 'subscribe success', res)
        const { url } = res
        const user = this.userController.addUser({ uid, url })
        if (user && user.stream && mediaType) {
          const streamParams = mediaType === 'audio' ? {
            muteAudio: false
          } : mediaType === 'video' ? {
            muteVideo: false
          } : {}
          user.stream.setProperty(streamParams)
        }

        // const { members } = await this._getUserInfo(uid)
        // user = this.userController.addUser({ uid, url, nickName: members[0].nickName })
        // // 如果此时是全屏模式，需要将新加入的人置为跟随者模式
        // if (this._isFullScreen) {
        //   this._setPlayerListener(uid)
        //   this._sortPlayerListenerIndex()
        // }

        await this._setList()
        if (user.stream.playerContext) {
          user.stream.replay()
          logger.log(TAG_NAME, '_onStreamAdded replay success', user)
        } else {
          user.stream.setProperty({ playerContext: wx.createLivePlayerContext(uid + '', this) })
          user.stream.play()
          logger.log(TAG_NAME, '_onStreamAdded play success', user)
        }
      } catch (error) {
        logger.error(TAG_NAME, '_onStreamAdded fail: ', err)
      }
    },
    _onStreamRemoved(data) {
      logger.log(TAG_NAME, '_onStreamRemoved', data)
      const { uid, mediaType } = data
      const user = this.userController.getUser(uid)
      if (user && user.stream) {
        if (mediaType === 'audio') {
          user.stream.setProperty({ muteAudio: true })
        } else if (mediaType === 'video') {
          user.stream.setProperty({ muteVideo: true })
        }
        this._setList()
      }
    },
    _onSyncDone(data) {
      logger.log(TAG_NAME, '_onSyncDone', data)
      const { userlist: userList } = data
      // 更新pusher
      const newPusher = userList.find(item => item.uid === this.data.config.uid)
      if (newPusher && newPusher.url && newPusher.url !== this.data.pusher.url) {
        // pusher url有变更，重新推流
        this._setPusherConfig({ url: newPusher.url }).then(() => {
          this._pusherStart()
        })
      }
      // 更新streams
      userList.filter(item => item.uid !== this.data.config.uid)
        .forEach(item => {
        const { uid, url } = item
        let user = this.userController.addUser({ uid, url })
        logger.log(TAG_NAME, '_onSyncDone addUser', user)
        this._getUserInfo(uid).then(res => {
          const { members } = res
          user = this.userController.addUser({ uid, url, nickName: members[0].nickName })
          logger.log(TAG_NAME, '_onSyncDone getUserInfo', user)
          return this._setList()
        }).then(() => {
          logger.log(TAG_NAME, '_onSyncDone play', user)
          if (user.stream.playerContext) {
            user.stream.replay()
          } else {
            user.stream.setProperty({ playerContext: wx.createLivePlayerContext(uid + '', this) })
            user.stream.play()
          }
        })
      })
    },
    _onClientLeave(data) {
      logger.log(TAG_NAME, '_onClientLeave', data)
      const { uid } = data
      // 如果开着全屏模式的人走了，需要重置为画廊模式
      const user = this.userController.getUser(uid)
      if (user) {
        if (user.isFullScreen && this._isFullScreen) {
          this._setPusherNormal()
          this.userController.getAllUser().filter(item => item.uid !== uid).forEach(item => {
            this._setPlayerNormal(item.uid)
          })
          this._isFullScreen = false
        }
        this.userController.removeUser(uid)
        this._setList()
      }
    },
    _onClientJoin(data) {
      logger.log(TAG_NAME, '_onClientJoin', data)
      const { uid } = data
      this.userController.addUser({ uid })
      this._getUserInfo(uid).then(res => {
        const { members } = res
        this.userController.addUser({ uid, nickName: members[0].nickName })
        // 如果此时是全屏模式，需要将新加入的人置为跟随者模式
        if (this._isFullScreen) {
          this._setPlayerListener(uid)
          this._sortPlayerListenerIndex()
        }
        this._setList()
      }).catch(err => {
        logger.error(TAG_NAME, '_onClientJoin', '_getUserInfo fail: ', err)
      })
    },
    _onClientUpdate(data) {
      logger.log(TAG_NAME, '_onClientUpdate', data)
      const { uid } = data
      const user = this.userController.getUser(uid)
      if (user) {
        if (user.stream.playerContext) {
          user.stream.replay()
        } else {
          user.stream.setProperty({ playerContext: wx.createLivePlayerContext(uid + '', this) })
          user.stream.play()
        }
      }
    },
    _onAudioMuteChange(mute, uid) {
      logger.log(TAG_NAME, '_onAudioMuteChange', uid, mute)
      // const user = this.userController.getUser(uid)
      // if (user && user.stream) {
      //   if (user.stream.playerContext) {
      //     user.stream.setProperty({ muteAudio: mute })
      //     this._setList()
      //   }
      // }
    },
    _onVideoMuteChange(mute, uid) {
      logger.log(TAG_NAME, '_onVideoMuteChange', uid, mute)
      // const user = this.userController.getUser(uid)
      // if (user && user.stream) {
      //   if (user.stream.playerContext) {
      //     user.stream.setProperty({ muteVideo: mute })
      //     this._setList()
      //   }
      // }
    },
    _onKicked(data) {
      logger.log(TAG_NAME, '_onKicked', data)
      this.exitRoom()
    },
    _onOpen(data) {
      logger.log(TAG_NAME, '_onOpen', data)
    },
    _onDisconnect(data) {
      logger.log(TAG_NAME, '_onDisconnect', data)
      this.exitRoom()
    },
    _onWillReconnect(data) {
      logger.log(TAG_NAME, '_onWillReconnect', data)
    },
    _onSendCommandOverTime(data) {
      logger.log(TAG_NAME, '_onSendCommandOverTime', data)
    },
    _onLiveRoomClose(data) {
      logger.log(TAG_NAME, '_onLiveRoomClose', data)
      this.exitRoom()
    },
    /**
     * 保持屏幕常亮
     */
     _keepScreenOn() {
      setInterval(() => {
        wx.setKeepScreenOn({
          keepScreenOn: true,
        })
      }, 20000)
    },
    /**
     * 必选参数检测
     * @param {Object} rtcConfig rtc参数
     * @returns {Boolean}
     */
     _checkParam(rtcConfig) {
      logger.log(TAG_NAME, 'checkParam config:', rtcConfig)
      if (!rtcConfig.channelName) {
        logger.error('未设置 channelName')
        return false
      }
      if (!rtcConfig.token) {
        logger.error('未设置 token')
        return false
      }
      if (!rtcConfig.uid) {
        logger.error('未设置 uid')
        return false
      }
      return true
    },
    _pusherStateChangeHandler(event) {
      const { code, message } = event.detail
      switch (code) {
        case 0: // 未知状态码，不做处理
          logger.log(TAG_NAME, message, code)
          break
        case 1001:
          logger.log(TAG_NAME, '已经连接推流服务器', code)
          break
        case 1002:
          logger.log(TAG_NAME, '已经与服务器握手完毕,开始推流', code)
          break
        case 1003:
          logger.log(TAG_NAME, '打开摄像头成功', code)
          break
        case 1004:
          logger.log(TAG_NAME, '录屏启动成功', code)
          break
        case 1005:
          logger.log(TAG_NAME, '推流动态调整分辨率', code)
          break
        case 1006:
          logger.log(TAG_NAME, '推流动态调整码率', code)
          break
        case 1007:
          logger.log(TAG_NAME, '首帧画面采集完成', code)
          break
        case 1008:
          logger.log(TAG_NAME, '编码器启动', code)
          break
        case 2003:
          logger.log(TAG_NAME, '渲染首帧视频', code)
          break
        case -1301:
          logger.error(TAG_NAME, '打开摄像头失败: ', code)
          break
        case -1302:
          logger.error(TAG_NAME, '打开麦克风失败: ', code)
          break
        case -1303:
          logger.error(TAG_NAME, '视频编码失败: ', code)
          break
        case -1304:
          logger.error(TAG_NAME, '音频编码失败: ', code)
          break
        case -1307:
          logger.error(TAG_NAME, '推流连接断开: ', code)
          this._pusherStart()
          break
        case 5000:
          logger.log(TAG_NAME, '小程序被挂起: ', code)
          // 20200421 iOS 微信点击胶囊圆点会触发该事件
          // 触发 5000 后，底层SDK会退房，返回前台后会自动进房
          break
        case 5001:
          // 20200421 仅有 Android 微信会触发该事件
          logger.log(TAG_NAME, '小程序悬浮窗被关闭: ', code)
          this.status.isPending = true
          if (this.status.isPush) {
            this.exitRoom()
          }
          break
        case 1021:
          logger.log(TAG_NAME, '网络类型发生变化，需要重新进房', code)
          break
        case 2007:
          logger.log(TAG_NAME, '本地视频播放loading: ', code)
          break
        case 2004:
          logger.log(TAG_NAME, '本地视频播放开始: ', code)
          break
        default:
          logger.log(TAG_NAME, message, code)
          break
      }
    },
    _pusherNetStatusHandler(event) {
      logger.log(TAG_NAME, '_pusherNetStatusHandler', event)
      const {
        videoFPS,
        videoBitrate,
        audioBitrate,
        // netQualityLevel,
      } = event.detail.info

      if (this.data.statusVisible) {
        this._setPusherConfig({
          videoFPS: Math.round(videoFPS),
          videoBitrate,
          audioBitrate,
          // netQualityLevel,
          // netQualityIcon: netStatusIconMap[netQualityLevel],
        })
      }
    },
    _pusherErrorHandler(event) {
      logger.log(TAG_NAME, '_pusherErrorHandler', event)
    },
    _pusherBGMStartHandler(event) {
      // logger.log(TAG_NAME, '_pusherBGMStartHandler', event)
    },
    _pusherBGMProgressHandler(event) {
      // logger.log(TAG_NAME, '_pusherBGMProgressHandler', event)
    },
    _pusherBGMCompleteHandler(event) {
      // logger.log(TAG_NAME, '_pusherBGMCompleteHandler', event)
    },
    _pusherAudioVolumeNotify(event) {
      // logger.log(TAG_NAME, '_pusherAudioVolumeNotify', event)
    },
    _playerStateChange(event) {
      const { code, message } = event.detail
      const { nickname } = event.currentTarget.dataset
      switch (code) {
        case -2301:
          logger.error(TAG_NAME, message, code)
          wx.showToast({
            title: `${nickname} 拉流彻底断了`,
            icon: 'none',
            duration: 2000,
          })
          break
        default:
          logger.log(TAG_NAME, message, code)
          break
      }
    },
    _playerFullscreenChange(event) {
      // logger.log(TAG_NAME, '_playerFullscreenChange', event)
    },
    _playerNetStatus(event) {
      logger.log(TAG_NAME, '_playerNetStatus', event)
      if (this.data.statusVisible) {
        const uid = Number(event.currentTarget.dataset.uid)
        const user = this.userController.getUser(uid)
        const { videoBitrate, audioBitrate } = event.detail.info
        if (user && user.stream) {
          user.stream.setProperty({ videoBitrate, audioBitrate })
        }
        const averageBitrate = this.userController.getAverageBitrate()
        this.setData({
          playerVideoBitrate: averageBitrate.videoBitrate,
          playerAudioBitrate: averageBitrate.audioBitrate,
        })
      }
    },
    _playerAudioVolumeNotify(event) {
      // logger.log(TAG_NAME, '_playerAudioVolumeNotify', event)
    },
    _pusherStart() {
      this.data.pusher.getPusherContext().start({
        success: () => {
          logger.log(TAG_NAME, '_pusherStart 推流成功')
        },
        fail: (err) => {
          logger.log(TAG_NAME, '_pusherStart 推流失败', err)
        },
      })
    },

    //  ________                                  __             __
    //  |        \                                |  \           |  \
    //   \$$$$$$$$______   ______ ____    ______  | $$  ______  _| $$_     ______
    //     | $$  /      \ |      \    \  /      \ | $$ |      \|   $$ \   /      \
    //     | $$ |  $$$$$$\| $$$$$$\$$$$\|  $$$$$$\| $$  \$$$$$$\\$$$$$$  |  $$$$$$\
    //     | $$ | $$    $$| $$ | $$ | $$| $$  | $$| $$ /      $$ | $$ __ | $$    $$
    //     | $$ | $$$$$$$$| $$ | $$ | $$| $$__/ $$| $$|  $$$$$$$ | $$|  \| $$$$$$$$
    //     | $$  \$$     \| $$ | $$ | $$| $$    $$| $$ \$$    $$  \$$  $$ \$$     \
    //      \$$   \$$$$$$$ \$$  \$$  \$$| $$$$$$$  \$$  \$$$$$$$   \$$$$   \$$$$$$$
    //                                  | $$
    //                                  | $$
    //                                   \$$
    _toggleVideo: prevent(function() {
      if (this.data.pusher.enableCamera) {
        this.unpublishLocalVideo()
      } else {
        this.publishLocalVideo()
      }
    }, 1000),
    _toggleAudio: prevent(function() {
      if (this.data.pusher.enableMic) {
        this.unpublishLocalAudio()
      } else {
        this.publishLocalAudio()
      }
    }, 1000),
    _toggleVisible(e) {
      const key = e.currentTarget.dataset.key
      this.setData({
        [key]: !this.data[key]
      })
    },
    _selectBeautyStyle: function() {
      logger.log(TAG_NAME, '_selectBeautyStyle')
      wx.showActionSheet({
        itemList: this.data.beautyStyleArray.map(item => item.label),
        success: (res) => {
          const index = res.tapIndex
          const value = this.data.beautyStyleArray[index].value
          this.setData({
            beautyIndex: index
          }, () => {
            this._setPusherConfig({
              beautyLevel: value === 'close' ? 0 : 9,
              beautyStyle: value === 'close' ? 'smooth' : value,
            })
          })
        },
        fail: (err) => {
          logger.log(TAG_NAME, '_selectBeautyStyle fail: ', err)
        },
      })
    },
    _selectFilter: function() {
      logger.log(TAG_NAME, '_selectFilter')
      wx.showActionSheet({
        itemList: this.data.filterArray.map(item => item.label),
        success: (res) => {
          const index= res.tapIndex
          this.setData({
            filterIndex: index
          }, () => {
            this._setPusherConfig({
              filter: this.data.filterArray[index].value
            })
          })
        },
        fail: (err) => {
          logger.log(TAG_NAME, '_selectFilter fail: ', err)
        },
      })
    },
    _togglePusherFullScreen() {
      if (this.data.pusher.isFullScreen) {
        this._setPusherNormal()
        this.userController.getAllUser().forEach(item => {
          this._setPlayerNormal(item.uid)
        })
        this._isFullScreen = false
      } else {
        this._setPusherFullScreen()
        this.userController.getAllUser().forEach(item => {
          this._setPlayerListener(item.uid)
        })
        this._sortPlayerListenerIndex()
        this._isFullScreen = true
      }
      return this._setList()
    },
    _togglePlayerFullScreen(event) {
      const uid = Number(event.currentTarget.dataset.uid)
      this.togglePlayerFullScreen({ uid })
    },
    _setPusherFullScreen() {
      return this._setPusherConfig({ isFullScreen: true, isListener: false, listenerIndex: null })
    },
    _setPusherNormal() {
      return this._setPusherConfig({ isFullScreen: false, isListener: false, listenerIndex: null })
    },
    _setPusherListener() {
      return this._setPusherConfig({ isFullScreen: false, isListener: true, listenerIndex: 0 })
    },
    _setPlayerFullScreen(uid) {
      const user = this.userController.getUser(uid)
      if (user) {
        user.setProperty({
          isFullScreen: true,
          isListener: false,
          listenerIndex: null,
        })
      }
    },
    _setPlayerNormal(uid) {
      const user = this.userController.getUser(uid)
      if (user) {
        user.setProperty({
          isFullScreen: false,
          isListener: false,
          listenerIndex: null,
        })
      }
    },
    _setPlayerListener(uid) {
      const user = this.userController.getUser(uid)
      if (user) {
        user.setProperty({
          isFullScreen: false,
          isListener: true,
        })
      }
    },
    _sortPlayerListenerIndex() {
      const pusherIsListenr = this.data.pusher.isListener
      this.userController.getAllUser().filter(item => item.isListener).forEach((item, index) => {
        item.setProperty({
          listenerIndex: pusherIsListenr ? (index + 1) : index
        })
      })
    },
    _preventBubble() {
      // 阻止冒泡
    },
    /**
     * 退出通话
     */
     _hangUp() {
      this.exitRoom()
    },
  },
})
