package com.netease.biz_live.yunxin.live.model.response;

import com.google.gson.annotations.SerializedName;

/**
 * Created by luc on 2020/11/26.
 */
public class PkRecord {

    /**
     * 直播号
     */
    @SerializedName("liveCid")
    public String liveCid;

    /**
     * 音视频房间cid
     */
    @SerializedName("roomCid")
    public String roomCid;

    /**
     * 邀请者账号
     */
    @SerializedName("inviter")
    public String inviter;

    /**
     * 被邀请者账号
     */
    @SerializedName("invitee")
    public String invitee;

    /**
     * PK开始时间
     */
    @SerializedName("pkStartTime")
    public long pkStartTime;

    /**
     * 当前时间戳
     */
    @SerializedName("currentTime")
    public long currentTime;

    /**
     * PK结束时间
     */
    @SerializedName("pkEndTime")
    public long pkEndTime;

    /**
     * 惩罚开始时间
     */
    @SerializedName("punishmentStartTime")
    public long punishmentStartTime;

    /**
     * 0：未开始 1：PK中，2：PK结束
     */
    @SerializedName("status")
    public int status;

    /**
     * 被邀请者打赏总额
     */
    @SerializedName("inviteeRewards")
    public long inviteeRewards;

    /**
     * 邀请者打赏总额
     */
    @SerializedName("inviterRewards")
    public long inviterRewards;

    /**
     * 邀请者原直播房间号
     */
    @SerializedName("inviterLiveCid")
    public String inviterLiveCid;

    /**
     * 被邀请者原直播房间号
     */
    @SerializedName("inviteeLiveCid")
    public String inviteeLiveCid;
}
