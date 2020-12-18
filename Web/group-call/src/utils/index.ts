import axios from 'axios';
import JsSha from 'jssha';

export const getToken = ({
  uid,
  channelName,
  appkey,
  appSecret,
}: {
  uid: string;
  channelName: string;
  appkey: string;
  appSecret: string;
}): Promise<string> => {
  const getTokenUrl = 'https://api.netease.im/nimserver/user/getToken.action';
  const Nonce = Math.ceil(Math.random() * 1e9);
  const CurTime = Math.ceil(Date.now() / 1000);
  const aaa = `${appSecret}${Nonce}${CurTime}`;
  const sha1 = new JsSha('SHA-1', 'TEXT', { encoding: 'UTF8' });
  sha1.update(aaa);
  const CheckSum = sha1.getHash('HEX');
  return new Promise((resolve, reject) => {
    axios
      .post(getTokenUrl, `uid=${uid}&channelName=${channelName}`, {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
          AppKey: appkey,
          Nonce,
          CurTime,
          CheckSum,
        },
      })
      .then(function(data) {
        var d = data.data;
        if (d.code !== 200) {
          reject('getChecksum code: ' + d.code);
          return;
        }
        resolve(d.token);
      })
      .catch(error => {
        reject('getChecksum error: ' + error);
      });
  });
};

type Browser = 'ie' | 'opera' | 'safari' | 'chrome' | 'firefox';
export const checkBrowser = (type: Browser): boolean => {
  const ua = navigator.userAgent.toLowerCase();
  const info: {
    [key in Browser]: boolean
  } = {
      ie: /msie/.test(ua) && !/opera/.test(ua),
      opera: /opera/.test(ua),
      safari: /version.*safari/.test(ua),
      chrome: /chrome/.test(ua),
      firefox: /gecko/.test(ua) && !/webkit/.test(ua)
  };
  return info[type] || false;
}
