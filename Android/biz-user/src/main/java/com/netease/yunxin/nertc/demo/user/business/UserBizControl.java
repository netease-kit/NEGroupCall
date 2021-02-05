package com.netease.yunxin.nertc.demo.user.business;

import android.text.TextUtils;

import com.google.gson.reflect.TypeToken;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.auth.AuthService;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.yunxin.android.lib.network.common.NetworkClient;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.yunxin.nertc.demo.user.UserCenterServiceNotify;
import com.netease.yunxin.nertc.demo.user.UserModel;
import com.netease.yunxin.nertc.demo.user.network.UserServerImpl;
import com.netease.yunxin.nertc.demo.utils.FileCache;
import com.netease.yunxin.nertc.module.base.sdk.NESdkBase;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.Single;
import io.reactivex.SingleOnSubscribe;
import io.reactivex.SingleSource;
import io.reactivex.functions.Function;
import io.reactivex.subjects.PublishSubject;

/**
 * Created by luc on 2020/11/8.
 */

public final class UserBizControl {
    private static final String USER_CACHE_NAME = "user-cache";
    private static final List<UserCenterServiceNotify> observerCache = new ArrayList<>();
    private static final UserCenterServiceNotify USER_STATE_OBSERVER = new UserCenterServiceNotify() {
        @Override
        public void onUserLogin(boolean success, int code) {
            notifyAllRegisteredInfo(notify -> notify.onUserLogin(success, code));
        }

        @Override
        public void onUserLogout(boolean success, int code) {
            notifyAllRegisteredInfo(notify -> notify.onUserLogout(success, code));
        }

        @Override
        public void onError(Throwable exception) {
            notifyAllRegisteredInfo(notify -> notify.onError(exception));
        }

        @Override
        public void onUserInfoUpdate(UserModel model) {
            notifyAllRegisteredInfo(notify -> notify.onUserInfoUpdate(model));
        }
    };

    /**
     * 当前用户
     */
    private static UserModel currentUser = null;

    /**
     * 注册/反注册登录状态监听
     *
     * @param notify   状态监听
     * @param register true 注册，false 反注册
     */
    public static void registerUserStatus(UserCenterServiceNotify notify, boolean register) {
        if (register) {
            observerCache.add(notify);
        } else {
            observerCache.remove(notify);
        }
    }

    /**
     * 尝试使用用户本地缓存数据完成登录
     */
    public static Single<Boolean> tryLogin() {
        // 检查本地缓存是否存在，不存在直接返回 false，否则返回登录后的结果；
        UserModel userModel =
                FileCache.getCacheValue(NESdkBase.getInstance().getContext(), USER_CACHE_NAME,
                        new TypeToken<UserModel>() {
                        });
        // 检查本地缓存是否有效
        if (userModel == null || TextUtils.isEmpty(userModel.imToken) || userModel.imAccid == 0) {
            return Single.just(false);
        }
        // 构建 im 登录参数
        LoginInfo loginInfo = new LoginInfo(String.valueOf(userModel.imAccid), userModel.imToken);
        return loginIM(loginInfo).doOnSuccess(aBoolean -> {
            currentUser = userModel;
            NetworkClient.getInstance().configAccessToken(userModel.accessToken);
        }).retry(1);
    }

    /**
     * 用户登录
     *
     * @param phoneNumber 手机号
     * @param verifyCode  验证码
     */
    public static Single<Boolean> login(String phoneNumber, String verifyCode) {
        return UserServerImpl.loginWithVerifyCode(phoneNumber, verifyCode)
                .doOnSuccess(model -> currentUser = model)
                .map(userModel -> new LoginInfo(String.valueOf(userModel.imAccid), userModel.imToken))
                // 缓存至本地
                .doOnSuccess(loginInfo -> {
                    FileCache.cacheValue(NESdkBase.getInstance().getContext(), USER_CACHE_NAME, currentUser,
                            new TypeToken<UserModel>() {
                            });
                    NetworkClient.getInstance().configAccessToken(currentUser.accessToken);
                })
                .flatMap((Function<LoginInfo, SingleSource<Boolean>>) UserBizControl::loginIM)
                .doOnSuccess(aBoolean -> {
                    // 登录im 失败认为登录失败，清空当前用户信息
                    if (!aBoolean) {
                        currentUser = null;
                    }
                });
    }

    /**
     * 登录 IM 信息
     */
    @SuppressWarnings("all")
    private static Single<Boolean> loginIM(LoginInfo loginInfo) {
        PublishSubject<Boolean> subject = PublishSubject.create();
        NIMClient.getService(AuthService.class)
                .login(loginInfo)
                .setCallback(new RequestCallback<LoginInfo>() {

                    @Override
                    public void onSuccess(LoginInfo param) {
                        subject.onNext(true);
                        subject.onComplete();
                    }

                    @Override
                    public void onFailed(int code) {
                        FileCache.removeCache(NESdkBase.getInstance().getContext(), USER_CACHE_NAME);
                        currentUser = null;
                        ToastUtils.showShort("登录IM 失败，错误码 " + code);
                        subject.onNext(false);
                        subject.onComplete();
                    }

                    @Override
                    public void onException(Throwable exception) {
                        subject.onError(exception);
                    }
                });
        return subject.serialize()
                .singleOrError()
                .doOnSuccess(aBoolean -> USER_STATE_OBSERVER.onUserLogin(aBoolean, 0))
                .doOnError(USER_STATE_OBSERVER::onError);
    }

    /**
     * 退出登录
     */
    public static Single<Boolean> logout() {
        return Single.create((SingleOnSubscribe<Boolean>) emitter -> {
            try {
                boolean result = FileCache.removeCache(NESdkBase.getInstance().getContext(), USER_CACHE_NAME);
                currentUser = null;
                emitter.onSuccess(result);
            } catch (Exception e) {
                emitter.onError(e);
            }
        }).doOnSuccess(aBoolean -> {
            NIMClient.getService(AuthService.class).logout();
            USER_STATE_OBSERVER.onUserLogout(aBoolean, 0);
        }).doOnError(USER_STATE_OBSERVER::onError);
    }

    /**
     * 更新用户信息
     *
     * @param model 用户信息
     */
    public static Single<UserModel> updateUserInfo(UserModel model) {
        if (model == null) {
            return Single.error(new Throwable("UserModel is null"));
        }

        return UserServerImpl.updateNickname(model.nickname)
                .doOnSuccess(userModel -> {
                    UserModel backup = userModel.backup();
                    currentUser = backup;
                    FileCache.cacheValue(NESdkBase.getInstance().getContext(), USER_CACHE_NAME, backup,
                            new TypeToken<UserModel>() {
                            });
                    USER_STATE_OBSERVER.onUserInfoUpdate(backup);
                })
                .doOnError(USER_STATE_OBSERVER::onError);
    }

    public static UserModel getUserInfo() {
        return currentUser != null ? currentUser.backup() : null;
    }

    /**
     * 通知所有已注册回调
     */
    private static void notifyAllRegisteredInfo(NotifyHelper helper) {
        for (UserCenterServiceNotify notify : observerCache) {
            helper.onNotifyAction(notify);
        }
    }

    /**
     * 通知帮助接口
     */
    private interface NotifyHelper {
        void onNotifyAction(UserCenterServiceNotify notify);
    }
}
