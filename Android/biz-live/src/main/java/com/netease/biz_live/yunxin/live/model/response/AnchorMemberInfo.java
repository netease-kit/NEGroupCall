package com.netease.biz_live.yunxin.live.model.response;

import com.netease.biz_live.yunxin.live.model.LiveConfig;

/**
 * Created by luc on 2020/11/26.
 */
public class AnchorMemberInfo {
    /**
     * 用户id
     */
    public String accountId;

    /**
     * 观众数
     */
    public long audienceCount;

    /**
     * 音视频房间的用户id
     */
    public long avRoomUid;

    /**
     * 音视频房间名称
     */
    public String avRoomCName;

    /**
     * 音视频房间token
     */
    public String avRoomCheckSum;

    /**
     * 音视频房间 id
     */
    public String avRoomCid;

    /**
     * 聊天室创建者
     */
    public String chatRoomCreator;

    /**
     * 聊天室频道号
     */
    public String chatRoomId;

    /**
     * im id
     */
    public String imAccd;

    /**
     * 直播状态: 0.未开始，1.正在直播， 2.PK直播，3.PK直播结束 4 直播结束 5 PK惩罚
     */
    public int live;

    /**
     * 直播号
     */
    public String liveCid;

    /**
     * 直播配置
     */
    public LiveConfig liveConfig;

    /**
     * 直播房间封面
     */
    public String liveCoverPic;

    /**
     * ?
     */
    public String mpRoomId;

    /**
     * 昵称
     */
    public String nickname;

    /**
     * 用户头像
     */
    public String avatar;

    public String roomCid;

    public String roomTopic;

    public String roomUid;
}
