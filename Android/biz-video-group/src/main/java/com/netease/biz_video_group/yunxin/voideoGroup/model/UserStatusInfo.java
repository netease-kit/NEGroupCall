package com.netease.biz_video_group.yunxin.voideoGroup.model;

/**
 * 进入channel的用户信息
 */
public class UserStatusInfo {

    public UserStatusInfo(boolean isSelf, String nickname) {
        this.isSelf = isSelf;
        this.nickname = nickname;
        this.isMute = false;
        this.enableVideo = true;
    }

    public UserStatusInfo(String nickname, long userId) {
        this.nickname = nickname;
        this.userId = userId;
        this.isMute = true;
        this.enableVideo = false;
    }

    //昵称
    public String nickname;

    //用户Id
    public long userId;

    //是否是当前自己
    public boolean isSelf;

    //是否开启视频
    public boolean enableVideo;

    public boolean isMute;
}
