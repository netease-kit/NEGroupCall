package com.netease.biz_live.yunxin.live.liveroom.model.impl;

/**
 * 推流recorder
 */
public class LiveStreamTaskRecorder {
    public String pushUlr;
    public boolean isPk;
    public long uid1;
    public long uid2;
    public String taskId;

    public LiveStreamTaskRecorder(String pushUlr, long uid1) {
        this.pushUlr = pushUlr;
        this.uid1 = uid1;
        taskId = String.valueOf(Math.abs(pushUlr.hashCode())) + System.currentTimeMillis();
    }

    public LiveStreamTaskRecorder(String pushUlr, boolean isPk, long uid1, long uid2) {
        this.pushUlr = pushUlr;
        this.isPk = isPk;
        this.uid1 = uid1;
        this.uid2 = uid2;
        taskId = String.valueOf(Math.abs(pushUlr.hashCode())) + System.currentTimeMillis();
    }

    @Override
    public String toString() {
        return "LiveStreamTaskRecorder{" +
                "pushUlr='" + pushUlr + '\'' +
                ", isPk=" + isPk +
                ", uid1=" + uid1 +
                ", uid2=" + uid2 +
                ", taskId='" + taskId + '\'' +
                '}';
    }
}
