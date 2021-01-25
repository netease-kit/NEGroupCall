package com.netease.biz_live.yunxin.live.model;

import java.io.Serializable;

/**
 * 直播参数
 */
public class LiveConfig implements Serializable {
    public String httpPullUrl;//String	直播拉流地址
    public String rtmpPullUrl;//String rtmp直播拉流地址
    public String hlsPullUrl;//Stringhls拉流地址
    public String pushUrl;//String	推流地址pushUrl
    public String cid;// String	直播频道Cid
}
