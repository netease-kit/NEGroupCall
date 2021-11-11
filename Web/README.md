## 《跑通示例项目》多人音视频 Web
### 《跑通示例项目》文档针对接入阶段的用户，提供示例源码的运行指引，提供快速跑通示例项目Demo的方案，帮助用户快速接入。

### 网易云信音视频通话 2.0 产品为您提供开源的的示例项目，您可以参考本文档快速跑通示例项目，快速在本地运行示例 Demo，体验 NERTC SDK 的实时音视频通话的效果。

**前提条件:**
在开始运行示例项目之前，请确保您已完成以下操作：
- 创建应用并获取App Key。
- 开通音视频通话 2.0 服务。
- 集成 SDK。
- 联系商务经理开通非安全模式。

**开发环境:**
在开始运行示例项目之前，请确保开发环境满足以下要求：
- 开发环境：react16.8及以上版本 + TypeScript + hooks
- node版本 > 12

**注意事项:**
1. 示例项目需要在非安全模式下使用，此时无需传入 Token。您可以在集成开发阶段使用非安全模式进行应用开发与测试。但是出于安全考虑，在应用上线前请联系商务经理改回安全模式。

**示例项目结构:**
- components 组件的文件，包括数据展示，参数设置等组件文件。
- utils
  - `rtc`：sdk的封装，包括web端以及electron版本的具体实现
  - 其它工具函数
- pages
  - join 多人通话首页加入房间页面
  - call 多人通话加入房间后页面及业务逻辑

**运行示例源码:**
1. 在SDK和示例代码下载页面或 Demo 体验页面下载需要体验的示例项目或 Demo 源码工程。
2. 在 `config/index.ts` 文件中配置 `appKey`、`appSecret`和`baseUrl`
  ```js
    export default {
      appkey: '',
      appSecret: '',
      baseUrl: '',
    };
  ```
3. 如果您使用的是非安全模式
  - web端 需要在`src/utils/rtc/webRtc.ts`中的`join()`中把`token`设为 `""`
  - electron 需要在`src/utils/rtc/electronRtc`中的`join()`中把`token`设为 `""`
4. 安装依赖
  ```bash
  $ npm install
  ```
5. 运行项目
  - web端
    ```bash
    $ npm start
    ```
  - electron
    启动两个进程，一个进程运行
    ```bash
    $ npm run dev:electron
    ```
    另一个进程运行
    ```bash
    $ npm run electron:dev
    ```
6. web端在浏览器打开 https://localhost:8000/#/ 访问项目，electron会自动打开app
7. 提供扬声器和摄像头即可加入房间

**常见问题:**
1. 如遇加入房间失败，请看加入失败的报错信息，检查是否缺少扬声器或摄像头

