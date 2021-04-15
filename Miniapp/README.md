# App-GroupCall-Miniapp

多人通话小程序

## 环境要求
- 微信 App iOS 最低版本要求：8.0.0
- 微信 App Android 最低版本要求：8.0.0
- 小程序基础库最低版本要求：2.10.0
- 由于微信开发者工具不支持原生组件（即 <live-pusher> 和 <live-player> 标签），需要在真机上进行运行体验。

## 操作步骤
### step1. 创建应用并获取appkey
在网易云信控制台中创建应用，查看该应用的 App Key。
[单击](https://doc.yunxin.163.com/docs/jcyOTA0ODM/Dg1MjAwNzA?platformId=50136)此处快速跳转。

### step2. 开通音视频通话2.0服务
若您之前从未开通过任何网易云信的产品服务，请先在官网首页通过 QQ、在线消息或电话等方式联系商务经理，一对一沟通您的具体需求。
[单击](https://doc.yunxin.163.com/docs/jcyOTA0ODM/Dg1MjAwNzA?platformId=50136)此处查看详情。

### step3. 开通小程序类目与推拉流标签权限
出于政策和合规的考虑，微信暂未放开所有小程序对实时音视频功能（即 <live-pusher> 和 <live-player> 标签）的支持：

- 小程序推拉流标签不支持个人小程序，只支持企业类小程序。
- 小程序推拉流标签使用权限暂时只开放给有限 [类目](https://developers.weixin.qq.com/miniprogram/dev/component/live-pusher.html)。
- 符合类目要求的小程序，需要在【[微信公众平台](https://mp.weixin.qq.com/)】>【开发】>【接口设置】中自助开通该组件权限。

### step4. 编译运行
- 打开微信开发者工具，选择【小程序】，单击新建图标，选择【导入项目】。
- 填写您微信小程序的AppID，单击【导入】。
- 找到 `/config/index.js` 中的 `appkey` 字段，填入您云信应用的appkey。
- 找到微信开发者工具中的 【详情】 > 【本地设置】 > 【不校验合法域名、web-view（业务域名）、TLS版本以及HTTPS证书】，勾选上该选项。
- 单击【真机调试】，通过手机微信扫描二维码即可进入小程序。
