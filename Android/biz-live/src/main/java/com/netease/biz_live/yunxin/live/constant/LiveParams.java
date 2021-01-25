package com.netease.biz_live.yunxin.live.constant;

/**
 * 直播参数
 */
public interface LiveParams {
    //****************直播推流参数start*******************
    int SIGNAL_HOST_LIVE_WIDTH = 720;

    int SIGNAL_HOST_LIVE_HEIGHT = 1280;

    int PK_LIVE_WIDTH = 360;

    int PK_LIVE_HEIGHT = 640;
    //****************直播推流参数end*********************

    /**
     * pk 状态下视频 宽高比
     */
    float WH_RATIO_PK = PK_LIVE_WIDTH * 2f / PK_LIVE_HEIGHT;
}
