package com.netease.biz_live.yunxin.live.chatroom.model;

import androidx.annotation.IntDef;

/**
 * Created by luc on 2020/11/18.
 */
public class RoomMsg {
    @MsgType
    public final int msgType;

    public final CharSequence message;

    public RoomMsg(int msgType, CharSequence message) {
        this.msgType = msgType;
        this.message = message;
    }

    @IntDef({MsgType.USER_IN, MsgType.USER_OUT, MsgType.TEXT, MsgType.GIFT})
    public @interface MsgType {

        /**
         * 用户进入聊天室
         */
        int USER_IN = 1;

        /**
         * 用户离开聊天室
         */
        int USER_OUT = 2;

        /**
         * 普通文本
         */
        int TEXT = 3;

        /**
         * 礼物发送
         */
        int GIFT = 4;

    }
}
