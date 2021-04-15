package com.netease.biz_live.yunxin.live.audience.ui.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;

import com.netease.biz_live.R;
import com.netease.yunxin.android.lib.historian.Historian;

import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;


/**
 * 底部弹窗基类，子类需要实现 顶部view，以及底部view 的渲染即可
 */
public abstract class BottomBaseDialog extends Dialog {
    protected Activity activity;
    protected View rootView;

    public BottomBaseDialog(@NonNull Activity activity) {
        super(activity, R.style.BottomDialogTheme);
        this.activity = activity;
        rootView = LayoutInflater.from(getContext()).inflate(contentLayoutId(), null);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final Window window = getWindow();
        if (window != null) {
            window.getDecorView().setPadding(0, 0, 0, 0);
            WindowManager.LayoutParams wlp = window.getAttributes();
            wlp.gravity = Gravity.BOTTOM;
            wlp.width = WindowManager.LayoutParams.MATCH_PARENT;
            wlp.height = WindowManager.LayoutParams.WRAP_CONTENT;
            window.setAttributes(wlp);
        }

        setContentView(rootView);
        setCanceledOnTouchOutside(true);
    }

    protected @LayoutRes
    int contentLayoutId() {
        return R.layout.view_dialog_utils_base;
    }

    /**
     * 页面渲染
     */
    protected void renderRootView(View rootView) {
        if (rootView == null) {
            return;
        }
        renderTopView(rootView.findViewById(R.id.fl_dialog_top));
        renderBottomView(rootView.findViewById(R.id.fl_dialog_bottom));
    }

    /**
     * 渲染dialog顶部UI
     *
     * @param parent UI 容器
     */
    protected abstract void renderTopView(FrameLayout parent);

    /**
     * 渲染dialog底部UI
     *
     * @param parent UI 容器
     */
    protected abstract void renderBottomView(FrameLayout parent);

    @Override
    public void show() {
        if (isShowing()) {
            return;
        }
        renderRootView(rootView);
        try {
            super.show();
        } catch (WindowManager.BadTokenException e) {
            Historian.e(this.getClass().getSimpleName(), "error message is :" + e.getMessage());
        }
    }
}
