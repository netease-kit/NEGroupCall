package com.netease.biz_live.yunxin.live.chatroom.control;

/**
 * Created by luc on 1/11/21.
 * <p>
 * 当前用户被直播间踢出原因
 */
public interface MemberKickedReasonType {

    /**
     * 聊天室被解散
     */
    int CHAT_ROOM_INVALID = 1;

    /**
     * 被其他端登入踢出
     */
    int KICK_OUT_BY_CONFLICT_LOGIN = 3;
}
