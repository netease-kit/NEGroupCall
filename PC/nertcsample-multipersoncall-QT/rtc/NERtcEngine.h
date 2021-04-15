#ifndef NRTC_ENGINE_H
#define NRTC_ENGINE_H

#include <QObject>

#include "nertc_sdk/api/nertc_audio_device_manager.h"
#include "nertc_sdk/api/nertc_base.h"
#include "nertc_sdk/api/nertc_engine_ex.h"
#include "nertc_sdk/api/nertc_video_device_manager.h"

#define APP_KEY  //输入你的appkey

class NEAudioMixer;
class NEDeviceManager;
class NEEventHandler;
class NEBeautyManager;

struct NRTCParameter {
    bool initialized;
    bool audio_aec_enable;
    bool audio_agc_enable;
    bool audio_ns_enable;
    bool audio_external_mix_enable;
    bool audio_earphone;
    bool record_host_enabled;
    bool record_audio_enabled;
    bool record_video_enabled;
    nertc::NERtcRecordType record_type;
    bool auto_start_local_audio;
    bool auto_start_local_video;
    bool auto_subscribe_audio;
    bool publish_self_stream_enabled;
    nertc::NERtcLogLevel log_level;
    bool video_smooth_enabled;
    bool video_watermark_enabled;
    bool video_filter_enabled;
    bool audio_filter_enabled;

    NRTCParameter() {
        initialized = false;
        audio_aec_enable = true;
        audio_agc_enable = true;
        audio_ns_enable = true;
        audio_external_mix_enable = false;
        audio_earphone = false;
        record_host_enabled = true;
        record_audio_enabled = true;
        record_video_enabled = true;
        record_type = nertc::kNERtcRecordTypeAll;
        auto_start_local_audio = true;
        auto_start_local_video = true;
        auto_subscribe_audio = true;
        publish_self_stream_enabled = false;
        log_level = nertc::kNERtcLogLevelInfo;
        video_smooth_enabled = false;
        video_watermark_enabled = false;
        video_filter_enabled = false;
        audio_filter_enabled = false;
    }
};

class NERtcEngine : public QObject {
    Q_OBJECT
public:
    explicit NERtcEngine(QObject* parent = nullptr);
    ~NERtcEngine();

    //初始化Rtc
    bool init(const char* app_key, const char* log_dir_path);
    //释放Rtc
    void release();

    // rtc是否初始化
    bool getIsInit();

    //加入频道
    int joinChannel(const QString& token, const QString& roomid, const QString& uid, unsigned int video_resolution = 2);
    //离开频道
    int leaveChannel();

    //设置视频分辨率
    void setCurrentVideoProfile(unsigned int index);

    //启用/关闭美颜
    void enableBeauty(bool enabled);

    //获取是否启用美颜
    bool getBeautyEnable();

    //启用/关闭本地视频
    int enableVideo(bool enabled);
    //启用/关闭本地音频
    int enableAudio(bool enabled);

    //禁用视频流，注意只有调用此接口，远端才能收到onUserVideoMute回调
    int muteLocalVideoStream(bool mute);

    //设置本地视频渲染窗口
    int setupLocalVideo(void* hwnd);
    //设置远端视频渲染窗口
    int setupRemoteVideo(quint64 uid, void* hwnd);

    //开始播放远端视频流
    void startRemoteVideo(nertc::uid_t uid);
    //停止播放远端视频流
    void stopRemoteVideo(nertc::uid_t uid);

    //开始播放远端音频流
    void startRemoteAudio(nertc::uid_t uid);
    //停止播放远端音频流
    void stopRemoteAudio(nertc::uid_t uid);

    //其它定制化参数设置
    void setParameter(const NRTCParameter& rtc_parameter);

    //获取rtc引擎
    nertc::IRtcEngineEx* GetRtcEngine() { return m_rtcEngine; }
    //获取混音控制器
    std::shared_ptr<NEAudioMixer> getAudioMixer();
    //获取设备管理器
    std::shared_ptr<NEDeviceManager> getDeviceManager();

Q_SIGNALS:
    //自己加入频道成功
    void sigJoinChannelSuccess();

    //自己加入频道失败
    void sigJoinChannelFail(const QString& reson);

    //自己正在加入频道
    void sigJoiningChannel();

    //自己正在离开频道
    void sigLeavingChannel();

    //账号在其他设备登录
    void sigForceOffline();

    //用户加入频道
    void sigUserJoined(quint64 uid, const QString& name);

    //用户离开频道
    void sigUserLeft(quint64 uid);

    //视频停止
    void videoStopped(unsigned long long uid);

    //视频开始
    void videoStart(unsigned long long uid, int max_profile);

    //断开
    void sigDisconnected(int code);

    //美颜渲染
    void sigRenderFrame(int ntype, void* data, unsigned int width, unsigned int height, int frame_id);

    //用户启用/禁用视频
    void sigUserVideoMute(quint64 uid, bool mute);

    //用户启用/禁用音频
    void sigUserAudioMute(quint64 uid, bool mute);

private:
    // 网易云通信 SDK 引擎
    nertc::IRtcEngineEx* m_rtcEngine;

    // 当前连接状态
    nertc::NERtcConnectionStateType m_connectState;

    // 混音控制器
    std::shared_ptr<NEAudioMixer> m_audioMixer;

    // 设备管理器
    std::shared_ptr<NEDeviceManager> m_deviceManager;

    // 美颜管理器
    std::shared_ptr<NEBeautyManager> m_beautyManager;

    // 事件处理器
    std::shared_ptr<NEEventHandler> m_rtcEngineHandler;

    // 当前视频分辨率
    nertc::NERtcVideoProfileType current_video_profile;

    // 实验性参数
    NRTCParameter rtc_parameter_;

    // 是否启用美颜
    std::atomic<bool> m_bBeauty;

    bool m_bInit;
};

#endif  // NRTC_ENGINE_H
