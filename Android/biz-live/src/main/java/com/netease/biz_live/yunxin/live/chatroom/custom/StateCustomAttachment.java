package com.netease.biz_live.yunxin.live.chatroom.custom;

import com.google.gson.annotations.SerializedName;
import com.netease.biz_live.yunxin.live.audience.utils.TimeUtils;

/**
 * Created by luc on 2020/11/19.
 */
abstract class StateCustomAttachment extends BaseCustomAttachment {

    /**
     * 当前状态，0-开始，1-结束，结束时
     */
    @SerializedName("state")
    public int state;
    /**
     * 开始时间
     * 开始 pk 时间戳，state为 1 时字段忽略
     */
    @SerializedName("startedTimestamp")
    public long startedTimestamp;
    /**
     * 当前时间
     * 当前服务器时间戳，state 为 1 时忽略
     */
    @SerializedName("currentTimestamp")
    public long currentTimestamp;
    /**
     * 对方主播昵称
     */
    @SerializedName("otherAnchorNickname")
    public String otherAnchorNickname;
    /**
     * 对方主播头像
     */
    @SerializedName("otherAnchorAvatar")
    public String otherAnchorAvatar;
    /**
     * 当前主播是否胜利
     * 结束 pk 结果，表示当前观众所在房间主播是否胜利，state 为 0 时忽略
     */
    @SerializedName("currentAnchorWin")
    public boolean anchorWin;

    public StateCustomAttachment() {
        this(false);
    }

    public StateCustomAttachment(boolean anchorWin) {
        this(true, 0, 0, null, null, anchorWin);
    }

    public StateCustomAttachment(long startedTimestamp, long currentTimestamp, String otherAnchorNickname, String otherAnchorAvatar) {
        this(false, startedTimestamp, currentTimestamp, otherAnchorNickname, otherAnchorAvatar, false);
    }

    public StateCustomAttachment(boolean finished, long startedTimestamp, long currentTimestamp, String otherAnchorNickname, String otherAnchorAvatar, boolean anchorWin) {
        this.state = finished ? 1 : 0;
        this.startedTimestamp = startedTimestamp;
        this.currentTimestamp = currentTimestamp;
        this.otherAnchorNickname = otherAnchorNickname;
        this.otherAnchorAvatar = otherAnchorAvatar;
        this.anchorWin = anchorWin;
    }

    public boolean isStartState() {
        return state == 0;
    }

    public boolean isStopState() {
        return state == 1;
    }

    public long getLeftTime(long totalTime, long offset) {
        return TimeUtils.getLeftTime(totalTime, currentTimestamp, startedTimestamp, offset);
    }
}
