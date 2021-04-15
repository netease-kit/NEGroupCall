package com.netease.biz_live.yunxin.live.model.message;

public class NotificationMessage<T> {
    /**
     * PK开始消息
     */
    public static final String TYPE_PK_START = "2000";
    /**
     * PK惩罚开始消息：告诉主播PK结果
     */
    public static final String TYPE_PUNISH_START = "2001";
    /**
     * 观众打赏消息
     */
    public static final String TYPE_AUDIENCE_REWARD = "2002";

    /**
     * PK结束消息
     */
    public static final String TYPE_PK_END = "2003";

    /**
     * 直播开始
     */
    public static final String TYPE_LIVE_START = "2004";

    public T data;
    public String type;
}
