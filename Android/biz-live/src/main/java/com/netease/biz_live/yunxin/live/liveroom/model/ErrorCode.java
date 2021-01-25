package com.netease.biz_live.yunxin.live.liveroom.model;

public interface ErrorCode {
    /**
     * 断开连接
     */
    int ERROR_CODE_DISCONNECT = 3001;

    /**
     * nertc 被回收
     */
    int ERROR_CODE_ENGINE_NULL = 3002;

    /**
     * 已经接受等待时进入超时
     */
    int ERROR_CODE_TIME_OUT_ACCEPTED = 4001;

    /**
     * 呼叫超时
     */
    int ERROR_CODE_TIME_OUT_CALL_OUT = 4002;

    /**
     * 接收超时
     */
    int ERROR_CODE_TIME_OUT_ACCEPT = 4003;
}
