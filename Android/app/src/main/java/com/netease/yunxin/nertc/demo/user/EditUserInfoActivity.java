package com.netease.yunxin.nertc.demo.user;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.yunxin.nertc.demo.R;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

public class EditUserInfoActivity extends BaseActivity {
    private final UserCenterService service = ModuleServiceMgr.getInstance().getService(UserCenterService.class);
    private UserModel currentUser;
    private String lastNickname;
    private EditText etNickname;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_user_info);
        paddingStatusBarHeight(findViewById(R.id.cl_root));
        currentUser = service.getCurrentUser();
        lastNickname = currentUser.getNickname();
        initViews();
    }

    private void initViews() {
        etNickname = findViewById(R.id.et_nick_name);
        etNickname.setText(currentUser.getNickname());

        View close = findViewById(R.id.iv_back);
        close.setOnClickListener(v -> finish());

        View clear = findViewById(R.id.iv_clear);
        clear.setOnClickListener(v -> etNickname.setText(""));

        etNickname.setOnFocusChangeListener((v, hasFocus) -> {
            boolean visible = hasFocus && !TextUtils.isEmpty(etNickname.getText().toString());
            clear.setVisibility(visible ? View.VISIBLE : View.INVISIBLE);
        });

        etNickname.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                clear.setVisibility(s.length() > 0 ? View.VISIBLE : View.INVISIBLE);
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });
    }

    private void doForUpdatingUserModel(String newNickname) {
        if (TextUtils.isEmpty(newNickname)) {
            ToastUtils.showShort("用户信息更新失败");
            return;
        }
        if (!newNickname.equals(lastNickname)) {
            currentUser.nickname = newNickname;
            service.updateUserInfo(currentUser, new CommonUserNotify() {
                @Override
                public void onUserInfoUpdate(UserModel model) {
                    ToastUtils.showShort("用户信息更新成功");
                }

                @Override
                public void onError(Throwable exception) {
                    ToastUtils.showShort("用户信息更新失败");
                }
            });
        }
    }

    @Override
    public void finish() {
        // 关闭页面前检查用户昵称决定是否更新
        doForUpdatingUserModel(etNickname.getText().toString());
        super.finish();
    }

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(false)
                .build();
    }
}