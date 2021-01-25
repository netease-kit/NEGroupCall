package com.netease.biz_live.yunxin.live.liveroom.model;

/**
 * 创建房间的回调
 */
public interface LiveRoomCallBack {
    void onSuccess();

    void onError(int code, String msg);
}
