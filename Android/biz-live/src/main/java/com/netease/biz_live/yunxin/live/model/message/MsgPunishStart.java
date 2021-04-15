package com.netease.biz_live.yunxin.live.model.message;

public class MsgPunishStart extends NotificationMessage<MsgPunishStart.PunishBody> {

    public static class PunishBody {
        public String operUser;// 操作者账号,
        public String fromUser;// 1111,
        public String fromUserAvRoomUid;// 1111,
        public String roomCid;//直播房间频道号,
        public long pkStartTime;// 111111,
        public long pkPulishmentTime;// 111111,
        public long currentTime;// 111111,
        public long inviteeRewards;// 111111,
        public long inviterRewards;// 111111
    }
}
