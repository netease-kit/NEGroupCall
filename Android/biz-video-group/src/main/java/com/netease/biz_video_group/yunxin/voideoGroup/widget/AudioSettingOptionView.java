package com.netease.biz_video_group.yunxin.voideoGroup.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.constant.AudioConstant;

/**
 * @author sunkeding
 * 音频相关参数设置：场景、音质
 */
public class AudioSettingOptionView extends LinearLayout {
    private TextView tvQuality;
    private AudioSceneSelectedView audioSceneView;
    public AudioSettingOptionView(Context context) {
        super(context);
        init(context);
    }

    public AudioSettingOptionView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public AudioSettingOptionView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }
    private void init(Context context) {
        inflate(context, R.layout.video_group_audio_setting_layout,this);
        tvQuality=findViewById(R.id.tv_quality);
        audioSceneView=findViewById(R.id.audio_scene_view);
        setAudioQuality(AudioConstant.AudioQuality.HD);
        audioSceneView.setAudioSceneSelectedListener(scene -> {
            if (audioSceneAndQualitySelectedListener !=null){
                audioSceneAndQualitySelectedListener.audioSceneSelected(scene);
            }
        });
        findViewById(R.id.fl_quality).setOnClickListener(v -> {
            if (audioSceneAndQualitySelectedListener !=null){
                audioSceneAndQualitySelectedListener.audioQualitySelected(tvQuality.getText().toString());
            }
        });
    }

    public void setAudioQuality(String audioQuality){
        tvQuality.setText(audioQuality);
    }
    private AudioSceneAndQualitySelectedListener audioSceneAndQualitySelectedListener;

    public void setAudioSceneAndQualitySelectedListener(AudioSceneAndQualitySelectedListener audioSceneAndQualitySelectedListener) {
        this.audioSceneAndQualitySelectedListener = audioSceneAndQualitySelectedListener;
    }

    public interface AudioSceneAndQualitySelectedListener {
        void audioSceneSelected(String scene);
        void audioQualitySelected(String quality);
    }
}
