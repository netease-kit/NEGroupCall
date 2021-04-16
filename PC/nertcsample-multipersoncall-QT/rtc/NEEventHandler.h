#ifndef NEEVENTHANDLER_H
#define NEEVENTHANDLER_H

#include <QObject>
#include <QPointer>

#include "nertc_sdk/api/nertc_base.h"
#include "nertc_sdk/api/nertc_engine_ex.h"

using namespace nertc;

class NERtcEngine;

class NEEventHandler : public QObject, public IRtcEngineEventHandlerEx , public IRtcMediaStatsObserver
{

    Q_OBJECT
public:
    NEEventHandler(NERtcEngine* engine);

    ~NEEventHandler();

    virtual void onUserVideoProfileUpdate(nertc::uid_t uid, NERtcVideoProfileType max_profile) override;

    virtual void onUserAudioMute(nertc::uid_t uid, bool mute) override;

    virtual void onUserVideoMute(nertc::uid_t uid, bool mute) override;

    virtual void onAudioDeviceStateChanged(const char device_id[kNERtcMaxDeviceIDLength],
        NERtcAudioDeviceType device_type,
        NERtcAudioDeviceState device_state) override;

    virtual void onVideoDeviceStateChanged(const char device_id[kNERtcMaxDeviceIDLength],
        NERtcVideoDeviceType device_type,
        NERtcVideoDeviceState device_state) override;

    virtual void onCaptureVideoFrame(void *data,
        NERtcVideoType type,
        uint32_t width,
        uint32_t height,
        uint32_t count,
        uint32_t offset[kNERtcMaxPlaneCount],
        uint32_t stride[kNERtcMaxPlaneCount],
        NERtcVideoRotation rotation) override;

    virtual void onAudioMixingStateChanged(NERtcAudioMixingState state, NERtcAudioMixingErrorCode error_code) override;

    virtual void onAudioMixingTimestampUpdate(uint64_t timestamp_ms) override;

    virtual void onLocalAudioVolumeIndication(int volume) override;

    virtual void onRemoteAudioVolumeIndication(const NERtcAudioVolumeInfo *speakers, unsigned int speaker_number, int total_volume) override;

    virtual void onUserVideoStop(nertc::uid_t uid) override;

    virtual void onUserVideoStart(nertc::uid_t uid, NERtcVideoProfileType max_profile) override;

    virtual void onUserAudioStop(nertc::uid_t uid) override;

    virtual void onUserAudioStart(nertc::uid_t uid) override;

    virtual void onJoinChannel(channel_id_t cid, nertc::uid_t uid, NERtcErrorCode result, uint64_t elapsed) override;

    virtual void onRejoinChannel(channel_id_t cid, nertc::uid_t uid, NERtcErrorCode result, uint64_t elapsed) override;

    virtual void onLeaveChannel(NERtcErrorCode result) override;

    virtual void onUserJoined(nertc::uid_t uid, const char * user_name) override;

    virtual void onUserLeft(nertc::uid_t uid, NERtcSessionLeaveReason reason) override;

    virtual void onDisconnect(NERtcErrorCode reason) override;

    virtual void onError(int error_code, const char* msg) override;

    virtual void onWarning(int warn_code, const char* msg) override;

    virtual void onNetworkQuality(const NERtcNetworkQualityInfo *infos, unsigned int user_count) override;

    virtual void onRtcStats(const NERtcStats &stats) override;

private:
    QPointer<NERtcEngine> m_engine;
};

#endif // NEEVENTHANDLER_H
