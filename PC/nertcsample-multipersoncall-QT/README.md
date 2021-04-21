


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

环境准备
---
Windows: Qt5.14.0及以上版本 + VS2017/VS2019

MacOS: Qt5.14.0及以上版本+ XCode

运行示例源码
---

 1. 下载SDK
    - 下载[Windows端SDK](https://yx-web-nosdn.netease.im/package/1618217725/NERtc_Windows_SDK_v4.1.1.zip?download=NERtc_Windows_SDK_v4.1.1.zip)，"api/", "dll/", "lib/"三个文件夹拷贝到nertc_sdk目录
    - 下载[Mac端SDK](https://yx-web-nosdn.netease.im/package/1616651545/NERTC_Mac_SDK_v4.0.3.zip?download=NERTC_Mac_SDK_v4.0.3.zip),拷贝"NEFundation_Mac.framework", "nertc_sdk_Mac.framework"到/nertc_sdk/mac/目录下
 2. 双击NERtcSample-MultipersonCall.pro打开工程
 3. 在NERtcEngine.h中输入appkey
 4. 如果需要体验应用美颜效果，则需要完成以下步骤：
    - 在 NERtcSample-MultipersonCall.pro 文件中打开 USE_BEAUTY 宏（不需要则注释该宏）
    - 获取相芯科技的美颜证书，并拷贝到/CNamaSDK/auth目录
    - 下载相芯科技美颜SDK
     macOS: 拷贝到CNamaSDK/mac目录
     windows: 拷贝到CNamaSDK/api/, CNamaSDK/dll/, CNamaSDK/lib/
    - 下载相芯科技资源文件face_beautification_v2.bundle，并拷贝到CNamaSDK/assert目录
 5. 如果您当前使用非安全模式，则需要在NERtcSample-MultipersonCall.pro文件中打开UNSAFE_APPKEY宏（安全模式则注释该宏）
 6. windows下执行build_win32.bat脚本，将库拷贝至bin目录
 7. 在Qt creator中点击编译、运行程序
