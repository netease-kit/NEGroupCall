package com.netease.biz_video_group.yunxin.voideoGroup.util;

import android.view.View;

import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;

/**
 * @author sunkeding
 * 处理视频
 */
public class VideoViewUtil {
    /**
     * 设置本地视图
     *
     * @param videoView
     * @param isStick 是否置顶
     */
    public static void setupLocalVideo(NERtcVideoView videoView,boolean isStick) {
        if (videoView == null) {
            return;
        }
        videoView.setZOrderMediaOverlay(isStick);
        videoView.setMirror(true);
        videoView.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_BALANCED);
        NERtcEx.getInstance().setupLocalVideoCanvas(videoView);
        videoView.setVisibility(View.VISIBLE);
    }

    /**
     * 设置远端视图
     *
     * @param videoView
     * @param userId
     */
    public static void setupRemoteVideo(NERtcVideoView videoView, long userId,boolean isStick) {
        videoView.setZOrderMediaOverlay(isStick);
        videoView.setMirror(true);
        videoView.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_FIT);
        NERtcEx.getInstance().setupRemoteVideoCanvas(videoView, userId);
        videoView.setVisibility(View.VISIBLE);
    }
}
