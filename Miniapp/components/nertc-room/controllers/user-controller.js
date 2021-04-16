import Event from '../utils/event'
import User from '../model/user'
import Stream from '../model/stream'

class UserController extends Event {
  constructor() {
    super();
    this.userMap = new Map()
  }
  addUser(data) {
    const { uid, url } = data
    let user = this.getUser(uid)
    if (!user) {
      user = new User(data)
      if (url) {
        user.stream = new Stream({ uid })
      }
    } else {
      // 当传入的url存在并且是个新的url的时候
      // 老的stream需要被reset
      // 并且需要创建一个新的stream
      // 否则复用老的stream
      if (url && user.url !== url) {
        if (user.stream) {
          user.stream.reset()
        }
        const stream = new Stream({ uid })
        user = Object.assign(user, data, { stream })
      } else {
        user = Object.assign(user, data)
      }
    }
    this.userMap.set(uid, user)
    return user
  }
  removeUser(uid) {
    const user = this.getUser(uid)
    if (user && user.stream && user.stream.reset) {
      user.stream.reset()
    }
    this.userMap.delete(uid)
  }
  getUser(uid) {
    return this.userMap.get(uid)
  }
  getAllUser() {
    return [...this.userMap.values()]
  }
  getAverageBitrate() {
    const hasStreamUsers = this.getAllUser().filter(item => !!item.stream)
    const total = hasStreamUsers.reduce((prev, cur) => {
      return {
        videoBitrate: Number(cur.stream.videoBitrate || 0) + Number(prev.videoBitrate || 0),
        audioBitrate: Number(cur.stream.audioBitrate || 0) + Number(prev.audioBitrate || 0),
      }
    }, {
      videoBitrate: 0,
      audioBitrate: 0,
    })
    return {
      videoBitrate: Math.round(total.videoBitrate / hasStreamUsers.length),
      audioBitrate: Math.round(total.audioBitrate / hasStreamUsers.length),
    }
  }
  /**
   * 重置所有user 和 steam
   * @returns {Object}
   */
  reset() {
    this.userMap.values(user => {
      if (user.stream) {
        user.stream.reset()
      }
    })
    this.userMap.clear()
  }
}

export default UserController
