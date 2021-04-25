#ifndef NEROOMLIVECONFIG_H
#define NEROOMLIVECONFIG_H

#include <QObject>

enum NEVideoFramerateType {
    kNERtcVideoFramerateFpsDefault = 0, /**< 默认帧率 */
    kNERtcVideoFramerateFps_7 = 7,      /**< 7帧每秒 */
    kNERtcVideoFramerateFps_10 = 10,    /**< 10帧每秒 */
    kNERtcVideoFramerateFps_15 = 15,    /**< 15帧每秒 */
    kNERtcVideoFramerateFps_24 = 24,    /**< 24帧每秒 */
    kNERtcVideoFramerateFps_30 = 30,    /**< 30帧每秒 */
};

enum NEVideoProfileType {
    kNEVideoProfileLowest = 0,   /**< 160x90/120, 15fps */
    kNEVideoProfileLow = 1,      /**< 320x180/240, 15fps */
    kNEVideoProfileStandard = 2, /**< 640x360/480, 30fps */
    kNEVideoProfileHD720P = 3,   /**< 1280x720, 30fps */
    kNEVideoProfileHD1080P = 4,  /**< 1920x1080, 30fps */
};

enum NEAudioScenarioType {
    kNEAudioScenarioSpeech = 1, /** 1: 语音场景 */
    kNEAudioScenarioMusic = 2,  /** 2: 音乐场景 */
};

enum NEAudioProfileType {
    kNEAudioProfileStandard = 1,            /**< 1: 普通质量的音频编码，16000Hz，20Kbps */
    kNEAudioProfileStandardExtend = 2,      /**< 2: 普通质量的音频编码，16000Hz，32Kbps */
    kNEAudioProfileMiddleQuality = 3,       /**< 3: 中等质量的音频编码，48000Hz，32Kbps */
    kNEAudioProfileMiddleQualityStereo = 4, /**< 4: 中等质量的立体声编码，48000Hz * 2，64Kbps  */
    kNEAudioProfileHighQuality = 5,         /**< 5: 高质量的音频编码，48000Hz，64Kbps  */
    kNEAudioProfileHighQualityStereo = 6,   /**< 6: 高质量的立体声编码，48000Hz * 2，128Kbps  */
};

struct NERoomProfile {
    NEVideoFramerateType framerate = kNERtcVideoFramerateFps_30;
    NEVideoProfileType videoProfile = kNEVideoProfileHD720P;
    NEAudioProfileType audioProfile = kNEAudioProfileHighQualityStereo;
    NEAudioScenarioType audioSence = kNEAudioScenarioMusic;
};

struct NERoomInfo {
    QString avRoomCName;
    QString avRoomCid;
    QString avRoomUid;
    QString avRoomCheckSum;
    qint64 createTime;
    qint64 duration;
    QString roomKey;
    QString meetingUniqueId;
    QString mpRoomId;
    QString requestId;
    QString costTime;
    QString selfnickName;
    bool isOpenCamera = false;
    bool isOpenMic = false;
};

struct NELiveUser {
    QString uid;
    QString nickname;
};

class NERoomLiveConfig {
public:
    static NERoomLiveConfig& instance() {
        static NERoomLiveConfig conf;

        return conf;
    }

    //设置房间信息
    void setRoomInfo(const NERoomInfo& info);
    //获取房间信息
    NERoomInfo getRoomInfo() const;

    void setRoomProfile(const NERoomProfile& profile);
    NERoomProfile getRoomProfile() const;

    void appendLiveUser(const NELiveUser& user);
    void deleteLiveUser(const QString& uid);
    void clearLiveUser();

    int getRoomUserCount();

private:
    NERoomLiveConfig();
    ~NERoomLiveConfig();

private:
    NERoomInfo m_roomInfo;
    NERoomProfile m_roomProfile;
    QList<NELiveUser> userList;
};

#endif  // NEROOMLIVECONFIG_H
