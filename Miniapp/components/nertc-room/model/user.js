class User {
  constructor(options) {
    Object.assign(this, {
      uid: '',
      url: '',
      nickName: '',
      stream: null, // stream 是用于渲染 live-player 的数据源
      isFullScreen: false, // 是否全屏
      isListener: false, // 是否追随者
      listenerIndex: null, // 追随者序号，用以渲染
    }, options)
  }
  setProperty(options) {
    Object.assign(this, options)
  }
}

export default User
