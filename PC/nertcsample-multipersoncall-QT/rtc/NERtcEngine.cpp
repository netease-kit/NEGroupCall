#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>
#include <QWindow>

#include "NEAudioMixer.h"
#include "NEDeviceManager.h"
#include "NEEventHandler.h"
#include "NERtcEngine.h"

#ifdef USE_BEAUTY
#include "NEBeautyManager.h"
#endif

using namespace nertc;

NERtcEngine::NERtcEngine(QObject* parent)
    : QObject(parent), m_rtcEngine(Q_NULLPTR), m_connectState(kNERtcConnectionStateDisconnected)
    , m_bBeauty(false), m_bInit(false) {
}

NERtcEngine::~NERtcEngine() {
    release();
}

bool NERtcEngine::init(const char* app_key, const char* log_dir_path) {
    //初始化事件回调
    m_rtcEngineHandler = std::make_shared<NEEventHandler>(this);

    //创建RTC引擎
    m_rtcEngine = dynamic_cast<IRtcEngineEx*>(createNERtcEngine());

    NERtcEngineContext rtcEngineContext;
    //LOG(INFO) << "app_key:" << app_key;
    rtcEngineContext.app_key = app_key;
    rtcEngineContext.log_dir_path = log_dir_path;
#ifdef QT_NO_DEBUG
    rtcEngineContext.log_level = kNERtcLogLevelWarning;
#else
    rtcEngineContext.log_level = kNERtcLogLevelInfo;
#endif

    rtcEngineContext.log_file_max_size_KBytes = 1024 * 10;
    rtcEngineContext.event_handler = m_rtcEngineHandler.get();
    rtcEngineContext.video_use_exnternal_render = false;

    //初始化RTC引擎
    if (kNERtcNoError != m_rtcEngine->initialize(rtcEngineContext)) {
        qDebug("ERROR: Failed to initialize NERtc Engine\n");
        return false;
    }

    //注册统计信息观测器
    m_rtcEngine->setStatsObserver(m_rtcEngineHandler.get());
    //初始化混音控制器
    m_audioMixer = std::make_shared<NEAudioMixer>(this);
    //初始化设备管理器
    m_deviceManager = std::make_shared<NEDeviceManager>(this);

#ifdef USE_BEAUTY
    //初始化美颜管理器
    m_beautyManager = std::make_shared<NEBeautyManager>(this);
#endif

    m_bInit = true;

    return true;
}

void NERtcEngine::release() {
    if (m_rtcEngine) {
        //同步退出
        m_rtcEngine->release(true);
        destroyNERtcEngine((void*&)m_rtcEngine);
        m_rtcEngine = Q_NULLPTR;

        m_bInit = false;
    }
}

bool NERtcEngine::getIsInit() {
    return m_bInit;
}

int NERtcEngine::joinChannel(const QString& token, const QString& roomid, const QString& uid) {
    int ret = kNERtcNoError;

    m_rtcEngine->enableLocalAudio(false);
    m_rtcEngine->enableLocalVideo(false);

    //加入频道
    ret = m_rtcEngine->joinChannel(token.toUtf8().data(), roomid.toUtf8().data(), uid.toULongLong());

    if (ret == kNERtcNoError) {
        emit sigJoiningChannel();
        qDebug() << "[INFO] join channel successfully!";
    } else {
        qDebug("[ERROR] can't join channel, ERROR CODE: %d", ret);
    }

    qDebug("[INFO] current connection state: %d", m_rtcEngine->getConnectionState());
    return ret;
}

int NERtcEngine::leaveChannel() {
    int ret = kNERtcNoError;
    qDebug("[INFO] current connection state: %d", m_rtcEngine->getConnectionState());

    if (m_rtcEngine) {
        ret = m_rtcEngine->enableLocalAudio(false);
        ret = m_rtcEngine->enableLocalVideo(false);
        ret = m_rtcEngine->leaveChannel();

        if (kNERtcNoError == ret) {
            Q_EMIT sigJoiningChannel();
        } else {
            qDebug("[ERROR] Can't leave channel, ERROR CODE: %d", ret);
        }
    }

    return ret;
}

void NERtcEngine::setCurrentVideoProfile(unsigned int profile) {
    NERtcVideoProfileType current_video_profile = (NERtcVideoProfileType)profile;
    NERtcVideoConfig videoConfig;
    videoConfig.max_profile = current_video_profile;
    videoConfig.crop_mode_ = kNERtcVideoCropModeDefault;
    videoConfig.width = 0;
    videoConfig.height = 0;
    m_rtcEngine->setVideoConfig(videoConfig);
}

void NERtcEngine::setCustomVideoProfile(unsigned int profile, int framerate)
{
    NERtcVideoConfig videoConfig;
    videoConfig.max_profile =(NERtcVideoProfileType)profile;
    videoConfig.framerate = (NERtcVideoFramerateType)framerate;
    videoConfig.crop_mode_ = kNERtcVideoCropModeDefault;
    videoConfig.width = 0;
    videoConfig.height = 0;
    m_rtcEngine->setVideoConfig(videoConfig);
}

void NERtcEngine::setCurrentAudioProfile(unsigned int profile, unsigned int sence)
{
     NERtcAudioProfileType audioProfile = (NERtcAudioProfileType)profile;
     NERtcAudioScenarioType scenarioType = (NERtcAudioScenarioType)sence;
     m_rtcEngine->setAudioProfile(audioProfile, scenarioType);
}

