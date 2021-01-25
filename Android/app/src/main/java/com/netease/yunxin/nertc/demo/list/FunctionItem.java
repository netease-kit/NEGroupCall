package com.netease.yunxin.nertc.demo.list;

public class FunctionItem {
    public int type = FunctionAdapter.TYPE_VIEW_CONTENT;

    public final int iconResId;

    public final String nameStr;

    public final Runnable action;

    public FunctionItem(int type, String nameStr,int iconResId) {
        this.type = type;
        this.nameStr = nameStr;
        this.iconResId = iconResId;
        this.action = null;
    }

    public FunctionItem(int iconResId, String nameStr, Runnable action) {
        this.iconResId = iconResId;
        this.nameStr = nameStr;
        this.action = action;
    }
}
