package com.netease.biz_live.yunxin.live.chatroom.model;

/**
 * Created by luc on 2020/11/18.
 */
public class RewardGiftInfo {
    /**
     * 直播间id
     */
    public final String liveCid;
    /**
     * 打赏发送方昵称
     */
    public final String rewardNickname;
    /**
     * 打赏发送方用户 id
     */
    public final String rewardAccountId;
    /**
     * 主播昵称
     */
    public final String anchorId;
    /**
     * 礼物id
     */
    public final int giftId;


    public RewardGiftInfo(int giftId, String rewardNickname) {
        this(null, null, rewardNickname, null, giftId);
    }


    public RewardGiftInfo(String liveCid, String rewardAccountId, String rewardNickname, String anchorId, int giftId) {
        this.liveCid = liveCid;
        this.rewardAccountId = rewardAccountId;
        this.rewardNickname = rewardNickname;
        this.anchorId = anchorId;
        this.giftId = giftId;
    }
}
