package com.netease.biz_live.yunxin.live.model.response;

import java.util.List;

/**
 * Created by luc on 2020/11/26.
 */
public class AnchorQueryInfo {
    /**
     * 房间类型 1：多人语音 2：直播 3：PK直播
     */
    public int type;

    /**
     * 直播频道号
     */
    public String liveCid;

    /**
     * 音频Cid
     */
    public String avRoomCid;

    /**
     * 频道名称
     */
    public String avRoomCName;

    /**
     * 云币总数
     */
    public long coinTotal;

    /**
     * 成员状态，1-未开始，2- 直播中，3-结束直播
     */
    public int status;

    /**
     * PK直播开始时间
     */
    public long pkStartTime;

    /**
     * Pk直播记录
     */
    public PkRecord pkRecord;

    /**
     * 成员信息
     */
    public List<AnchorMemberInfo> members;
}
