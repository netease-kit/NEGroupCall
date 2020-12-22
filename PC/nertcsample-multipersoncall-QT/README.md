


功能介绍
---
这个开源示例项目演示了如何基于Qt Widget快速集成网易云信-新一代(G2) 音视频SDK，实现多人视频通话
*  加入/离开通话
*  打开/关闭美颜
*  打开/关闭摄像头
*  打开/关闭麦克风
*  设备切换

前提条件
---

1.  若您已经与专属客户经理取得联系，可直接向他获取Appkey
2.  若您并未与专属客户经理取得联系那么请按后续步骤获取Appkey
3.  首先在[网易云信](https://id.163yun.com/register?h=media&t=media&clueFrom=nim&from=bdjjnim0035&referrer=https://app.yunxin.163.com/?clueFrom=nim&from=bdjjnim0035)注册账号
4.  然后在「应用」一栏中创建您的项目
5.  等待专属客户经理联系您，并向他获取Appkey

**Windows**

下载[Windows端SDK](https://dev.yunxin.163.com/docs/product/%E9%9F%B3%E8%A7%86%E9%A2%91%E9%80%9A%E8%AF%9D2.0/SDK&%E7%A4%BA%E4%BE%8B%E4%BB%A3%E7%A0%81%E4%B8%8B%E8%BD%BD)，"api/", "dll/", "lib/"三个文件夹拷贝到nertc_sdk目录

**Mac**

下载[Mac端SDK](https://dev.yunxin.163.com/docs/product/%E9%9F%B3%E8%A7%86%E9%A2%91%E9%80%9A%E8%AF%9D2.0/SDK&%E7%A4%BA%E4%BE%8B%E4%BB%A3%E7%A0%81%E4%B8%8B%E8%BD%BD),拷贝"NEFundation_Mac.framework", "nertc_sdk_Mac.framework"到/nertc_sdk/mac/目录下

**美颜**

由于本sample美颜的功能是使用相芯SDK实现的，所以您在使用前需要获取相芯的证书，即复制authpack.h文件到/CNamaSDK/auth路径下

环境准备
---



