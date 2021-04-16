const { miniProgram: { envVersion } } = wx.getAccountInfoSync()

export default {
  baseUrl: envVersion === 'release' ? 'https://yiyong.netease.im' : 'https://yiyong-qa.netease.im',
  appkey: '', // 请填入自己的appkey
}
