export default {
  appKey: '',
  appSecret: '',
  baseUrl:
    process.env.ENV === 'prod'
      ? 'https://yiyong.netease.im'
      : 'https://yiyong-qa.netease.im',
};
