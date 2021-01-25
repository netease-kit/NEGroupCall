package com.netease.biz_live.yunxin.live.model.message;

import com.netease.biz_live.yunxin.live.chatroom.model.AudienceInfo;

import java.util.List;

/**
 * 打赏消息体
 */
public class MsgReward extends NotificationMessage<MsgReward.RewardBody> {

    public static class RewardBody {
        public String operUser;// 观众账号,
        public String fromUser;// 打赏账号,
        public String fromUserAvRoomUid;// 主播 roomUid,
        public String roomCid;//直播房间频道号,
        public String pkStartTime;// 111111,
        public String pkEndTime;// 111111,
        public String currentTime;// 111111,
        public List<AudienceInfo> rewardPkList;//[ （PK贡献榜）
        public List<AudienceInfo> rewardList;//[ （在线观众贡献榜）

        public List<AudienceInfo> inviteeRewardPkList;//[ （PK贡献榜）

        public List<AudienceInfo> inviteeRewardList;//[ （在线观众贡献榜）

        public long rewardCoinTotal;//1234(云币总贡献数),
        public long inviteeRewardCoinTotal;//1234(被邀请者云币总贡献数),
        public long memberTotal;//1234（成员总数）
        public long giftId;// 打赏礼物id
        public String nickname;// 打赏者昵称
        /**
         * 直播PK被邀请者打赏总额
         */
        public long inviteeRewardPKCoinTotal;

        /**
         * 直播PK邀请者打赏总额
         */
        public long inviterRewardPKCoinTotal;
    }

}
