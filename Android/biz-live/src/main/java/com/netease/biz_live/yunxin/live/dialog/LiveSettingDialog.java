package com.netease.biz_live.yunxin.live.dialog;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.biz_live.R;
import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.video.NERtcVideoConfig;

/**
 * 开播前设置Dialog
 */
public class LiveSettingDialog extends BaseBottomDialog {

    private TextView tv1080P;

    private TextView tv720P;

    private TextView tv360P;

    private TextView tv30;

    private TextView tv24;

    private TextView tv15;

    private TextView tvNormal;

    private TextView tvMusic;

    private ImageView ivReset;

    private LiveSettingChangeListener valueChangeListener;

    //*******************直播参数*******************
    private int videoProfile = NERtcConstants.VideoProfile.HD720P;//视频分辨率

    private NERtcVideoConfig.NERtcVideoFrameRate frameRate = NERtcVideoConfig.NERtcVideoFrameRate.FRAME_RATE_FPS_30;//码率

    private int audioScenario = NERtcConstants.AudioScenario.MUSIC;//音频标准

    //*****************直播默认参数******************
    private static final int videoProfileDefault = NERtcConstants.VideoProfile.HD720P;//视频分辨率

    private static final NERtcVideoConfig.NERtcVideoFrameRate frameRateDefaul = NERtcVideoConfig.NERtcVideoFrameRate.FRAME_RATE_FPS_30;//码率

    private static final int audioScenarioDefaul = NERtcConstants.AudioScenario.MUSIC;//音频标准

    @Override
    protected int getResourceLayout() {
        return R.layout.live_setting_dialog_layout;
    }

    @Override
    protected void initView(View rootView) {
        super.initView(rootView);

        ivReset = rootView.findViewById(R.id.iv_reset);
        ivReset.setOnClickListener(view -> {
            resetBeauty();
        });

        tv1080P = rootView.findViewById(R.id.tv_1080p);
        tv1080P.setOnClickListener(view -> {
            tv1080P.setSelected(true);
            tv720P.setSelected(false);
            tv360P.setSelected(false);
            if (valueChangeListener != null) {
                valueChangeListener.videoProfileChange(NERtcConstants.VideoProfile.HD1080p);
            }
        });
        tv720P = rootView.findViewById(R.id.tv_720p);
        tv720P.setOnClickListener(view -> {
            tv720P.setSelected(true);
            tv1080P.setSelected(false);
            tv360P.setSelected(false);
            if (valueChangeListener != null) {
                valueChangeListener.videoProfileChange(NERtcConstants.VideoProfile.HD720P);
            }
        });
        tv360P = rootView.findViewById(R.id.tv_360p);
        tv360P.setOnClickListener(view -> {
            tv360P.setSelected(true);
            tv1080P.setSelected(false);
            tv720P.setSelected(false);
            if (valueChangeListener != null) {
                valueChangeListener.videoProfileChange(NERtcConstants.VideoProfile.STANDARD);
            }
        });
        tv30 = rootView.findViewById(R.id.tv_30);
        tv30.setOnClickListener(view -> {
            tv30.setSelected(true);
            tv24.setSelected(false);
            tv15.setSelected(false);
            if (valueChangeListener != null) {
                valueChangeListener.frameRateChange(NERtcVideoConfig.NERtcVideoFrameRate.FRAME_RATE_FPS_30);
            }
        });
        tv24 = rootView.findViewById(R.id.tv_24);
        tv24.setOnClickListener(view -> {
            tv30.setSelected(false);
            tv24.setSelected(true);
            tv15.setSelected(false);
            if (valueChangeListener != null) {
                valueChangeListener.frameRateChange(NERtcVideoConfig.NERtcVideoFrameRate.FRAME_RATE_FPS_24);
            }
        });
        tv15 = rootView.findViewById(R.id.tv_15);
        tv15.setOnClickListener(view -> {
            tv30.setSelected(false);
            tv24.setSelected(false);
            tv15.setSelected(true);
            if (valueChangeListener != null) {
                valueChangeListener.frameRateChange(NERtcVideoConfig.NERtcVideoFrameRate.FRAME_RATE_FPS_15);
            }
        });
        tvMusic = rootView.findViewById(R.id.tv_music);
        tvMusic.setOnClickListener(view -> {
            tvMusic.setSelected(true);
            tvNormal.setSelected(false);
            if (valueChangeListener != null) {
                valueChangeListener.audioScenarioChange(NERtcConstants.AudioScenario.MUSIC);
            }
        });
        tvNormal = rootView.findViewById(R.id.tv_normal);
        tvNormal.setOnClickListener(view -> {
            tvMusic.setSelected(false);
            tvNormal.setSelected(true);
            if (valueChangeListener != null) {
                valueChangeListener.audioScenarioChange(NERtcConstants.AudioScenario.DEFAULT);
            }
        });

    }

    public void setValueChangeListener(LiveSettingChangeListener liveSettingChangeListener) {
        this.valueChangeListener = liveSettingChangeListener;
    }

    /**
     * 恢复默认
     */
    private void resetBeauty() {
        tv360P.setSelected(false);
        tv1080P.setSelected(false);
        tv720P.setSelected(true);
        tv30.setSelected(true);
        tv24.setSelected(false);
        tv15.setSelected(false);
        tvMusic.setSelected(true);
        tvNormal.setSelected(false);
        if (valueChangeListener != null) {
            valueChangeListener.audioScenarioChange(audioScenarioDefaul);
            valueChangeListener.frameRateChange(frameRateDefaul);
            valueChangeListener.videoProfileChange(videoProfileDefault);
        }
    }

    /**
     * 设置已有的直播参数
     *
     * @param videoProfile
     * @param frameRate
     * @param audioScenario
     */
    public void setLiveSetting(int videoProfile,
                               NERtcVideoConfig.NERtcVideoFrameRate frameRate, int audioScenario) {
        this.videoProfile = videoProfile;
        this.frameRate = frameRate;
        this.audioScenario = audioScenario;
    }

    @Override
    protected void initData() {
        switch (videoProfile) {
            case NERtcConstants.VideoProfile.STANDARD:
                tv360P.setSelected(true);
                break;
            case NERtcConstants.VideoProfile.HD720P:
                tv720P.setSelected(true);
                break;
            case NERtcConstants.VideoProfile.HD1080p:
                tv1080P.setSelected(true);
                break;
            default:
                break;
        }
        switch (frameRate) {
            case FRAME_RATE_FPS_15:
                tv15.setSelected(true);
                break;
            case FRAME_RATE_FPS_24:
                tv24.setSelected(true);
                break;
            case FRAME_RATE_FPS_30:
            default:
                tv30.setSelected(true);
                break;
        }

        switch (audioScenario) {
            case NERtcConstants.AudioScenario.MUSIC:
                tvMusic.setSelected(true);
                break;
            case NERtcConstants.AudioScenario.DEFAULT:
            default:
                tvNormal.setSelected(true);
                break;
        }
    }

    /**
     * 直播设置回调
     */
    public interface LiveSettingChangeListener {

        void videoProfileChange(int newValue);

        void frameRateChange(NERtcVideoConfig.NERtcVideoFrameRate frameRate);

        void audioScenarioChange(int audioScenario);
    }
}
