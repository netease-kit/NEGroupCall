package com.netease.biz_live.yunxin.live.chatroom.custom;

import com.google.gson.annotations.SerializedName;
import com.netease.nimlib.sdk.msg.attachment.MsgAttachment;

/**
 * Created by luc on 2020/11/19.
 */
abstract class BaseCustomAttachment implements MsgAttachment {
    public static final String KEY_JSON_TYPE = "type";

    @SerializedName(KEY_JSON_TYPE)
    public int type;

}
