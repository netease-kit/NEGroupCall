## 云信多人通话（iOS）

本文主要展示如何集成云信的NERtcSDK，快速实现多人视频通话功能。您可以直接基于我们的Demo修改适配。

### 功能介绍

- 开启/关闭麦克风
- 开启/关闭摄像头
- 切换前后摄像头
- 视频拒绝/挂断
- 设置视频/音频
- 设置美颜
- 观测实时数据

### 环境准备

1. 登录[网易云控制台](https://app.yunxin.163.com/index?clueFrom=nim&from=nim#/)，点击【应用】>【创建】创建自己的App，在【功能管理】中申请开通【音视频通话】功能。
2. 在控制台中【App Key管理】获取App Key。
3. 下载[场景Demo]()，将AppKey.m中的App Key更换为自己的App Key。

### 运行示例项目

**注意：在运行前，请联系商务经理开通非安全模式（因Demo中RTCSDK中的token传空）。**

1. 下载完成场景Demo后，终端进入Podfile所在文件夹，执行`pod install`命令。如未安装Cocoapods，请参考[安装说明](https://guides.cocoapods.org/using/getting-started.html#getting-started)。
2. 执行 `pod install` 完成安装后，双击 `NEGroupCall-iOS.xcworkspace` 通过 Xcode 打开工程。然后打开 `AppKey.h` 文件，填入您的AppKey，和服务器的host地址。。随后运行工程即可。



#### 修改Demo源代码：

Demo跑通之后，可以修改GroupCall/Controller文件夹下的类文件以及GroupCall/View下的文件，去修改多人通话的UI和功能逻辑。

|         文件/文件夹         |                   功能                   |
| :-------------------------: | :--------------------------------------: |
|          AppKey.h           |   配置AppKey、推送证书名称、服务器域名   |
|    NEGroupVideoVC     |               多人通话视频页               |
| NERtcContactsViewController |             音视频设置页             |
|    NEEvaluateVC     |              视频质量反馈页             |
|           Macro            |            appkey设置&宏定义模块             |
|          Service           |             网络请求功能模块             |
|           beauty            | 美颜相关模块  |



#### 具体实现步骤：


##### 步骤1:集成SDK

1. 使用Xcode创建工程，进入/iOS/NEGroupCall-iOS，执行`pod init`，创建Podfile文件。

2. 编辑Podfile文件并执行`pod install`：

   ```objc
   pod 'NERtcSDK', '4.2.112'
   ```


##### 步骤2:添加权限

1. 在`Info.plist`文件中添加相机、麦克风访问权限：

   ```
   Privacy - Camera Usage Description
   Privacy - Microphone Usage Description
   ```

2. 在工程的`Signing&Capabilities`添加`Background Modes`，并勾选`Audio、Airplay、and Picture in Picture`。

##### 步骤3:注册账号后登录：

```objc
+ (void)loginWithMobile:(NSString *)mobile
                smsCode:(NSString *)smsCode
             completion:(NEAccountComplete)completion
{
    NESmsLoginTask *task = [NESmsLoginTask taskWithSubURL:@"/auth/loginBySmsCode"];
    task.req_mobile = mobile;
    task.req_smsCode = smsCode;
    [[NEService shared] runTask:task completion:^(NSDictionary * _Nullable response, id  _Nullable task, NSError * _Nullable error) {
        [self _loginHandleWithResponse:response error:error completion:completion];
    }];
}
```

##### 步骤4:进入视频房间

```objc
- (void)gotoVideoVCWithTask:(NEJoinRoomTask *)task nickname:(NSString *)nickname{
    NEGroupVideoVC *groupVC = [[NEGroupVideoVC alloc] init];
    groupVC.delegate = self;
    groupVC.task = task;
    groupVC.nickname = nickname;
    groupVC.isMicrophoneOpen = self.isMicrophoneOpen;
    groupVC.isCameraOpen = self.isCameraOpen;
    }
```


```










