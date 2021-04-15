# umi project

## Getting Started

Install dependencies,

```bash
$ yarn
```

Start the dev server,

```bash
$ yarn start
```
## 《跑通示例项目》多人音视频 Web
### 《跑通示例项目》文档针对接入阶段的用户，提供示例源码的运行指引，提供快速跑通示例项目Demo的方案，帮助用户快速接入。

### 网易云信音视频通话 2.0 产品为您提供开源的的示例项目，您可以参考本文档快速跑通示例项目，快速在本地运行示例 Demo，体验 NERTC SDK 的实时音视频通话的效果。
前提条件:
  1. 在开始运行示例项目之前，请确保您已完成以下操作：
    - 创建应用并获取App Key。
    - 开通音视频通话 2.0 服务。
    - 集成 SDK（Windows）。
    - 联系商务经理开通非安全模式。

开发环境:
  1. 在开始运行示例项目之前，请确保开发环境满足以下要求：
    - 开发环境：react16.8及以上版本 + TypeScript + hooks
      node版本 > 12

注意事项:
  1. 示例项目需要在非安全模式下使用，此时无需传入 Token。您可以在集成开发阶段使用非安全模式进行应用开发与测试。但是出于安全考虑，在应用上线前请联系商务经理改回安全模式。

  示例项目结构:
  1. component 目录中的文件说明如下：
    文件夹                         文件                            说明
    components                                                    组件的文件，包括数据展示，参数设置等组件文件。
    utils                         rtc.ts                          sdk的封装，包括网络监听状态事件和音视频事件处理函数
    utils                         index.ts                        封装post请求，和checkBrowser封装函数
    page                                                          多人通话首页加入房间页面
                                                                  多人通话加入房间后页面及业务逻辑

运行示例源码:
  1. 在SDK和示例代码下载页面或 Demo 体验页面下载需要体验的示例项目或 Demo 源码工程。
  2. 下载web端SDK文件，拷贝NIM_Web_WebRTC2_v4.x.x.js到assets文件夹下
  3. 在config/index.ts 文件中配置 AppKey ，appSecret和baseUrl
  - TypeScript:
      export default {
        appkey: '',
        appSecret: '',
        baseUrl: '',
      };
  4. 如果您使用的是非安全模式，需要在rtc.ts中的join()中把token设为" "，
       public async join() {
        try {
          const {
            avRoomUid,
            avRoomCid,
            avRoomCheckSum,
            avRoomCName,
          } = await this.sendJoinChannelRequest();
          this.uid = avRoomUid;
          this.channelId = avRoomCid;
          // if (this.appSecret) {
          //   this.token = await getToken({uid: this.uid, appkey: this.appkey, appSecret: this.appSecret, channelName: this.channelName})
          // } else {
          //   this.token = ''
          // }
          await this.client.join({
            channelName: avRoomCName,
            uid: this.uid,
            token: avRoomCheckSum,   //如果是非安全模式, token: ''
          });
        }
  5. 运行 npm install 安装依赖
  6. 运行 npm start 跑通项目
  7. 在浏览器打开 https://localhost:8000/#/ 访问项目
  8. 提供扬声器和摄像头即可加入房间

常见问题:
  1. 如遇加入房间失败，请看加入失败的报错信息，检查是否缺少扬声器或摄像头

