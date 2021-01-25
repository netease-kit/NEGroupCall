package com.netease.biz_live.yunxin.live.dialog;

import android.view.View;
import android.widget.SeekBar;
import android.widget.TextView;

import com.netease.biz_live.R;

/**
 * 音量控制dialog
 */
public class AudioControlDialog extends BaseBottomDialog {

    private TextView tvMusic1;

    private TextView tvMusic2;

    private TextView tvEffect1;

    private TextView tvEffect2;

    private SeekBar sbrMusicVolume;

    private SeekBar sbrEffectVolume;

    private int musicVolume;//背景音乐音量

    private int effectVolume;//音效音量

    private DialogActionsCallBack callBack;

    private int musicIndex = -1;

    private int[] effectIndex;

    @Override
    protected int getResourceLayout() {
        return R.layout.audio_contril_dialog_layout;
    }

    @Override
    protected void initView(View rootView) {
        tvMusic1 = rootView.findViewById(R.id.tv_music_1);
        tvMusic2 = rootView.findViewById(R.id.tv_music_2);
        tvEffect1 = rootView.findViewById(R.id.tv_audio_effect_1);
        tvEffect2 = rootView.findViewById(R.id.tv_audio_effect_2);
        sbrMusicVolume = rootView.findViewById(R.id.music_song_volume_control);
        sbrEffectVolume = rootView.findViewById(R.id.audio_effect_volume_control);
        super.initView(rootView);
    }

    @Override
    protected void initData() {
        //初始化数据设置view
        if (musicIndex == 0) {
            tvMusic1.setSelected(true);
        } else if (musicIndex == 1) {
            tvMusic2.setSelected(true);
        }
        sbrMusicVolume.setProgress(musicVolume);
        sbrEffectVolume.setProgress(effectVolume);
        if (effectIndex != null) {
            for (int i = 0; i < effectIndex.length; i++) {
                if (i == 0 && effectIndex[i] == 1) {
                    tvEffect1.setSelected(true);
                }
                if (i == 1 && effectIndex[i] == 1) {
                    tvEffect2.setSelected(true);
                }
            }
        }
        //======================伴音(背景音乐)控制=======================
        tvMusic1.setOnClickListener(v -> {
            if (callBack != null) {
                if (!tvMusic1.isSelected()) {
                    tvMusic1.setSelected(callBack.setMusicPlay(0));
                } else {
                    callBack.stopMusicPlay();
                    tvMusic1.setSelected(!tvMusic1.isSelected());
                }
            }

            tvMusic2.setSelected(false);
        });

        tvMusic2.setOnClickListener(v -> {
            if (callBack != null) {
                if (!tvMusic2.isSelected()) {
                    tvMusic2.setSelected(callBack.setMusicPlay(1));
                } else {
                    callBack.stopMusicPlay();
                    tvMusic2.setSelected(!tvMusic2.isSelected());
                }
            }
            tvMusic1.setSelected(false);
        });

        sbrMusicVolume.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (callBack != null) {
                    callBack.onMusicVolumeChange(progress);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        //====================音效控制======================
        tvEffect1.setOnClickListener(v -> {
            if (!tvEffect1.isSelected()) {
                if (callBack != null) {
                    tvEffect1.setSelected(callBack.addEffect(0));
                }
            } else {
                if (callBack != null) {
                    tvEffect1.setSelected(!callBack.stopEffect(0));
                }
            }
            tvEffect2.setSelected(false);
        });

        tvEffect2.setOnClickListener(v -> {
            if (!tvEffect2.isSelected()) {
                if (callBack != null) {
                    tvEffect2.setSelected(callBack.addEffect(1));
                }
            } else {
                if (callBack != null) {
                    tvEffect2.setSelected(!callBack.stopEffect(1));
                }
            }
            tvEffect1.setSelected(false);
        });

        sbrEffectVolume.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

                if (callBack != null) {
                    int[] index = new int[2];
                    index[0] = tvEffect1.isSelected() ? 1 : 0;
                    index[1] = tvEffect2.isSelected() ? 1 : 0;
                    callBack.onEffectVolumeChange(progress, index);
                }

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        super.initData();
    }

    public void setCallBack(DialogActionsCallBack callBack) {
        this.callBack = callBack;
    }

    public void setInitData(int musicIndex, int[] effectIndex, int musicVolume, int effectVolume) {
        this.musicIndex = musicIndex;
        this.effectIndex = effectIndex;
        this.musicVolume = musicVolume;
        this.effectVolume = effectVolume;
    }

    public void onMixingFinished(){
        tvMusic1.setSelected(false);
        tvMusic1.setSelected(false);
    }

    public void onEffectFinish(int id){
        switch (id){
            case 1:
                tvEffect1.setSelected(false);
            case 2:
                tvEffect2.setSelected(false);
        }
    }

    public interface DialogActionsCallBack {
        boolean setMusicPlay(int index);

        void onMusicVolumeChange(int progress);

        boolean addEffect(int index);

        void onEffectVolumeChange(int progress, int[] index);

        boolean stopEffect(int index);

        void stopMusicPlay();
    }
}