void NERtcEngine::enableBeauty(bool enabled) {

#ifdef USE_BEAUTY
    m_bBeauty = enabled;

    m_beautyManager->initBeauty();

    if (m_bBeauty) {
        connect(this, &NERtcEngine::sigRenderFrame, m_beautyManager.get(), &NEBeautyManager::onRenderFrame, Qt::BlockingQueuedConnection);
    } else {
        disconnect(this, &NERtcEngine::sigRenderFrame, 0, 0);
    }
#endif
}

bool NERtcEngine::getBeautyEnable() {
    return m_bBeauty;
}

int NERtcEngine::enableVideo(bool enabled) {
    return m_rtcEngine->enableLocalVideo(enabled);
}

int NERtcEngine::enableAudio(bool enabled) {
    return m_rtcEngine->enableLocalAudio(enabled);
}

int NERtcEngine::muteLocalVideoStream(bool mute) {
    return m_rtcEngine->muteLocalVideoStream(mute);
}

int NERtcEngine::setupLocalVideo(void* hwnd) {
    NERtcVideoCanvas canvas;
    canvas.cb = Q_NULLPTR;
    canvas.user_data = Q_NULLPTR;
    canvas.window = hwnd;
    canvas.scaling_mode = kNERtcVideoScaleCropFill;

    int ret = m_rtcEngine->setupLocalVideoCanvas(&canvas);
    if (ret) {
        qDebug("ERROR: Can not setup local video canvas! ERROR CODE: %d", ret);
    }

    return ret;
}

int NERtcEngine::setupRemoteVideo(quint64 uid, void* hwnd) {
    NERtcVideoCanvas canvas;
    canvas.cb = Q_NULLPTR;
    canvas.user_data = Q_NULLPTR;
    canvas.window = hwnd;
    canvas.scaling_mode = kNERtcVideoScaleFit;

    int ret = m_rtcEngine->setupRemoteVideoCanvas(uid, &canvas);
    if (ret) {
        qDebug("[ERROR] Can not setup remote video canvas! ERROR CODE: %d", ret);
    }

    int ret_temp = m_rtcEngine->subscribeRemoteVideoStream(uid, kNERtcRemoteVideoStreamTypeHigh, true);
    if (ret_temp) {
        qDebug("[ERROR] can not subscribe remote video stream! ERROR CODE: %d", ret_temp);
    }

    ret_temp = m_rtcEngine->subscribeRemoteAudioStream(uid, true);
    if (ret_temp) {
        qDebug("[ERROR] can not subscribe remote audio stream! ERROR CODE: %d", ret_temp);
    }
    return ret;
}

void NERtcEngine::setParameter(const NRTCParameter& rtc_parameter) {
    rtc_parameter_ = rtc_parameter;
    QJsonObject values;

    values[kNERtcKeyAudioProcessingAECEnable] = rtc_parameter_.audio_aec_enable;
    values[kNERtcKeyAudioProcessingAGCEnable] = rtc_parameter_.audio_agc_enable;
    values[kNERtcKeyAudioProcessingNSEnable] = rtc_parameter_.audio_ns_enable;
    values[kNERtcKeyAudioProcessingExternalAudioMixEnable] = rtc_parameter_.audio_external_mix_enable;
    values[kNERtcKeyAudioProcessingEarphone] = rtc_parameter_.audio_earphone;
    values[kNERtcKeyRecordHostEnabled] = rtc_parameter_.record_host_enabled;
    values[kNERtcKeyRecordAudioEnabled] = rtc_parameter_.record_audio_enabled;
    values[kNERtcKeyRecordVideoEnabled] = rtc_parameter_.record_video_enabled;
    values[kNERtcKeyRecordType] = rtc_parameter_.record_type;
    values[kNERtcKeyAutoSubscribeAudio] = rtc_parameter_.auto_subscribe_audio;
    values[kNERtcKeyPublishSelfStreamEnabled] = rtc_parameter_.publish_self_stream_enabled;
    values[kNERtcKeyLogLevel] = rtc_parameter_.log_level;

    QString parameters = QString(QJsonDocument(values).toJson());
    int ret = m_rtcEngine->setParameters(parameters.toUtf8().data());
    if (ret) {
        qDebug("[ERROR] Cannot set parameters ERROR CODE: %d", ret);
    }
}

void NERtcEngine::startRemoteVideo(nertc::uid_t uid) {
    m_rtcEngine->subscribeRemoteVideoStream(uid, kNERtcRemoteVideoStreamTypeHigh, true);
}

void NERtcEngine::stopRemoteVideo(nertc::uid_t uid) {
    m_rtcEngine->subscribeRemoteVideoStream(uid, kNERtcRemoteVideoStreamTypeHigh, false);
}

void NERtcEngine::startRemoteAudio(nertc::uid_t uid) {
    m_rtcEngine->subscribeRemoteAudioStream(uid, true);
}

void NERtcEngine::stopRemoteAudio(nertc::uid_t uid) {
    m_rtcEngine->subscribeRemoteAudioStream(uid, false);
}

std::shared_ptr<NEAudioMixer> NERtcEngine::getAudioMixer() {
    return m_audioMixer;
}

std::shared_ptr<NEDeviceManager> NERtcEngine::getDeviceManager() {
    return m_deviceManager;
}
