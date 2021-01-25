package com.netease.biz_live.yunxin.live.chatroom.control;

import com.netease.biz_live.yunxin.live.chatroom.model.LiveChatRoomInfo;

/**
 * Created by luc on 2020/11/18.
 */
class AudienceImpl implements Audience {
    @Override
    public void joinRoom(LiveChatRoomInfo roomInfo) {
        ChatRoomControl.getInstance().joinRoom(roomInfo);
    }

    @Override
    public void leaveRoom() {
        ChatRoomControl.getInstance().leaveRoom();
    }

    @Override
    public void sendTextMsg(String msg) {
        ChatRoomControl.getInstance().sendTextMsg(false, msg);
    }

    @Override
    public void registerNotify(ChatRoomNotify notify, boolean register) {
        ChatRoomControl.getInstance().registerNotify(notify, register);
    }
}
