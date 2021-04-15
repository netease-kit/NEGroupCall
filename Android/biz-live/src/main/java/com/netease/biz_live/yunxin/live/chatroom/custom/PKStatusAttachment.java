package com.netease.biz_live.yunxin.live.chatroom.custom;

import com.google.gson.Gson;

/**
 * Created by luc on 2020/11/18.
 * <p>
 * 自定义消息，pk 状态
 */
public class PKStatusAttachment extends StateCustomAttachment {


    public PKStatusAttachment(boolean anchorWin) {
        super(anchorWin);
        this.type = CustomAttachmentType.CHAT_ROOM_PK;
    }

    public PKStatusAttachment(long startedTimestamp, long currentTimestamp, String otherAnchorNickname, String otherAnchorAvatar) {
        super(startedTimestamp, currentTimestamp, otherAnchorNickname, otherAnchorAvatar);
        this.type = CustomAttachmentType.CHAT_ROOM_PK;
    }

    @Override
    public String toJson(boolean send) {
        return new Gson().toJson(this);
    }
}
