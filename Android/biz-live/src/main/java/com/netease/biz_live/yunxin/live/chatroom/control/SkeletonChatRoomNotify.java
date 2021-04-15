package com.netease.biz_live.yunxin.live.chatroom.control;

import com.netease.biz_live.yunxin.live.chatroom.custom.AnchorCoinChangedAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PKStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PunishmentStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.model.AudienceInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.LiveChatRoomInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.RewardGiftInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.RoomMsg;
import com.netease.nimlib.sdk.RequestCallback;

import java.util.Collections;
import java.util.List;

import androidx.annotation.CallSuper;

/**
 * Created by luc on 2020/11/18.
 * <p>
 * 允许用户按需实现接口避免关注非必要接口
 */
public class SkeletonChatRoomNotify implements ChatRoomNotify {
    /**
     * 直播间展示最多在线观众信息数目
     */
    private static final int MAX_AUDIENCE_COUNT = 10;

    @Override
    public void onJoinRoom(boolean success, int code) {

    }

    @Override
    public void onRoomDestroyed(LiveChatRoomInfo roomInfo) {

    }

    @Override
    public void onAnchorLeave() {

    }

    @Override
    public void onKickedOut() {

    }

    @Override
    public void onMsgArrived(RoomMsg msg) {

    }

    @Override
    public void onGiftArrived(RewardGiftInfo giftInfo) {

    }

    @CallSuper
    @Override
    public void onUserCountChanged(int count) {
        handleUserIO();
    }

    @Override
    public void onAnchorCoinChanged(AnchorCoinChangedAttachment attachment) {

    }

    @Override
    public void onPKStatusChanged(PKStatusAttachment pkStatus) {

    }

    @Override
    public void onPunishmentStatusChanged(PunishmentStatusAttachment punishmentStatus) {

    }

    /**
     * 直播房间内观众变化信息，此信息目前由客户端维护，只展示最早加入房间的前10个在线用户，当用户数量变化时检测是否需要更新
     * 调用聊天室服务查询前10的用户信息
     *
     * @param infoList 直播间在线观众信息¬
     */
    public void onAudienceChanged(List<AudienceInfo> infoList) {

    }

    /**
     * 每次观众数变化时都需要重新像聊天室查询此信息，正常观众列表应有服务端维护
     */
    private void handleUserIO() {
        ChatRoomControl.getInstance().queryRoomTempMembers(MAX_AUDIENCE_COUNT, new RequestCallback<List<AudienceInfo>>() {
            @Override
            public void onSuccess(List<AudienceInfo> param) {
                // 聊天室返回的数据为用户最新加入房间为最前面，需求是按加入房间时间排序，越早越前
                Collections.reverse(param);
                onAudienceChanged(param);
            }

            @Override
            public void onFailed(int code) {
            }

            @Override
            public void onException(Throwable exception) {
            }
        });
    }
}
