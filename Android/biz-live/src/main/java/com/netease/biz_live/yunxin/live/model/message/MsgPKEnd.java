package com.netease.biz_live.yunxin.live.model.message;

/**
 * PK 结束的消息体
 */
public class MsgPKEnd extends NotificationMessage<MsgPKEnd.PKEndBody> {

    public static class PKEndBody {
        public String operUser;//: 操作者账号,
        public String fromUser;//: 1111,
        public String fromUserAvRoomUid;//: 1111,
        public String roomCid;//:直播房间频道号,
        public String currentTime;//: 111111,
        public String pkEndTime;//: 111111,
        public boolean countdownEnd;//是否是倒计时结束的
        /**
         * 发起者的昵称，如果是countdownEnd true，则为空
         */
        public String closedNickname;
    }
}
