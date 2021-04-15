package com.netease.biz_live.yunxin.live.chatroom.control;

import com.netease.biz_live.yunxin.live.chatroom.custom.AnchorCoinChangedAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PKStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PunishmentStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.model.LiveChatRoomInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.RewardGiftInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.RoomMsg;

/**
 * Created by luc on 2020/11/18.
 */
public interface ChatRoomNotify {
    /**
     * 用户进入聊天室
     *
     * @param success 是否成功进入聊天室
     * @param code    错误码
     */
    void onJoinRoom(boolean success, int code);

    /**
     * 聊天室关闭时触发
     */
    void onRoomDestroyed(LiveChatRoomInfo roomInfo);

    /**
     * 主播离开
     */
    void onAnchorLeave();

    /**
     * 当观众自己被从直播间聊天室踢出
     */
    void onKickedOut();

    /**
     * 接收对应聊天室内容
     *
     * @param msg 消息内容
     */
    void onMsgArrived(RoomMsg msg);

    /**
     * 当主播接收到礼物时回调// 用于
     *
     * @param giftInfo 礼物信息
     */
    void onGiftArrived(RewardGiftInfo giftInfo);

    /**
     * 聊天室用户数量变化时通知
     *
     * @param count 当前用户数量
     */
    void onUserCountChanged(int count);

    /**
     * 主播云币变更时通知
     *
     * @param attachment 变更数据
     */
    void onAnchorCoinChanged(AnchorCoinChangedAttachment attachment);

    /**
     * PK 状态变化通知
     *
     * @param pkStatus pk 状态
     */
    void onPKStatusChanged(PKStatusAttachment pkStatus);


    /**
     * 惩罚 状态变化通知
     *
     * @param punishmentStatus 惩罚状态
     */
    void onPunishmentStatusChanged(PunishmentStatusAttachment punishmentStatus);

}
