#include "NEHttpApi.h"

NERequest* NEHttpApi::join(const QString& roomid, const QString& nickname) {
    QMap<QString, QString> paramMap;

    paramMap["mpRoomId"] = roomid;
    paramMap["nickName"] = nickname;
    int clientType = 5;
#ifdef Q_OS_WIN
    clientType = 4;
#endif
    paramMap["clientType"] = QString::number(clientType);

	//此处填充自己的http地址
    return NEHttpManager::instance().post("", paramMap, 10000);
}

NERequest* NEHttpApi::saveSuggest(const NERoomSuggestInfo& info) {
    QMap<QString, QString> paramMap;

    paramMap["hubble_id"] = info.hubble_id;
    paramMap["feedback_type"] = QString::number(info.feedback_type);
    paramMap["conetent_type"] = info.conetent_type;
    paramMap["content"] = info.content;
    paramMap["contact"] = info.contact;
    paramMap["flag_content"] = info.flag_content;
    paramMap["doc_url"] = info.doc_url;
    paramMap["feedback_source"] = info.feedback_source;
    paramMap["type"] = QString::number(info.type);
    paramMap["uid"] = info.uid;
    paramMap["cid"] = info.cid;
    paramMap["appid"] = info.appid;
    paramMap["appkey"] = info.appkey;
	//此处填充自己的http地址
    return NEHttpManager::instance().post("", paramMap, 10000);
}

NERequest* NEHttpApi::getUserInfo(const QString& roomid, const QString& uid) {
    QMap<QString, QString> paramMap;

    paramMap["mpRoomId"] = roomid;
    paramMap["avRoomUid"] = uid;
	//此处填充自己的http地址
    return NEHttpManager::instance().post("", paramMap, 10000);
}
