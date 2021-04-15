package com.netease.yunxin.nertc.demo;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.demo.user.CommonUserNotify;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import androidx.annotation.Nullable;

public class SplashActivity extends BaseActivity {

    private static final String TAG = "SplashActivity";


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (!this.isTaskRoot()) {
            Intent mainIntent = getIntent();
            String action = mainIntent.getAction();
            if (mainIntent.hasCategory(Intent.CATEGORY_LAUNCHER) && Intent.ACTION_MAIN.equals(action)) {
                finish();
                return;
            }
        }
        setContentView(R.layout.activity_splash);
        UserCenterService service = ModuleServiceMgr.getInstance().getService(UserCenterService.class);
        service.tryLogin(new CommonUserNotify() {
            @Override
            public void onUserLogin(boolean success, int code) {
                if (success) {
                    navigationMain();
                } else {
                    service.launchLogin(SplashActivity.this);
                }
                finish();
            }

            @Override
            public void onError(Throwable exception) {
                service.launchLogin(SplashActivity.this);
                finish();
            }
        });
    }


    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        Log.d(TAG, "onNewIntent: intent -> " + intent.getData());
        setIntent(intent);
    }

    private void navigationMain() {
        Intent intent = new Intent(this, MainActivity.class);
        startActivity(intent);
        finish();
    }

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(true)
                .fullScreen(true)
                .build();
    }
}
