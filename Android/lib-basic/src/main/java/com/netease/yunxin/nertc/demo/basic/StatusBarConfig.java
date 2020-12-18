package com.netease.yunxin.nertc.demo.basic;

import android.app.Activity;
import android.view.View;

import androidx.annotation.ColorRes;

import com.gyf.immersionbar.ImmersionBar;

/**
 * Created by luc on 2020/11/12.
 */
public final class StatusBarConfig {
    public final boolean fits;
    public final boolean darkFont;
    public final boolean fullScreen;
    public final int barColor;

    public StatusBarConfig(boolean fits, boolean darkFont, boolean fullScreen, int barColor) {
        this.fits = fits;
        this.darkFont = darkFont;
        this.fullScreen = fullScreen;
        this.barColor = barColor;
    }

    public static class Builder {
        private boolean fits = false;
        private boolean darkFont = false;
        private boolean fullScreen = false;
        private int barColor = android.R.color.transparent;


        public Builder fitsSystemWindow(boolean fits) {
            this.fits = fits;
            return this;
        }

        public Builder statusBarDarkFont(boolean dark) {
            this.darkFont = dark;
            return this;
        }

        public Builder statusBarColor(@ColorRes int color) {
            this.barColor = color;
            return this;
        }

        public Builder fullScreen(boolean full) {
            this.fullScreen = full;
            return this;
        }

        public StatusBarConfig build() {
            return new StatusBarConfig(fits, darkFont, fullScreen, barColor);
        }
    }

    public static void paddingStatusBarHeight(Activity activity, View view) {
        if (view == null) {
            return;
        }
        int barHeight = getStatusBarHeight(activity);
        view.setPadding(view.getPaddingLeft(), view.getPaddingTop() + barHeight,
                view.getPaddingRight(), view.getPaddingBottom());
    }

    public static int getStatusBarHeight(Activity activity) {
        return ImmersionBar.getStatusBarHeight(activity);
    }
}
