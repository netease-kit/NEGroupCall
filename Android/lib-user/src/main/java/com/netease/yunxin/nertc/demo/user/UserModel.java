package com.netease.yunxin.nertc.demo.user;

import android.text.TextUtils;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

/**
 * 业务用户数据
 */
public final class UserModel implements Serializable {
    @SerializedName("mobile")
    public String mobile;//String  登录的手机号
    @SerializedName("accessToken")
    public String accessToken;//String  登录令牌，重新生成的新令牌，过期时间重新计算
    @SerializedName("imAccid")
    public long imAccid;//long  IM账号
    @SerializedName("imToken")
    public String imToken;//String  IM令牌，重新生成的新令牌
    @SerializedName("avatar")
    public String avatar;//String  头像地址
    @SerializedName("nickname")
    public String nickname; //昵称
    @SerializedName("accountId")
    public String accountId; // 账号id
    @SerializedName("avRoomUid")
    public String avRoomUid;// 音视频房间内成员编号

    /**
     * 是否为相同的 IM 用户
     *
     * @param imAccid IM 用户id
     * @return true 相同IM用户，false 不同的IM用户
     */
    public boolean isSameIMUser(long imAccid) {
        return this.imAccid == imAccid;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserModel userModel = (UserModel) o;
        return TextUtils.equals(this.mobile, userModel.mobile);
    }

    /**
     * 获取昵称，没有昵称默认为 手机号
     */
    public String getNickname() {
        return TextUtils.isEmpty(nickname) ? mobile : nickname;
    }

    /**
     * 信息备份
     */
    public UserModel backup() {
        UserModel model = new UserModel();
        model.accessToken = accessToken;
        model.accountId = accountId;
        model.avatar = avatar;
        model.avRoomUid = avRoomUid;
        model.imAccid = imAccid;
        model.imToken = imToken;
        model.mobile = mobile;
        model.nickname = nickname;
        return model;
    }

}
