package com.netease.yunxin.nertc.demo.user.ui;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.CommonBrowseActivity;
import com.netease.yunxin.nertc.demo.basic.Constants;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.demo.user.network.UserServerImpl;
import com.netease.yunxin.nertc.user.R;

import io.reactivex.annotations.NonNull;
import io.reactivex.observers.ResourceSingleObserver;

public class LoginActivity extends BaseActivity {

    private EditText mEdtPhoneNumber;
    private Button mBtnSendMessage;

    @Override
    protected StatusBarConfig provideStatusBarConfig() {
        return new StatusBarConfig.Builder()
                .statusBarDarkFont(true)
                .statusBarColor(R.color.colorWhite)
                .fitsSystemWindow(true)
                .build();
    }

    @Override
    protected boolean ignoredLoginEvent() {
        return true;
    }

    public static void startLogin(Context context) {
        Intent intent = new Intent();
        intent.setClass(context, LoginActivity.class);
        if (!(context instanceof Activity)) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        }
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login_activity);
        initView();
    }

    private void initView() {
        mEdtPhoneNumber = findViewById(R.id.edt_phone_number);
        mBtnSendMessage = findViewById(R.id.btn_send);
        mBtnSendMessage.setOnClickListener(v -> {
            sendMsm();
        });

        TextView tvPolice = findViewById(R.id.tv_login_police);
        initPolice(tvPolice);
    }

    private void initPolice(TextView tvPolice) {
        SpannableStringBuilder builder = new SpannableStringBuilder("登录即视为您已同意 ");

        int start = builder.length();
        builder.append("隐私政策");
        builder.setSpan(new ClickableSpan() {
            @Override
            public void updateDrawState(@androidx.annotation.NonNull TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(Color.parseColor("#ff337eef"));
                ds.setUnderlineText(false);
            }

            @Override
            public void onClick(@androidx.annotation.NonNull View widget) {
                CommonBrowseActivity.launch(LoginActivity.this, "隐私政策", Constants.URL_PRIVACY);
            }
        }, start, builder.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);

        builder.append(" 和 ");

        start = builder.length();
        builder.append("用户服务协议");
        builder.setSpan(new ClickableSpan() {

            @Override
            public void updateDrawState(@androidx.annotation.NonNull TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(Color.parseColor("#ff337eef"));
                ds.setUnderlineText(false);
            }

            @Override
            public void onClick(@androidx.annotation.NonNull View widget) {
                CommonBrowseActivity.launch(LoginActivity.this, "用户协议", Constants.URL_USER_POLICE);
            }
        }, start, builder.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);

        tvPolice.setMovementMethod(LinkMovementMethod.getInstance());
        tvPolice.setText(builder);
    }

    private void sendMsm() {
        String phoneNumber = mEdtPhoneNumber.getText().toString().trim();
        if (!TextUtils.isEmpty(phoneNumber)) {
            UserServerImpl.sendVerifyCode(phoneNumber)
                    .subscribe(new ResourceSingleObserver<Boolean>() {
                        @Override
                        public void onSuccess(@NonNull Boolean aBoolean) {
                            if (!aBoolean) {
                                ToastUtils.showShort("验证码发送失败！");
                                return;
                            }
                            VerifyCodeActivity.startVerifyCode(LoginActivity.this, phoneNumber);
                            finish();
                        }

                        @Override
                        public void onError(@NonNull Throwable e) {
                            ToastUtils.showShort("验证码发送失败！");
                            e.printStackTrace();
                        }
                    });
        }
    }
}
