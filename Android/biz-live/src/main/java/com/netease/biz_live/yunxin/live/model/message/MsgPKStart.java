package com.netease.biz_live.yunxin.live.model.message;

/**
 * PK 开始的消息体
 */
public class MsgPKStart extends NotificationMessage<MsgPKStart.StartPKBody> {

    public static class StartPKBody {
        public String operUser;//: 11111,
        public String fromUser;//: 1111,
        public String fromUserAvRoomUid;//: 1111,
        public String roomCid;//:直播房间频道号,
        public long pkStartTime;//: 111111,
        public String pkPublishmentTime;//: 111111,
        public long currentTime;//: 111111,
        public String inviter;//:邀请者账号,
        public String invitee;//:被邀请者账号,
        public String inviterNickname;//: 邀请者昵称,
        public String inviteeNickname;//: 被邀请者昵称,
        public String inviterAvatar;//: 邀请者头像,
        public String inviteeAvatar;//: 被邀请者头像
        public long inviterRoomUid;//邀请者房间号中UID,
        public long inviteeRoomUid;//被邀请者房间号中UID,
    }

}
