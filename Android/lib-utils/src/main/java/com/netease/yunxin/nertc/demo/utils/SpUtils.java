package com.netease.yunxin.nertc.demo.utils;

import android.content.Context;

/**
 * Created by luc on 2020/11/11.
 */
public final class SpUtils {

    /**
     * 获取屏幕宽度
     *
     * @param context 上下文
     */
    public static int getScreenWidth(Context context) {
        return context.getResources().getDisplayMetrics().widthPixels;
    }

    /**
     * 获取屏幕高度
     *
     * @param context 上下文
     */
    public static int getScreenHeight(Context context) {
        return context.getResources().getDisplayMetrics().heightPixels;
    }

    /**
     * dp 转换成 pixel
     */
    public static int dp2pix(Context context, float dp) {
        float density = context.getResources().getDisplayMetrics().density;
        return (int) (density * dp + 0.5f);
    }
}
