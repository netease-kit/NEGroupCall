package com.netease.biz_video_group.yunxin.voideoGroup.ui;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.base.VideoGroupBaseDialog;
import com.netease.biz_video_group.yunxin.voideoGroup.constant.AudioConstant;
import com.netease.biz_video_group.yunxin.voideoGroup.constant.VideoConstant;
import com.netease.biz_video_group.yunxin.voideoGroup.model.RtcSetting;
import com.netease.biz_video_group.yunxin.voideoGroup.widget.AudioSettingOptionView;
import com.netease.biz_video_group.yunxin.voideoGroup.widget.OptionSwitchWidget;
import com.netease.biz_video_group.yunxin.voideoGroup.widget.VideoSettingOptionView;

import java.util.ArrayList;

/**
 * @author sunkeding
 * 设置弹窗
 */
public class SettingDialog extends VideoGroupBaseDialog {
    private OptionSwitchWidget mOptionButton;
    private VideoSettingOptionView videoSettingOptionView;
    private AudioSettingOptionView audioSettingOptionView;
    private int resolutionCurrentIndex = 3;
    private int fpsCurrentIndex = 4;
    /**
     * 音频选项，音乐场景默认的index
     */
    private int audioMusicQualityCurrentIndex = 1;
    /**
     * 音频选项，语音场景默认的index
     */
    private int audioVoiceQualityCurrentIndex = 1;
    private ArrayList<String> resolutionList = new ArrayList<>();
    private ArrayList<String> fpsList = new ArrayList<>();
    private ArrayList<String> audioMusicSceneList = new ArrayList<>();
    private ArrayList<String> audioVoiceSceneList = new ArrayList<>();
    //以下是需要回调给Activity的数据
    private String audioScene= AudioConstant.AudioScene.MUSIC;
    private RtcSetting rtcSetting=new RtcSetting();
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        initData();
        View rootView = inflater.inflate(R.layout.video_group_setting_dialog_layout, container, false);
        initView(rootView);
        return rootView;
    }

    private void initData() {
        resolutionList.add(VideoConstant.Resolution.RESOLUTION_160X90);
        resolutionList.add(VideoConstant.Resolution.RESOLUTION_320X180);
        resolutionList.add(VideoConstant.Resolution.RESOLUTION_640X360);
        resolutionList.add(VideoConstant.Resolution.RESOLUTION_1280X720);
        resolutionList.add(VideoConstant.Resolution.RESOLUTION_1920X1080);
        fpsList.add(VideoConstant.FPS.FPS_7);
        fpsList.add(VideoConstant.FPS.FPS_10);
        fpsList.add(VideoConstant.FPS.FPS_15);
        fpsList.add(VideoConstant.FPS.FPS_24);
        fpsList.add(VideoConstant.FPS.FPS_30);
        audioMusicSceneList.add(AudioConstant.AudioQuality.SD);
        audioMusicSceneList.add(AudioConstant.AudioQuality.HD);
        audioMusicSceneList.add(AudioConstant.AudioQuality.ACME);

        audioVoiceSceneList.add(AudioConstant.AudioQuality.GENERAL);
        audioVoiceSceneList.add(AudioConstant.AudioQuality.SD);
        audioVoiceSceneList.add(AudioConstant.AudioQuality.HD);
    }

    protected void initView(View rootView) {
        mOptionButton = rootView.findViewById(R.id.option_switch);
        videoSettingOptionView = rootView.findViewById(R.id.video_option);
        audioSettingOptionView = rootView.findViewById(R.id.audio_option);
        videoSettingOptionView.setResolutionAndFpsSelectedListener(new VideoSettingOptionView.ResolutionAndFpsSelectedListener() {
            @Override
            public void showResolutionSelectedWheel(String currentResolution) {
                showResolutionSelectedDialog();
            }

            @Override
            public void showFpsSelectedWheel(String currentFps) {
                showFpsSelectedDialog();
            }
        });
        audioSettingOptionView.setAudioSceneAndQualitySelectedListener(new AudioSettingOptionView.AudioSceneAndQualitySelectedListener() {


            @Override
            public void audioSceneSelected(String scene) {
                if (!audioScene.equals(scene)){
                    //与上一次选择的不一样，则改为默认选项
                    audioMusicQualityCurrentIndex=1;
                    audioVoiceQualityCurrentIndex=1;
                    if (AudioConstant.AudioScene.MUSIC.equals(scene)){
                        audioSettingOptionView.setAudioQuality(AudioConstant.AudioQuality.HD);
                    }else if (AudioConstant.AudioScene.SPEECH.equals(scene)){
                        audioSettingOptionView.setAudioQuality(AudioConstant.AudioQuality.SD);
                    }
                }
                audioScene=scene;
                rtcSetting.audioScene=audioScene;
            }

            @Override
            public void audioQualitySelected(String quality) {
                showAudioQualitySelectedDialog();
            }
        });
        mOptionButton.setOnOptionSelectedListener((view, position) -> {
            if (position == 0) {
                videoSettingOptionView.setVisibility(View.VISIBLE);
                audioSettingOptionView.setVisibility(View.GONE);
            } else {
                videoSettingOptionView.setVisibility(View.GONE);
                audioSettingOptionView.setVisibility(View.VISIBLE);
            }
        });
    }

    /**
     * 展示分辨率选项
     */
    private void showResolutionSelectedDialog() {
        WheelSelectedDialog wheelSelectedDialog = new WheelSelectedDialog();

        Bundle bundle = new Bundle();
        bundle.putStringArrayList(WheelSelectedDialog.DATA_KEY, resolutionList);
        bundle.putInt(WheelSelectedDialog.CURRENT_INDEX_KEY, resolutionCurrentIndex);
        wheelSelectedDialog.setArguments(bundle);
        wheelSelectedDialog.show(getChildFragmentManager(), getClass().getSimpleName());
        wheelSelectedDialog.setOnItemSelectedCallback(index -> {
            resolutionCurrentIndex = index;
            videoSettingOptionView.setVideoResolution(resolutionList.get(index));
            rtcSetting.resolution=resolutionList.get(index);
        });
    }

    /**
     * 展示帧率选项
     */
    private void showFpsSelectedDialog() {
        WheelSelectedDialog wheelSelectedDialog = new WheelSelectedDialog();
        Bundle bundle = new Bundle();
        bundle.putStringArrayList(WheelSelectedDialog.DATA_KEY, fpsList);
        bundle.putInt(WheelSelectedDialog.CURRENT_INDEX_KEY, fpsCurrentIndex);
        wheelSelectedDialog.setArguments(bundle);
        wheelSelectedDialog.show(getChildFragmentManager(), getClass().getSimpleName());
        wheelSelectedDialog.setOnItemSelectedCallback(index -> {
            fpsCurrentIndex = index;
            videoSettingOptionView.setVideoFps(fpsList.get(index));
            rtcSetting.fps=fpsList.get(index);
        });
    }

    /**
     * 展示音质选项
     */
    private void showAudioQualitySelectedDialog() {
        WheelSelectedDialog wheelSelectedDialog = new WheelSelectedDialog();
        Bundle bundle = new Bundle();
        if (AudioConstant.AudioScene.MUSIC.equals(audioScene)){
            bundle.putStringArrayList(WheelSelectedDialog.DATA_KEY, audioMusicSceneList);
            bundle.putInt(WheelSelectedDialog.CURRENT_INDEX_KEY, audioMusicQualityCurrentIndex);
        }else if (AudioConstant.AudioScene.SPEECH.equals(audioScene)){
            bundle.putStringArrayList(WheelSelectedDialog.DATA_KEY, audioVoiceSceneList);
            bundle.putInt(WheelSelectedDialog.CURRENT_INDEX_KEY, audioVoiceQualityCurrentIndex);
        }

        wheelSelectedDialog.setArguments(bundle);
        wheelSelectedDialog.show(getChildFragmentManager(), getClass().getSimpleName());
        wheelSelectedDialog.setOnItemSelectedCallback(index -> {
            if (AudioConstant.AudioScene.MUSIC.equals(audioScene)){
                audioMusicQualityCurrentIndex =index;
                audioSettingOptionView.setAudioQuality(audioMusicSceneList.get(index));
                rtcSetting.audioQuality=audioMusicSceneList.get(index);
            }else if (AudioConstant.AudioScene.SPEECH.equals(audioScene)){
                audioVoiceQualityCurrentIndex =index;
                audioSettingOptionView.setAudioQuality(audioVoiceSceneList.get(index));
                rtcSetting.audioQuality=audioVoiceSceneList.get(index);
            }

        });
    }

    public RtcSetting getRtcSetting() {
        return rtcSetting;
    }
}
