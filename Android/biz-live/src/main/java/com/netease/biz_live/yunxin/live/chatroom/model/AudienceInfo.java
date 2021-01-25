package com.netease.biz_live.yunxin.live.chatroom.model;

import com.google.gson.annotations.SerializedName;

/**
 * Created by luc on 2020/11/20.
 * 观众基本信息
 */
public class AudienceInfo {
    @SerializedName("accountId")
    public final String accountId;
    /**
     * 用户昵称
     */
    @SerializedName("nickname")
    public final String nickname;
    /**
     * 用户 IM id
     */
    @SerializedName("imAccid")
    public final long imAccid;
    /**
     * 用户头像
     */
    @SerializedName("avatar")
    public final String avatar;

    /**
     * 贡献云币数
     */
    @SerializedName("rewardCoin")
    public final String rewardCoin;

    public AudienceInfo(String accountId, long imAccid, String nickname, String avatar) {
        this.accountId = accountId;
        this.nickname = nickname;
        this.imAccid = imAccid;
        this.avatar = avatar;
        this.rewardCoin = "";
    }

    public AudienceInfo(String accountId, long imAccid, String nickname, String avatar, String rewardCoin) {
        this.accountId = accountId;
        this.nickname = nickname;
        this.imAccid = imAccid;
        this.avatar = avatar;
        this.rewardCoin = rewardCoin;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        AudienceInfo that = (AudienceInfo) o;

        if (imAccid != that.imAccid) return false;
        return accountId != null ? accountId.equals(that.accountId) : that.accountId == null;
    }

    @Override
    public int hashCode() {
        int result = accountId != null ? accountId.hashCode() : 0;
        result = 31 * result + (int) (imAccid ^ (imAccid >>> 32));
        return result;
    }
}
