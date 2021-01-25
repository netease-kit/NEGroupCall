package com.netease.yunxin.nertc.demo.user.network;

import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.android.lib.network.common.NetworkClient;
import com.netease.yunxin.android.lib.network.common.NetworkConstant;
import com.netease.yunxin.nertc.demo.user.UserModel;

import java.util.HashMap;
import java.util.Map;

import io.reactivex.Single;
import io.reactivex.SingleTransformer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by luc on 2020/11/7.
 */
public final class UserServerImpl {

    /**
     * 发送短信验证码
     *
     * @param phoneNumber 手机号码
     * @return true 成功，false 失败
     */
    public static Single<Boolean> sendVerifyCode(String phoneNumber) {
        UserServerApi api = NetworkClient.getInstance().getService(UserServerApi.class);
        Map<String, Object> map = new HashMap<>(1);
        map.put("mobile", phoneNumber);
        return api.sendLoginSmsCode(map).compose(scheduleThread()).map(BaseResponse::isSuccessful);
    }

    /**
     * 通过手机号+短信验证登录获取用户信息
     *
     * @param phoneNumber 手机号
     * @param code        短信验证码
     * @return 用户信息
     */
    public static Single<UserModel> loginWithVerifyCode(String phoneNumber, String code) {
        UserServerApi api = NetworkClient.getInstance().getService(UserServerApi.class);
        Map<String, Object> map = new HashMap<>(2);
        map.put("mobile", phoneNumber);
        map.put("smsCode", code);
        return api.loginWithSmsCode(map)
                .compose(scheduleThread())
                .doOnSuccess(userModelBaseResponse -> {
                    if (!userModelBaseResponse.isSuccessful()) {
                        throw new Exception("loginWithSmsCode error and code is " + userModelBaseResponse.code);
                    }
                })
                .map(userModelBaseResponse -> userModelBaseResponse.data);
    }

    /**
     * 登出用户账号
     */
    @Deprecated // 目前接口已经废弃，由于调用此接口会导致token失效
    public static Single<Boolean> logout() {
        UserServerApi api = NetworkClient.getInstance().getService(UserServerApi.class);
        return api
                .logout()
                .compose(scheduleThread())
                .map(response -> response.isSuccessful() || response.code == NetworkConstant.ERROR_RESPONSE_CODE_TOKEN_FAIL);
    }

    /**
     * 更新用户昵称
     */
    public static Single<UserModel> updateNickname(String nickname) {
        UserServerApi api = NetworkClient.getInstance().getService(UserServerApi.class);
        Map<String, Object> map = new HashMap<>(1);
        map.put("nickname", nickname);
        return api.updateNickname(map).compose(scheduleThread())
                .map(userModelBaseResponse -> userModelBaseResponse.data);
    }

    /***
     * 切换网络访问线程
     */
    private static <T> SingleTransformer<T, T> scheduleThread() {
        return upstream -> upstream.
                subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread());
    }
}
