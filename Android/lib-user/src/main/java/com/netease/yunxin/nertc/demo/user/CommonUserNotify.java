package com.netease.yunxin.nertc.demo.user;

/**
 * Created by luc on 2020/11/16.
 */
public abstract class CommonUserNotify implements UserCenterServiceNotify {

    @Override
    public void onUserLogin(boolean success, int code) {

    }

    @Override
    public void onUserLogout(boolean success, int code) {

    }

    @Override
    public void onError(Throwable exception) {

    }

    @Override
    public void onUserInfoUpdate(UserModel model) {

    }
}
