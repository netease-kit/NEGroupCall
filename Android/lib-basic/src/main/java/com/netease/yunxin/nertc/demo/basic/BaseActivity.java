package com.netease.yunxin.nertc.demo.basic;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.IdRes;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.gyf.immersionbar.ImmersionBar;
import com.netease.yunxin.nertc.demo.user.CommonUserNotify;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserCenterServiceNotify;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

public class BaseActivity extends AppCompatActivity {
    private final UserCenterService userCenterService = ModuleServiceMgr.getInstance().getService(UserCenterService.class);
    private final UserCenterServiceNotify loginNotify = new CommonUserNotify() {

        @Override
        public void onUserLogout(boolean success, int code) {
            if (success && !ignoredLoginEvent()) {
                finish();
            }
        }
    };

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        userCenterService.registerLoginObserver(loginNotify, true);
        StatusBarConfig config = provideStatusBarConfig();
        if (config != null) {
            ImmersionBar bar = ImmersionBar.with(this)
                    .statusBarDarkFont(config.darkFont)
                    .statusBarColor(config.barColor);
            if (config.fits) {
                bar.fitsSystemWindows(true);
            }
            if (config.fullScreen) {
                bar.fullScreen(true);
            }
            bar.init();
        }
    }

    @Override
    protected void onDestroy() {
        userCenterService.registerLoginObserver(loginNotify, false);
        super.onDestroy();
    }

    protected StatusBarConfig provideStatusBarConfig() {
        return null;
    }

    protected boolean ignoredLoginEvent() {
        return false;
    }

    protected final void paddingStatusBarHeight(View view) {
        StatusBarConfig.paddingStatusBarHeight(this, view);
    }

    protected final void paddingStatusBarHeight(@IdRes int rootViewId) {
        paddingStatusBarHeight(findViewById(rootViewId));
    }
}
