## 云信多人视频通话（Android）

本文主要展示如何集成云信的多人通话SDK以及NERTC SDK，快速实现多人视频通话功能。您可以直接基于我们的Demo修改适配，也可以使用我们提供的NERTC SDK，实现自定义UI。

### <span id="功能介绍">功能介绍</span>

- 视频呼叫/接听
- 开启/关闭麦克风
- 开启/关闭摄像头
- 切换前后摄像头
- 视频拒绝/挂断

### <span id="环境准备">环境准备</span>

1. 登录[网易云控制台](https://app.yunxin.163.com/index?clueFrom=nim&from=nim#/)，点击【应用】>【创建】创建自己的App，在【功能管理】中申请开通【信令】和【音视频通话2.0】功能。
2. 在控制台中【appkey管理】获取appkey。
3. 下载[场景Demo](https://github.com/netease-kit/NEGroupCall/tree/master/Android)，将config文件夹中的appkey更换为自己的appkey。
4. 替换config文件夹中的BASE_URL 为自己的业务BASE_URL，实现验证码等登陆功能。

### <span id="运行示例项目">运行示例项目</span>




#### 修改Demo源代码：

Demo跑通之后，可以修改biz-video-group文件夹下的代码，复用**音视频参数设置页**以及**视频通话页**。

|         文件/文件夹         |                   功能                   |
| :------------------------- | :-------------------------------------- |
| VideoRoomSetActivity |             **音视频参数设置页**             |
|    VideoMeetingRoomActivity   |              **视频通话页**              |

#### 基于NERtc实现自定义UI：

具体步骤如下：

##### 步骤1:集成SDK

1. 使用Android Studio创建工程。

2. 通过 Gradle 集成RTC SDK

 ```
   dependencies {
    implementation fileTree(dir: 'libs', include: '*.jar')
    implementation "com.netease.yunxin:nertc:4.0.1"
    implementation "com.netease.nimlib:basesdk:8.3.0"
    implementation "com.netease:gslb:1.0.0"
   }
```

3. 防止代码混淆，在 proguard-rules.pro 文件中，为 nertc sdk 添加 -keep 类的配置，这样可以防止混淆 nertc sdk 公共类名称:

   ```
   -keep class com.netease.lava.** {*;}
   -keep class com.netease.yunxin.** {*;}
   ```

##### 步骤2:添加权限

1. 打开 app/src/main/AndroidManifest.xml 文件，添加必要的设备权限。例如：

```
<uses-permission android:name="android.permission.INTERNET"/>
 <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
 <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
 <uses-permission android:name="android.permission.CHANGE_WIFI_STATE"/>
 <uses-permission android:name="android.permission.WAKE_LOCK"/>
 <uses-permission android:name="android.permission.CAMERA"/>
 <uses-permission android:name="android.permission.RECORD_AUDIO"/>
 <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
 <uses-permission android:name="android.permission.BLUETOOTH"/>
 <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
 <uses-permission android:name="android.permission.BROADCAST_STICKY"/>
 <uses-permission android:name="android.permission.READ_PHONE_STATE"/>
 <uses-feature android:name="android.hardware.camera"/>
 <uses-feature android:name="android.hardware.camera.autofocus"/>
```
2. 点击 Sync Project With Gradle Files , 重新同步 Android 项目文件。

##### 步骤3:初始化NERtc：

```
  neRtcEx.init(getApplicationContext(), appKey, neRtcCallback, null);
  //设置相关参数
   NERtcVideoConfig neRtcVideoConfig = new NERtcVideoConfig();
   neRtcEx.setLocalVideoConfig(neRtcVideoConfig);
```

##### 步骤4:加入RTC房间

```
   NERtcEx.getInstance().joinChannel(token, channelName, uid);
```
##### 步骤5:参考VideoMeetingRoomActivity实现自己的UI

### RTC相关回调NERtcCallback API

####**NERtcVideoCall**组件的 **API接口**列表如下：

| **接口名**      | **接口描述**             |
| :---------------- | :---------------------------------------- 
| onJoinChannel             | 加入频道                                 |
| onLeaveChannel           | 离开频道                                 |
| onUserJoined           | 用户加入频道                                 |
| onUserLeave           | 用户离开频道                                 |
| onUserAudioStart           | 用户开启麦克风                                     |
| onUserAudioStop   | 用户关闭麦克风                             |
| onUserVideoStart  | 用户打开摄像头                         |
| onUserVideoStop     | 用户关闭摄像头                          |
| onDisconnect       | 断开RTC连接                        |



