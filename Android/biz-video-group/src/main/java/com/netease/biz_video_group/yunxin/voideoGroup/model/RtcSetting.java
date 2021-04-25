package com.netease.biz_video_group.yunxin.voideoGroup.model;

import com.netease.biz_video_group.yunxin.voideoGroup.constant.AudioConstant;
import com.netease.biz_video_group.yunxin.voideoGroup.constant.VideoConstant;

import java.io.Serializable;

public class RtcSetting implements Serializable {
    public String resolution= VideoConstant.Resolution.RESOLUTION_1280X720;
    public String fps=VideoConstant.FPS.FPS_30;
    public String audioScene= AudioConstant.AudioScene.MUSIC;
    public String audioQuality=AudioConstant.AudioQuality.HD;
    /**
     * 入会时打开摄像头
     */
    public boolean enableCamera=true;
    /**
     * 入会时打开麦克风
     */
    public boolean enableMicphone=true;

    @Override
    public String toString() {
        return "RtcSetting{" +
                "resolution='" + resolution + '\'' +
                ", fps='" + fps + '\'' +
                ", audioScene='" + audioScene + '\'' +
                ", audioQuality='" + audioQuality + '\'' +
                ", enableCamera=" + enableCamera +
                ", enableMicphone=" + enableMicphone +
                '}';
    }





}
