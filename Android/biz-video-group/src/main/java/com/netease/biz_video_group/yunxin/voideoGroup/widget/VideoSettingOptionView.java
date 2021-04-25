package com.netease.biz_video_group.yunxin.voideoGroup.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.constant.VideoConstant;

/**
 * @author sunkeding
 * 视频相关参数设置：分辨率、帧率
 */
public class VideoSettingOptionView extends LinearLayout {
    private TextView tvResolution;
    private TextView tvFps;
    public VideoSettingOptionView(Context context) {
        super(context);
        init(context);
    }

    public VideoSettingOptionView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public VideoSettingOptionView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }
    private void init(Context context) {
        inflate(context, R.layout.video_group_video_setting_layout,this);
        tvResolution=findViewById(R.id.tv_resolution);
        tvFps=findViewById(R.id.tv_fps);
        findViewById(R.id.rl_resolution).setOnClickListener(v -> {
            if (resolutionAndFpsSelectedListener!=null){
                resolutionAndFpsSelectedListener.showResolutionSelectedWheel(tvResolution.getText().toString());
            }
        });
        findViewById(R.id.rl_fps).setOnClickListener(v -> {
            if (resolutionAndFpsSelectedListener!=null){
                resolutionAndFpsSelectedListener.showFpsSelectedWheel(tvFps.getText().toString());
            }
        });
        setVideoResolution(VideoConstant.Resolution.RESOLUTION_1280X720);
        setVideoFps(VideoConstant.FPS.FPS_30);
    }

    public void setVideoResolution(String videoResolution){
        tvResolution.setText(videoResolution);
    }
    public void setVideoFps(String videoFps){
        tvFps.setText(videoFps);
    }

    public void setResolutionAndFpsSelectedListener(ResolutionAndFpsSelectedListener resolutionAndFpsSelectedListener) {
        this.resolutionAndFpsSelectedListener = resolutionAndFpsSelectedListener;
    }

    private ResolutionAndFpsSelectedListener resolutionAndFpsSelectedListener;
    public interface ResolutionAndFpsSelectedListener{
        void showResolutionSelectedWheel(String currentResolution);
        void showFpsSelectedWheel(String currentFps);
    }
}
