package com.netease.yunxin.nertc.demo.user;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.netease.yunxin.nertc.demo.BuildConfig;
import com.netease.yunxin.nertc.demo.R;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.CommonBrowseActivity;
import com.netease.yunxin.nertc.demo.basic.Constants;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;

public class AppAboutActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_app_about);
        paddingStatusBarHeight(findViewById(R.id.cl_root));
        initViews();
    }

    private void initViews() {
        View close = findViewById(R.id.iv_close);
        close.setOnClickListener(v -> finish());

        TextView appVersion = findViewById(R.id.tv_app_version);
        appVersion.setText("v"+BuildConfig.VERSION_NAME);

        TextView imVersion = findViewById(R.id.tv_im_version);
        imVersion.setText("v"+BuildConfig.VERSION_IM);

        TextView nertcVersion = findViewById(R.id.tv_g2_version);
        nertcVersion.setText("v"+BuildConfig.VERSION_NERTC);

        View privacy = findViewById(R.id.tv_privacy);
        privacy.setOnClickListener(v -> CommonBrowseActivity.launch(AppAboutActivity.this, "隐私政策", Constants.URL_PRIVACY));

        View userPolice = findViewById(R.id.tv_user_police);
        userPolice.setOnClickListener(v -> CommonBrowseActivity.launch(AppAboutActivity.this, "用户协议", Constants.URL_USER_POLICE));


        View disclaimer = findViewById(R.id.tv_disclaimer);
        disclaimer.setOnClickListener(v -> CommonBrowseActivity.launch(AppAboutActivity.this, "免责声明", Constants.URL_DISCLAIMER));
    }

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(false)
                .build();
    }
}