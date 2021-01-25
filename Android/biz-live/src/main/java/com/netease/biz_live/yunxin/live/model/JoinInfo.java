package com.netease.biz_live.yunxin.live.model;

/**
 * 加入房间的info
 */
public class JoinInfo {
    public String avRoomCName;//String	音视频房间的channelName
    public String avRoomCid;//String	音视频房间id
    public long avRoomUid;//String	成员在音视频房间中用户id
    public String avRoomCheckSum;//String	token，加入音视频房间用的鉴权
    public long createTime;//int	房间的创建时间
    public long duration;//int	房间已经持续的时间
    public String roomKey;//String	appId 和 mpRoomId 加密后的key
    public int roomUniqueId;//int	房间在数据库中的唯一id
    public String liveCid;//String	直播号
    public String nrtcAppKey;//String	nrtc的appKey
}
