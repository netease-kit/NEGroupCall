package com.netease.biz_live.yunxin.live.model;


import java.io.Serializable;

/**
 * 单个直播信息
 */
public class LiveInfo implements Serializable {

    public String roomTopic;//房间主题
    public String nickname;//主播昵称
    public int audienceCount;//观众数量
    public String liveCoverPic;//直播房间封面
    public String liveCid;//直播号或者PK直播号
    public String avRoomCName;//房间频道名称 - 音视频房间的channelName
    public String imAccid;//主播CID
    public long avRoomUid;//音视频的房间号
    public int status;//房间状态状态: 0.未开始，1.房间中
    public int live;//直播状态: 0.未开始，1.正在直播，2.PK直播，3.直播结束
    public String chatRoomId;//聊天室频道号
    public LiveConfig liveConfig;//直播配置
    public String chatRoomCreator;//聊天室创建者
    public String accountId;//主播账号
    public String avatar;//主播头像
    public String avRoomCheckSum;//token，加入音视频房间用的鉴权
    public String roomUid;// 直播房间主播id
}
