package com.netease.biz_live.yunxin.live.model.response;

import com.google.gson.annotations.SerializedName;

/**
 * Created by luc on 2020/11/26.
 */
public class PkLiveContributor {

    @SerializedName("accountId")
    public String accountId;

    @SerializedName("avatar")
    public String avatar;

    @SerializedName("imAccid")
    public String imAccid;

    @SerializedName("nickname")
    public String nickname;

    @SerializedName("rewardCoin")
    public long rewardCoin;
}
