#ifndef UPCLASSHTTPAPI_H
#define UPCLASSHTTPAPI_H

#include "NEHttpManager.h"

enum NEConetentType {
    OTHER_TYPE = 99,  //其他类型
    NO_VOICE = 101,   //无声音
    MUR_VOICE,        //杂音
    CATON_VOICE,      //声音卡顿
    NO_VIDEO,         //无画面
    CATON_VIDEO,      //画面卡顿
    BLURRED_VIDEO,    //画面模糊
    NO_SYNC,          //音画不同步
    CRASH_EXIT        //意外退出
};

struct NERoomSuggestInfo {
    QString hubble_id;
    qint64 feedback_type;   //用户评价 0：好 1：坏
    QString conetent_type;  //问题类型
    QString content;        //问题描述
    QString contact;        //联系方式
    QString flag_content;
    QString doc_url;
    QString feedback_source;  //反馈来源
    qint32 type;              //反馈场景 1：demo 2：demo通话中
    QString uid;              //用户ID
    QString cid;              //房间ID
    QString appid;            //应用ID
    QString appkey;           //应用Key

    NERoomSuggestInfo() {
        hubble_id = "";
        feedback_type = 0;
        conetent_type = OTHER_TYPE;
        content = "";
        contact = "";
        flag_content = "";
        doc_url = "";
        feedback_source = "多人视频通话Demo";
        type = 1;
        uid = "";
        cid = "";
        appid = "";
        appkey = "";
    }
};

class NEHttpApi {
public:
    static NERequest* join(const QString& roomid, const QString& nickname);

    static NERequest* saveSuggest(const NERoomSuggestInfo& info);

    static NERequest* getUserInfo(const QString& roomid, const QString& uid);

    static QString getBaseUrl();
};

#endif  // UPCLASSHTTPAPI_H
