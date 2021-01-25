package com.netease.biz_live.yunxin.live.liveroom.model;

import com.netease.biz_live.yunxin.live.liveroom.msg.PkInfo;
import com.netease.biz_live.yunxin.live.model.message.MsgPKStart;
import com.netease.biz_live.yunxin.live.model.message.MsgPunishStart;
import com.netease.biz_live.yunxin.live.model.message.MsgReward;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.avsignalling.event.InvitedEvent;

public interface NERTCLiveRoomDelegate {

    /**
     * 主播开启直播，收到服务端消息，正式开始直播（由IM消息触发）
     */
    void onRoomLiveStart();

    /**
     * PK开始，（由IM消息触发）
     */
    void onPkStart(MsgPKStart.StartPKBody startPKBody);

    /**
     * 惩罚开始（由IM消息触发）
     *
     * @param punishBody
     */
    void onPunishStart(MsgPunishStart.PunishBody punishBody);

    /**
     * pk结束（由IM消息触发）
     */
    void onPKEnd(boolean isFromUser, String nickname);

    /**
     * 观众打赏（由IM消息触发）
     *
     * @param reward
     */
    void onUserReward(MsgReward.RewardBody reward);

    /**
     * pk 邀请被取消，
     * 可由邀请方调用{@link NERTCLiveRoom#cancelPkRequest(RequestCallback, boolean)} 取消
     *
     * @param byUser 是否是由用户主动取消的
     */
    void onPkRequestCancel(boolean byUser);

    /**
     * 收到PK邀请 邀请方调用{@link NERTCLiveRoom#requestPK(String, String, String, String, String, LiveRoomCallBack)}，
     * 被邀请方收到此方法回调
     *
     * @param invitedEvent
     * @param pkInfo
     */
    void receivePKRequest(InvitedEvent invitedEvent, PkInfo pkInfo);

    /**
     * pk 邀请被拒绝
     *
     * @param userId
     */
    void pkRequestRejected(String userId);

    /**
     * 邀请被接受，正式进入Pk准备阶段
     */
    void onAccept();


    /**
     * 加入rtc 房间之前调用，获取checkSum，并站位
     *
     * @param liveCid
     * @param isPk
     * @param parentLiveCid
     */
    void preJoinRoom(String liveCid, boolean isPk, String parentLiveCid);

    /**
     * 音效结束回调
     * @param effectId 指定音效的 ID。每个音效均有唯一的 ID
     */
    void onAudioEffectFinished(int effectId);

    /**
     * 背景音乐结束回调
     */
    void onAudioMixingFinished();

    /**
     * 超时
     *
     * @param code 超时code
     */
    void onTimeOut(int code);

    /**
     * 邀请方忙线
     *
     * @param userId 忙线用户
     */
    void onUserBusy(String userId);

    /**
     * 错误回调
     *
     * @param serious 是否严重
     * @param code    错误码
     * @param msg     错误信息
     */
    void onError(boolean serious, int code, String msg);
}
