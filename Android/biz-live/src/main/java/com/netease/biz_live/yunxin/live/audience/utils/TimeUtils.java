package com.netease.biz_live.yunxin.live.audience.utils;

/**
 * Created by luc on 2020/12/9.
 */
public final class TimeUtils {

    /**
     * 获取时间剩余总毫秒数
     *
     * @param totalTime        时间总毫秒数
     * @param currentTimestamp 当前时间戳
     * @param startedTimestamp 开始时间戳
     * @param offset           偏移量毫秒数
     * @return 时间剩余毫秒数
     */
    public static long getLeftTime(long totalTime, long currentTimestamp, long startedTimestamp, long offset) {
        return totalTime - (currentTimestamp - startedTimestamp) + offset;
    }
}
