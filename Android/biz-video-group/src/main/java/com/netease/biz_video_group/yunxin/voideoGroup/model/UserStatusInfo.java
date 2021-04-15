package com.netease.biz_video_group.yunxin.voideoGroup.model;

/**
 * 进入channel的用户信息
 */
public class UserStatusInfo {

    public UserStatusInfo(boolean isSelf, String nickname) {
        this.isSelf = isSelf;
        this.nickname = nickname;
    }

    public UserStatusInfo(String nickname, long userId) {
        this.nickname = nickname;
        this.userId = userId;
    }

    //昵称
    public String nickname;

    //用户Id
    public long userId;

    //是否是当前自己
    public boolean isSelf;

    //是否开启视频
    public boolean enableVideo=false;

    /**
     * 是否开启麦克风
     */
    public boolean enableMicphone=false;

    /**
     * 加入房间的时间戳
     */
    public long joinRoomTimeStamp;
    public int uiType;

    public static class UIType{
        /**
         * 全屏的样式
         */
        public static final int FULL_SCREEN_TYPE =0;
        /**
         * 平分整个屏幕的样式
         */
        public static final int HALF_TYPE =1;
        /**
         * 三个用户进入时，第三个用户特殊的样式
         */
        public static final int THIRD_SPECIAL_TYPE =2;
        /**
         * 四分之一的样式
         */
        public static final int QUARTER_TYPE=3;
    }
}
