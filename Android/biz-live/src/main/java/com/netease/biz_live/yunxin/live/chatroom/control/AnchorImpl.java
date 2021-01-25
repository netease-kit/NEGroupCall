package com.netease.biz_live.yunxin.live.chatroom.control;

import com.netease.biz_live.yunxin.live.chatroom.custom.AnchorCoinChangedAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PKStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PunishmentStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.model.LiveChatRoomInfo;

/**
 * Created by luc on 2020/11/18.
 */
class AnchorImpl implements Anchor {

    @Override
    public void notifyPKStatus(PKStatusAttachment pkStatus) {
        ChatRoomControl.getInstance().sendCustomMsg(pkStatus);
    }

    @Override
    public void notifyPunishmentStatus(PunishmentStatusAttachment punishmentStatus) {
        ChatRoomControl.getInstance().sendCustomMsg(punishmentStatus);
    }

    @Override
    public void notifyCoinChanged(AnchorCoinChangedAttachment attachment) {
        ChatRoomControl.getInstance().sendCustomMsg(attachment);
    }

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
        ChatRoomControl.getInstance().sendTextMsg(true, msg);
    }

    @Override
    public void registerNotify(ChatRoomNotify notify, boolean register) {
        ChatRoomControl.getInstance().registerNotify(notify, register);
    }
}
