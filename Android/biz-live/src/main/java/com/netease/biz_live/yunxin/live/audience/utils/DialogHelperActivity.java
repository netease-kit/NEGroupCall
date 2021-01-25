package com.netease.biz_live.yunxin.live.audience.utils;

import android.os.Bundle;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.dialog.NotificationDialog;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;

public class DialogHelperActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_transparen_helper);

        new NotificationDialog(this)
                .setTitle("已被其他设备踢出")
                .setContent("暂不支持多台设备进入同一直播间，\n您可以去其他直播间转转～")
                .setPositive("确认", v -> finish()).show();

    }

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(false)
                .build();
    }
}