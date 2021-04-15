package com.netease.biz_live.yunxin.live.ui;

import android.hardware.Camera;

import androidx.fragment.app.FragmentActivity;

import com.faceunity.FURenderer;
import com.netease.biz_live.yunxin.live.dialog.BeautyDialog;
import com.netease.biz_live.yunxin.live.dialog.FilterDialog;
import com.netease.biz_live.yunxin.live.liveroom.model.NERTCLiveRoom;
import com.netease.lava.nertc.sdk.video.NERtcVideoFrame;

/**
 * 美颜相关控制
 */
public class BeautyControl {

    private FragmentActivity activity;
    private NERTCLiveRoom liveRoom;
    private FURenderer mFuRender;//美颜效果
    //*******************美颜参数*******************
    private float mColorLevel = 0.3f;//美白

    private float mBlurLevel = 0.7f;//磨皮程度

    private float mCheekThinning = 0f;//瘦脸

    private float mEyeEnlarging = 0.4f;//大眼

    public BeautyControl(FragmentActivity activity, NERTCLiveRoom liveRoom) {
        this.activity = activity;
        this.liveRoom = liveRoom;
    }

    public void initFaceUI() {
        mFuRender = new FURenderer
                .Builder(activity)
                .maxFaces(1)
                .inputImageOrientation(getCameraOrientation(Camera.CameraInfo.CAMERA_FACING_FRONT))
                .inputTextureType(FURenderer.FU_ADM_FLAG_EXTERNAL_OES_TEXTURE)
                .build();
        mFuRender.onSurfaceCreated();
        mFuRender.setBeautificationOn(true);
    }

    public void openBeauty() {
        liveRoom.setVideoCallback(neRtcVideoFrame -> {
            //此处可自定义第三方的美颜实现
            neRtcVideoFrame.textureId = mFuRender.onDrawFrame(neRtcVideoFrame.data, neRtcVideoFrame.textureId,
                    neRtcVideoFrame.width, neRtcVideoFrame.height);

            neRtcVideoFrame.format = NERtcVideoFrame.Format.TEXTURE_RGB;
            return true;
        }, true);
    }

    public void switchCamera(int cameraFacing) {
        mFuRender.onCameraChange(cameraFacing, getCameraOrientation(cameraFacing));
    }

    private int getCameraOrientation(int cameraFacing) {
        Camera.CameraInfo info = new Camera.CameraInfo();
        int cameraId = -1;
        int numCameras = Camera.getNumberOfCameras();
        for (int i = 0; i < numCameras; i++) {
            Camera.getCameraInfo(i, info);
            if (info.facing == cameraFacing) {
                cameraId = i;
                break;
            }
        }
        if (cameraId < 0) {
            // no front camera, regard it as back camera
            return 90;
        } else {
            return info.orientation;
        }
    }

    /**
     * 展示美颜dialog
     */
    public void showBeautyDialog() {
        BeautyDialog beautyDialog = new BeautyDialog();
        beautyDialog.setBeautyParams(mColorLevel, mBlurLevel, mCheekThinning, mEyeEnlarging);
        beautyDialog.setValueChangeListener((type, newValue) -> {
            switch (type) {
                case BeautyDialog.BeautyValueChangeListener.BEAUTY_WHITE:
                    mColorLevel = newValue / 100f;
                    mFuRender.onColorLevelSelected(mColorLevel);
                    break;
                case BeautyDialog.BeautyValueChangeListener.BEAUTY_SKIN:
                    mBlurLevel = newValue / 100f;
                    mFuRender.onBlurLevelSelected(mBlurLevel);
                    break;
                case BeautyDialog.BeautyValueChangeListener.THIN_FACE:
                    mCheekThinning = newValue / 100f;
                    mFuRender.onCheekThinningSelected(mCheekThinning);
                    break;
                case BeautyDialog.BeautyValueChangeListener.BIG_EYE:
                    mEyeEnlarging = newValue / 100f;
                    mFuRender.onEyeEnlargeSelected(mEyeEnlarging);
                    break;
            }

        });
        beautyDialog.show(activity.getSupportFragmentManager(), "beautyDialog");
    }

    public void showFilterDialog() {
        FilterDialog filterDialog = new FilterDialog();
        filterDialog.setOnFUControlListener(mFuRender);
        filterDialog.show(activity.getSupportFragmentManager(), "filterDialog");
    }

    public void onDestroy() {
        if (mFuRender != null) {
            mFuRender.onSurfaceDestroyed();
            mFuRender = null;
        }
    }
}
