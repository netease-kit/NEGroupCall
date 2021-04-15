#include "NERoomLiveConfig.h"

void NERoomLiveConfig::setRoomInfo(const NERoomInfo &info)
{
    m_roomInfo = info;
}

NERoomInfo NERoomLiveConfig::getRoomInfo() const
{
    return  m_roomInfo;
}

void NERoomLiveConfig::appendLiveUser(const NELiveUser &user)
{
    userList << user;
}

void NERoomLiveConfig::deleteLiveUser(const QString &uid)
{
    for(int i = 0; i < userList.count(); ++i){
        if(uid == userList[i].uid)
        {
            userList.removeAt(i);
            break;
        }
    }
}

void NERoomLiveConfig::clearLiveUser()
{
    userList.clear();
}

int NERoomLiveConfig::getRoomUserCount()
{
    return userList.count();
}

NERoomLiveConfig::NERoomLiveConfig()
{

}

NERoomLiveConfig::~NERoomLiveConfig()
{

}
