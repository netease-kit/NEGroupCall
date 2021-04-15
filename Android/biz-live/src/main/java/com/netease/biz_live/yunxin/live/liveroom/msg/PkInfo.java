package com.netease.biz_live.yunxin.live.liveroom.msg;

public class PkInfo {

    /**
     * 发起者的昵称
     */
    public String inviterNickname;

    /**
     * pk 的cid
     */
    public String pkLiveCid;

    public PkInfo(String pkLiveCid, String inviterNickname) {
        this.inviterNickname = inviterNickname;
        this.pkLiveCid = pkLiveCid;
    }
}
