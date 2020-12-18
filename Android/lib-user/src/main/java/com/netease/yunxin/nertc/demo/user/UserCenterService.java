package com.netease.yunxin.nertc.demo.user;

import android.app.Activity;
import android.content.Context;

import com.netease.yunxin.nertc.module.base.ModuleService;

public interface UserCenterService extends ModuleService {

    /**
     * 正常登出
     */
    int LOGOUT_DIALOG_TYPE_NORMAL = 1;
    /**
     * 登出，提示重新登录
     */
    int LOGOUT_DIALOG_TYPE_LOGIN_AGAIN = 2;


    /**
     * 注册或反注册用户登录状态监听
     *
     * @param notify     监听回调
     * @param registered true 注册，false 反注册
     */
    void registerLoginObserver(UserCenterServiceNotify notify, boolean registered);

    /**
     * 对应用户是否为当前用户
     *
     * @param imAccId 用户im id
     * @return true 当前用户
     */
    boolean isCurrentUser(long imAccId);

    /**
     * 获取当前用户
     */
    UserModel getCurrentUser();

    /**
     * 更新用户信息
     */
    void updateUserInfo(UserModel model, UserCenterServiceNotify notify);

    /**
     * 吊起登录页面
     *
     * @param context 上下文
     */
    void launchLogin(Context context);

    /**
     * 通过缓存尝试登录
     */
    void tryLogin(UserCenterServiceNotify notify);

    /**
     * 用户登出
     */
    void launchLogout(Activity activity, int type, UserCenterServiceNotify notify);

    /**
     * 当前用户是否登录
     */
    boolean isLogin();
}
