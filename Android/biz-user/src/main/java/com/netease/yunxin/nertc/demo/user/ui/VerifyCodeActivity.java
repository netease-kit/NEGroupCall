package com.netease.yunxin.nertc.demo.user.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig;
import com.netease.yunxin.nertc.demo.user.business.UserBizControl;
import com.netease.yunxin.nertc.demo.user.network.UserServerImpl;
import com.netease.yunxin.nertc.demo.user.ui.view.VerifyCodeView;
import com.netease.yunxin.nertc.demo.utils.TempLogUtil;
import com.netease.yunxin.nertc.user.R;

import io.reactivex.annotations.NonNull;
import io.reactivex.observers.ResourceSingleObserver;

public class VerifyCodeActivity extends BaseActivity {

    public static final String PHONE_NUMBER = "phone_number";

    private VerifyCodeView verifyCodeView;//验证码输入框

    private TextView tvMsmComment;

    private Button btnNext;

    private TextView tvTimeCountDown;

    private String phoneNumber;

    private CountDownTimer countDownTimer;

    private TextView tvResendMsm;

    public static void startVerifyCode(Context context, String phoneNumber) {
        Intent intent = new Intent();
        intent.setClass(context, VerifyCodeActivity.class);
        intent.putExtra(PHONE_NUMBER, phoneNumber);
        context.startActivity(intent);
    }


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

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.verify_code_layout);
        initView();
        initData();
    }

    private void initView() {
        verifyCodeView = findViewById(R.id.vcv_sms);
        tvMsmComment = findViewById(R.id.tv_msm_comment);
        btnNext = findViewById(R.id.btn_next);
        tvTimeCountDown = findViewById(R.id.tv_time_discount);
        tvResendMsm = findViewById(R.id.tv_resend_msm);
    }

    private void initData() {
        phoneNumber = getIntent().getStringExtra(PHONE_NUMBER);
        tvMsmComment.setText("验证码已经发送至 +86-" + phoneNumber + "，请在下方输入验证码");
        btnNext.setOnClickListener(v -> {
            String smsCode = verifyCodeView.getResult();
            if (!TextUtils.isEmpty(smsCode)) {
                login(smsCode);
            }
        });
        tvTimeCountDown.setOnClickListener(v -> {
            reSendMsm();
        });

        initCountDown();
    }

    private void initCountDown() {
        tvTimeCountDown.setText("60s");
        tvResendMsm.setVisibility(View.VISIBLE);
        tvTimeCountDown.setEnabled(false);

        countDownTimer = new CountDownTimer(60000, 1000) {
            @Override
            public void onTick(long l) {
                tvTimeCountDown.setText((l / 1000) + "s");
            }

            @Override
            public void onFinish() {
                tvTimeCountDown.setText("重新发送");
                tvTimeCountDown.setEnabled(true);
                tvResendMsm.setVisibility(View.GONE);
            }
        };

        countDownTimer.start();
    }

    private void reSendMsm() {
        if (!TextUtils.isEmpty(phoneNumber)) {
            UserServerImpl.sendVerifyCode(phoneNumber).subscribe(new ResourceSingleObserver<Boolean>() {
                @Override
                public void onSuccess(@NonNull Boolean aBoolean) {
                    if (aBoolean) {
                        ToastUtils.showLong("验证码重新发送成功");
                        initCountDown();
                    } else {
                        ToastUtils.showLong("验证码重新发送失败");
                    }
                }

                @Override
                public void onError(@NonNull Throwable e) {
                    ToastUtils.showLong("验证码重新发送失败");
                }
            });
        }
    }

    private void login(String msmCode) {
        if (!TextUtils.isEmpty(phoneNumber) && !TextUtils.isEmpty(msmCode)) {

            UserBizControl.login(phoneNumber, msmCode).subscribe(new ResourceSingleObserver<Boolean>() {
                @Override
                public void onSuccess(@NonNull Boolean aBoolean) {
                    if (aBoolean){
                        ToastUtils.showLong("登录成功");
                        startMainActivity();
                    }else {
                        ToastUtils.showLong("登录失败");
                    }
                }

                @Override
                public void onError(@NonNull Throwable e) {
                    ToastUtils.showLong("登录失败");
                }
            });
        }
    }

    private void startMainActivity() {
        Intent intent = new Intent();
        intent.addCategory("android.intent.category.DEFAULT");
        intent.setAction("com.nertc.groupcall.action.main");
        startActivity(intent);
        finish();
    }

}
