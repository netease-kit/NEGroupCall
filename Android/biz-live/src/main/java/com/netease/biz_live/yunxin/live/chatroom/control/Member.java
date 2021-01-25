package com.netease.biz_live.yunxin.live.chatroom.control;

import com.netease.biz_live.yunxin.live.chatroom.model.LiveChatRoomInfo;

/**
 * Created by luc on 2020/11/18.
 */
interface Member {

    /**
     * 加入聊天室
     *
     * @param roomInfo 房间信息
     */
    void joinRoom(LiveChatRoomInfo roomInfo);

    /**
     * 离开聊天室
     */
    void leaveRoom();

    /**
     * 发送聊天室文本
     *
     * @param msg 文本信息
     */
    void sendTextMsg(String msg);

    /**
     * 聊天室消息回调注册
     *
     * @param notify   聊天室消息回调
     * @param register true 注册，false 反注册
     */
    void registerNotify(ChatRoomNotify notify, boolean register);
}
