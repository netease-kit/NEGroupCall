#ifndef NEROOMLIVECONFIG_H
#define NEROOMLIVECONFIG_H

#include <QObject>

struct NERoomInfo
{
    QString avRoomCName;
    QString avRoomCid;
    QString avRoomUid;
    QString avRoomCheckSum;
    qint64 createTime;
    qint64 duration;
    QString roomKey;
    QString meetingUniqueId;
    QString mpRoomId;
    QString nrtcAppKey;
    QString requestId;
    QString costTime;
    QString selfnickName;
};

struct NELiveUser
{
    QString uid;
    QString nickname;
};

class NERoomLiveConfig
{
public:
    static NERoomLiveConfig &instance()
    {
        static NERoomLiveConfig conf;

        return conf;
    }

    //设置房间信息
    void setRoomInfo(const NERoomInfo& info);
    //获取房间信息
    NERoomInfo getRoomInfo() const;

    void appendLiveUser(const NELiveUser& user);
    void deleteLiveUser(const QString& uid);
    void clearLiveUser();

    int getRoomUserCount();

private:
    NERoomLiveConfig();
    ~NERoomLiveConfig();

private:
    NERoomInfo m_roomInfo;
    QList<NELiveUser> userList;
};

#endif // NEROOMLIVECONFIG_H
