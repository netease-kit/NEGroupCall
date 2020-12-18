package com.netease.yunxin.nertc.demo.user;

import android.app.Activity;
import android.content.Context;

import com.netease.yunxin.nertc.demo.user.business.UserBizControl;
import com.netease.yunxin.nertc.demo.user.ui.LoginActivity;
import com.netease.yunxin.nertc.demo.user.ui.LogoutDialog;

import io.reactivex.annotations.NonNull;
import io.reactivex.observers.ResourceSingleObserver;

public class UserCenterServiceImpl implements UserCenterService {

    @Override
    public void onInit(Context context) {

    }


    @Override
    public void registerLoginObserver(UserCenterServiceNotify notify, boolean registered) {
        UserBizControl.registerUserStatus(notify, registered);
    }

    @Override
    public boolean isCurrentUser(long imAccId) {
        return isLogin() && getCurrentUser().isSameIMUser(imAccId);
    }

    @Override
    public UserModel getCurrentUser() {
        return UserBizControl.getUserInfo();
    }

    @Override
    public void updateUserInfo(UserModel model, UserCenterServiceNotify notify) {
        UserBizControl.updateUserInfo(model).subscribe(new ResourceSingleObserver<UserModel>() {
            @Override
            public void onSuccess(@NonNull UserModel model) {
                notify.onUserInfoUpdate(model);
            }

            @Override
            public void onError(@NonNull Throwable e) {
                notify.onError(e);
            }
        });
    }

    @Override
    public void launchLogin(Context context) {
        LoginActivity.startLogin(context);
    }

    @Override
    public void tryLogin(UserCenterServiceNotify notify) {
        UserBizControl.tryLogin().subscribe(new ResourceSingleObserver<Boolean>() {
            @Override
            public void onSuccess(@NonNull Boolean aBoolean) {
                notify.onUserLogin(aBoolean, 0);
            }

            @Override
            public void onError(@NonNull Throwable e) {
                notify.onError(e);
            }
        });
    }

    private LogoutDialog dialog;

    @Override
    public void launchLogout(Activity activity, int type, UserCenterServiceNotify notify) {
        if (dialog != null && dialog.isShowing() && !activity.isFinishing()) {
            try {
                dialog.dismiss();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        dialog = new LogoutDialog(activity, type, notify);
        dialog.show();
    }

    @Override
    public boolean isLogin() {
        return UserBizControl.getUserInfo() != null;
    }

}
