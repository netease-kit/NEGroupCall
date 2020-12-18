package com.netease.yunxin.nertc.demo.user;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.yunxin.nertc.demo.R;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.demo.picture.ImageLoader;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

public class UserInfoActivity extends BaseActivity {
    private final UserCenterService service = ModuleServiceMgr.getInstance().getService(UserCenterService.class);
    private final UserCenterServiceNotify notify = new CommonUserNotify() {
        @Override
        public void onUserInfoUpdate(UserModel model) {
            currentUser = model;
            initUser();
        }
    };
    private UserModel currentUser;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        service.registerLoginObserver(notify, true);
        setContentView(R.layout.activity_user_info);
        currentUser = service.getCurrentUser();
        initViews();
        paddingStatusBarHeight(findViewById(R.id.cl_root));
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        service.registerLoginObserver(notify, false);
    }

    private void initViews() {
        View logout = findViewById(R.id.tv_logout);
        logout.setOnClickListener(v -> service.launchLogout(this,
                UserCenterService.LOGOUT_DIALOG_TYPE_NORMAL, new CommonUserNotify() {
                    @Override
                    public void onUserLogout(boolean success, int code) {
                        if (success) {
                            UserInfoActivity.this.finish();
                        }
                    }
                }));


        View close = findViewById(R.id.iv_close);
        close.setOnClickListener(v -> finish());

        initUser();
    }

    private void initUser() {
        ImageView ivUserPortrait = findViewById(R.id.iv_user_portrait);
        ImageLoader.with(getApplicationContext()).circleLoad(currentUser.avatar, ivUserPortrait);

        TextView tvNickname = findViewById(R.id.tv_nick_name);
        tvNickname.setOnClickListener(v -> startActivity(new Intent(UserInfoActivity.this, EditUserInfoActivity.class)));
        tvNickname.setText(currentUser.getNickname());
    }

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(false)
                .build();
    }
}