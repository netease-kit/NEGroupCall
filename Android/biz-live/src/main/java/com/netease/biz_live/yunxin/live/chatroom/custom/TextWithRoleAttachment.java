package com.netease.biz_live.yunxin.live.chatroom.custom;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;

/**
 * Created by luc on 2020/11/26.
 * 附带是否主播信息的文本自定义消息
 */
public class TextWithRoleAttachment extends BaseCustomAttachment {
    /**
     * 消息发送方是否为主播
     */
    @SerializedName("isAnchor")
    public boolean isAnchor;

    /**
     * 实际传输的文本消息
     */
    @SerializedName("message")
    public String msg;

    public TextWithRoleAttachment(boolean isAnchor, String msg) {
        this.isAnchor = isAnchor;
        this.msg = msg;
        this.type = CustomAttachmentType.CHAT_ROOM_TEXT;
    }

    @Override
    public String toJson(boolean send) {
        return new Gson().toJson(this);
    }
}
