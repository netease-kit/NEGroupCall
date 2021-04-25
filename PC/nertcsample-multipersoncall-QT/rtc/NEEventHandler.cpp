#include <QDebug>

#include "NEEventHandler.h"
#include "NERtcEngine.h"
#include "utils/macxhelper.h"
#include "include/base_type_defines.h"

NEEventHandler::NEEventHandler(NERtcEngine* engine) : m_engine(engine) {

}

NEEventHandler::~NEEventHandler() {

}

void NEEventHandler::onUserVideoProfileUpdate(nertc::uid_t uid, NERtcVideoProfileType max_profile) {}

void NEEventHandler::onUserAudioMute(nertc::uid_t uid, bool mute) {
    if (m_engine.isNull()) {
        return;
    }

    Q_EMIT m_engine->sigUserAudioMute(uid, mute);
}

void NEEventHandler::onUserVideoMute(nertc::uid_t uid, bool mute) {
    if (m_engine.isNull()) {
        return;
    }

    Q_EMIT m_engine->sigUserVideoMute(uid, mute);
}

void NEEventHandler::onAudioDeviceStateChanged(const char device_id[kNERtcMaxDeviceIDLength],
                                               NERtcAudioDeviceType device_type,
                                               NERtcAudioDeviceState device_state) {}

void NEEventHandler::onVideoDeviceStateChanged(const char device_id[kNERtcMaxDeviceIDLength],
                                               NERtcVideoDeviceType device_type,
                                               NERtcVideoDeviceState device_state) {
    //可根据此回调，当视频设备插入或者移除时，在UI层做出提示
}

void NEEventHandler::onCaptureVideoFrame(void* data,
                                         NERtcVideoType type,
                                         uint32_t width,
                                         uint32_t height,
                                         uint32_t count,
                                         uint32_t offset[kNERtcMaxPlaneCount],
                                         uint32_t stride[kNERtcMaxPlaneCount],
                                         NERtcVideoRotation rotation) {
#ifndef USE_BEAUTY
    return;
#endif

    //可根据此回调，进行美颜等图像处理
    if (m_engine.isNull()) {
        return;
    }

    if (m_engine->getBeautyEnable()) {
#ifdef Q_OS_WIN
        Q_EMIT m_engine->sigRenderFrame(type, data, width, height, 0);
#else
        if (type == kNERtcVideoTypeCVPixelBuffer) {
            void* buf = nullptr;
            int w = 0;
            int h = 0;
            Macxhelper::getCVPixelbufferInfo(data, buf, w, h);

            //LOG(INFO) << "getCVPixelbufferInfo w: " << w;

            Q_EMIT m_engine->sigRenderFrame(type, buf, w, h, 0);
        }
#endif
    }
}

void NEEventHandler::onAudioMixingStateChanged(NERtcAudioMixingState state, NERtcAudioMixingErrorCode error_code) {}

void NEEventHandler::onAudioMixingTimestampUpdate(uint64_t timestamp_ms) {
    //可根据此回调，展示混音音乐的播放进度
}

void NEEventHandler::onLocalAudioVolumeIndication(int volume) {
    //可根据此回调，实时显示本端的音量大小
}

void NEEventHandler::onRemoteAudioVolumeIndication(const NERtcAudioVolumeInfo* speakers, unsigned int speaker_number, int total_volume) {
    //可根据此回调，实时显示远端用户的音量大小
}

void NEEventHandler::onUserVideoStop(nertc::uid_t uid) {
    Q_EMIT m_engine->sigUserVideoMute(uid, true);
}

void NEEventHandler::onUserVideoStart(nertc::uid_t uid, NERtcVideoProfileType max_profile) {
    Q_EMIT m_engine->sigUserVideoMute(uid, false);
}

void NEEventHandler::onUserAudioStop(nertc::uid_t uid) {
    Q_EMIT m_engine->sigUserAudioMute(uid, true);
}

void NEEventHandler::onUserAudioStart(nertc::uid_t uid) {
    m_engine->startRemoteAudio(uid);
    Q_EMIT m_engine->sigUserAudioMute(uid, false);
}

void NEEventHandler::onJoinChannel(nertc::channel_id_t cid, nertc::uid_t uid, NERtcErrorCode result, uint64_t elapsed) {
    if (m_engine.isNull()) {
        return;
    }

    if (result == kNERtcNoError) {
        Q_EMIT m_engine->sigJoinChannelSuccess();
    } else {
        Q_EMIT m_engine->sigJoinChannelFail(QString::number(result));
    }
}

void NEEventHandler::onRejoinChannel(nertc::channel_id_t cid, nertc::uid_t uid, NERtcErrorCode result, uint64_t elapsed) {

}

void NEEventHandler::onLeaveChannel(NERtcErrorCode result) {
    if (m_engine.isNull()) {
        return;
    }

    if (result == kNERtcErrChannelKicked) {
        Q_EMIT m_engine->sigForceOffline();
    } else {
        Q_EMIT m_engine->sigLeavingChannel();
    }
}

void NEEventHandler::onUserJoined(nertc::uid_t uid, const char* user_name) {
    if (m_engine.isNull()) {
        return;
    }

    Q_EMIT m_engine->sigUserJoined(uid, user_name);
}

void NEEventHandler::onUserLeft(nertc::uid_t uid, NERtcSessionLeaveReason reason) {
    if (m_engine.isNull()) {
        return;
    }

    Q_EMIT m_engine->sigUserLeft(uid);
}

void NEEventHandler::onDisconnect(NERtcErrorCode reason) {
    if (m_engine.isNull()) {
        return;
    }

    //可根据此回调，在ui界面展示断开连接
    Q_EMIT m_engine->sigDisconnected(reason);
}

void NEEventHandler::onError(int error_code, const char* msg) {
    //可根据此回调，在ui界面展示相应错误提示，或者进行日志打点。
}

void NEEventHandler::onWarning(int warn_code, const char* msg) {
    //可根据此回调，在ui界面展示相应警告提示，或者进行日志打点。
}

void NEEventHandler::onNetworkQuality(const NERtcNetworkQualityInfo *infos, unsigned int user_count) {
    //可根据此回调，在ui界面展示用户网络质量

    for (unsigned int i = 0; i < user_count; i++) {
        Q_EMIT m_engine->sigNetworkQuality(infos[i].uid, infos[i].tx_quality, infos[i].rx_quality);
    }
}

void NEEventHandler::onRtcStats(const NERtcStats &stats) {
   NERoomStats stats_;
   stats_.up_rtt = stats.up_rtt;
   stats_.down_rtt = stats.down_rtt;
   stats_.cpu_app_usage = stats.cpu_app_usage;
   stats_.cpu_total_usage = stats.cpu_total_usage;
   stats_.rx_audio_kbitrate = stats.rx_audio_kbitrate;
   stats_.rx_video_kbitrate = stats.rx_video_kbitrate;
   stats_.tx_audio_kbitrate = stats.tx_audio_kbitrate;
   stats_.tx_video_kbitrate = stats.tx_video_kbitrate;
   stats_.rx_audio_packet_loss_rate = stats.rx_audio_packet_loss_rate;
   stats_.rx_video_packet_loss_rate = stats.rx_video_packet_loss_rate;
   stats_.tx_audio_packet_loss_rate = stats.tx_audio_packet_loss_rate;
   stats_.tx_video_packet_loss_rate = stats.tx_video_packet_loss_rate;

   Q_EMIT m_engine->sigRtcStats(stats_);
}
