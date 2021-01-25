package com.netease.biz_live.yunxin.live.dialog;

import android.view.View;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import com.netease.biz_live.R;

/**
 * 美颜Dialog
 */
public class BeautyDialog extends BaseBottomDialog implements SeekBar.OnSeekBarChangeListener {

    private SeekBar sbBeautyWhite;

    private SeekBar sbBeautySkin;

    private SeekBar sbThinFace;

    private SeekBar sbBigEye;

    private TextView tvBeautyWhiteValue;

    private TextView tvBeautySkinValue;

    private TextView tvThinFaceValue;

    private TextView tvBigEyeValue;

    private ImageView ivReset;

    private BeautyValueChangeListener valueChangeListener;

    //*******************美颜参数*******************
    private float mColorLevel = 0.3f;//美白

    private float mBlurLevel = 0.7f;//磨皮程度

    private float mCheekThinning = 0f;//瘦脸

    private float mEyeEnlarging = 0.4f;//大眼
    //*****************美颜默认参数******************
    private static final float mColorLevelDefault = 0.3f;//美白

    private static final float mBlurLevelDefault = 0.7f;//磨皮程度

    private static final float mCheekThinningDefault = 0f;//瘦脸

    private static final float mEyeEnlargingDefault = 0.4f;//大眼

    @Override
    protected int getResourceLayout() {
        return R.layout.beauty_dialog_layout;
    }

    @Override
    protected void initView(View rootView) {
        super.initView(rootView);

        ivReset = rootView.findViewById(R.id.iv_reset);
        ivReset.setOnClickListener(view -> {
            resetBeauty();
        });

        tvBeautyWhiteValue = rootView.findViewById(R.id.tv_beauty_white_value);
        sbBeautyWhite = rootView.findViewById(R.id.sb_beauty_white);
        sbBeautyWhite.setOnSeekBarChangeListener(this);

        tvBeautySkinValue = rootView.findViewById(R.id.tv_beauty_skin_value);
        sbBeautySkin = rootView.findViewById(R.id.sb_beauty_skin);
        sbBeautySkin.setOnSeekBarChangeListener(this);

        tvThinFaceValue = rootView.findViewById(R.id.tv_thin_face_value);
        sbThinFace = rootView.findViewById(R.id.sb_thin_face);
        sbThinFace.setOnSeekBarChangeListener(this);

        tvBigEyeValue = rootView.findViewById(R.id.tv_big_eye_value);
        sbBigEye = rootView.findViewById(R.id.sb_big_eye);
        sbBigEye.setOnSeekBarChangeListener(this);
    }

    public void setValueChangeListener(BeautyValueChangeListener beautyValueChangeListener) {
        this.valueChangeListener = beautyValueChangeListener;
    }

    /**
     * 恢复默认
     */
    private void resetBeauty() {
        this.mColorLevel = mColorLevelDefault;
        this.mBlurLevel = mBlurLevelDefault;
        this.mCheekThinning = mCheekThinningDefault;
        this.mEyeEnlarging = mEyeEnlargingDefault;
        setSbProcess();
    }

    /**
     * 设置美颜参数
     *
     * @param mColorLevel
     * @param mBlurLevel
     * @param mCheekThinning
     * @param mEyeEnlarging
     */
    public void setBeautyParams(float mColorLevel,
                                float mBlurLevel, float mCheekThinning, float mEyeEnlarging) {
        this.mColorLevel = mColorLevel;
        this.mBlurLevel = mBlurLevel;
        this.mCheekThinning = mCheekThinning;
        this.mEyeEnlarging = mEyeEnlarging;
    }

    @Override
    protected void initData() {
        setSbProcess();
    }

    private void setSbProcess() {
        sbBeautyWhite.setProgress((int) (mColorLevel * 100));
        sbBeautySkin.setProgress((int) (mBlurLevel * 100));
        sbThinFace.setProgress((int) (mCheekThinning * 100));
        sbBigEye.setProgress((int) (mEyeEnlarging * 100));
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        if (valueChangeListener != null) {
            valueChangeListener.beautyValueChange(setValueGetType(seekBar, progress), progress);
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }

    /**
     * 设置变量数值，并返回type，在value变化时调用
     *
     * @param seekBar
     * @return
     */
    private int setValueGetType(SeekBar seekBar, int value) {
        String text = String.valueOf(value/100f);
        if (seekBar == sbBeautyWhite) {
            tvBeautyWhiteValue.setText(text);
            return BeautyValueChangeListener.BEAUTY_WHITE;
        } else if (seekBar == sbBeautySkin) {
            tvBeautySkinValue.setText(text);
            return BeautyValueChangeListener.BEAUTY_SKIN;
        } else if (seekBar == sbThinFace) {
            tvThinFaceValue.setText(text);
            return BeautyValueChangeListener.THIN_FACE;
        } else if (seekBar == sbBigEye) {
            tvBigEyeValue.setText(text);
            return BeautyValueChangeListener.BIG_EYE;
        }
        return 0;
    }

    public interface BeautyValueChangeListener {

        int BEAUTY_WHITE = 1;

        int BEAUTY_SKIN = 2;

        int THIN_FACE = 3;

        int BIG_EYE = 4;

        void beautyValueChange(int type, int newValue);
    }
}
