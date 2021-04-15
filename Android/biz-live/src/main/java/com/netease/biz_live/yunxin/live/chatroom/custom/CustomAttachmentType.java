package com.netease.biz_live.yunxin.live.chatroom.custom;

import androidx.annotation.IntDef;

/**
 * Created by luc on 2020/11/18.
 */

@IntDef({CustomAttachmentType.CHAT_ROOM_PK, CustomAttachmentType.CHAT_ROOM_PUNISHMENT,
       CustomAttachmentType.CHAT_ROOM_ANCHOR_COIN_CHANGED,
        CustomAttachmentType.CHAT_ROOM_TEXT})
public @interface CustomAttachmentType {
    /**
     * 未知
     */
    int UNKNOWN = 0;
    /**
     * pk 阶段
     */
    int CHAT_ROOM_PK = 11;
    /**
     * 惩罚阶段
     */
    int CHAT_ROOM_PUNISHMENT = 12;
    /**
     * 主播云币变化
     */
    int CHAT_ROOM_ANCHOR_COIN_CHANGED = 14;
    /**
     * 文本消息
     */
    int CHAT_ROOM_TEXT = 15;
}
