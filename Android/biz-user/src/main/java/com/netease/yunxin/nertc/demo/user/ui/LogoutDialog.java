package com.netease.yunxin.nertc.demo.user.ui;

import android.app.Dialog;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserCenterServiceNotify;
import com.netease.yunxin.nertc.demo.user.business.UserBizControl;
import com.netease.yunxin.nertc.user.R;

import androidx.annotation.NonNull;
import io.reactivex.observers.ResourceSingleObserver;


/**
 * Created by luc on 2020/11/17.
 */
public class LogoutDialog extends Dialog {

    public LogoutDialog(@NonNull Context context, int type, UserCenterServiceNotify notify) {
        super(context, R.style.LogoutDialog);

        View rootView = LayoutInflater.from(getContext()).inflate(R.layout.view_logout_dialog, null);
        View tvNo = rootView.findViewById(R.id.tv_logout_no);
        tvNo.setOnClickListener(v -> dismiss());

        initForType(rootView, type);
        View tvYes = rootView.findViewById(R.id.tv_logout_yes);
        tvYes.setOnClickListener(v -> {
            dismiss();
            UserBizControl.logout().subscribe(new ResourceSingleObserver<Boolean>() {
                @Override
                public void onSuccess(@io.reactivex.annotations.NonNull Boolean aBoolean) {
                    LoginActivity.startLogin(context);
                    if (notify != null) {
                        notify.onUserLogout(aBoolean, 0);
                    }
                }

                @Override
                public void onError(@io.reactivex.annotations.NonNull Throwable e) {
                    if (notify != null) {
                        notify.onError(e);
                    }
                }
            });
        });
        setContentView(rootView);
    }

    private void initForType(View rootView, int type) {
        if (type == UserCenterService.LOGOUT_DIALOG_TYPE_NORMAL) {
            initForNormal(rootView);
        } else if (type == UserCenterService.LOGOUT_DIALOG_TYPE_LOGIN_AGAIN) {
            initForLoginAgain(rootView);
        }
    }

    private void initForLoginAgain(View rootView) {
        TextView tvTitle = rootView.findViewById(R.id.tv_logout_title);
        tvTitle.setText("重新登录");

        TextView tvContent = rootView.findViewById(R.id.tv_logout_content);
        tvContent.setText("当前用户已经在其它设备上登录，请重新登录！");

        TextView tvYes = rootView.findViewById(R.id.tv_logout_yes);
        tvYes.setText("知道了");

        rootView.findViewById(R.id.line_divide).setVisibility(View.GONE);
        rootView.findViewById(R.id.tv_logout_no).setVisibility(View.GONE);
        setCancelable(false);
    }

    private void initForNormal(View rootView) {
        TextView tvTitle = rootView.findViewById(R.id.tv_logout_title);
        tvTitle.setText("退出登录");

        TextView tvContent = rootView.findViewById(R.id.tv_logout_content);
        tvContent.setText("确认退出当前登录账户？");

        TextView tvYes = rootView.findViewById(R.id.tv_logout_yes);
        tvYes.setText("是");

        rootView.findViewById(R.id.line_divide).setVisibility(View.VISIBLE);
        rootView.findViewById(R.id.tv_logout_no).setVisibility(View.VISIBLE);
        setCancelable(true);
    }
}
