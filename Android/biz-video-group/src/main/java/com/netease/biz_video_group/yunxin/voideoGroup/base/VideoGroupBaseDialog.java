package com.netease.biz_video_group.yunxin.voideoGroup.base;

import android.content.DialogInterface;
import android.view.Gravity;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import androidx.fragment.app.DialogFragment;

import com.netease.biz_video_group.R;

/**
 * @author sunkeding
 * 封装一些公关的属性、方法
 */
public class VideoGroupBaseDialog extends DialogFragment {
    private DialogInterface.OnDismissListener mOnClickListener;

    public void setOnDismissListener(DialogInterface.OnDismissListener listener) {
        this.mOnClickListener = listener;
    }

    @Override
    public void onDismiss(DialogInterface dialog) {
        super.onDismiss(dialog);
        if (mOnClickListener != null) {
            mOnClickListener.onDismiss(dialog);
        }
    }

        @Override
    public void onStart() {
        super.onStart();
        initParams();
    }

    public void initParams() {
        Window window = getDialog().getWindow();
        if (window != null) {
            window.setBackgroundDrawableResource(R.drawable.white_bottom_dialog_bg);
            WindowManager.LayoutParams params = window.getAttributes();
            params.gravity = Gravity.BOTTOM;
            // 使用ViewGroup.LayoutParams，以便Dialog 宽度充满整个屏幕
            params.width = ViewGroup.LayoutParams.MATCH_PARENT;
            params.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            params.windowAnimations=R.style.VideoGroup_dialog_fragment_animation;
            window.setAttributes(params);
        }
        setCancelable(true);//设置点击外部是否消失
    }
}
