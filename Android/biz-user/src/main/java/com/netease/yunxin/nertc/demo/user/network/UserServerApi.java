package com.netease.yunxin.nertc.demo.user.network;

import com.netease.yunxin.nertc.demo.network.BaseResponse;
import com.netease.yunxin.nertc.demo.user.UserModel;

import java.util.Map;

import io.reactivex.Single;
import retrofit2.http.Body;
import retrofit2.http.POST;

/**
 * Created by luc on 2020/11/7.
 */
interface UserServerApi {

    /**
     * 发送登录验证码
     */
    @POST("/auth/sendLoginSmsCode")
    Single<BaseResponse<Void>> sendLoginSmsCode(@Body Map<String, Object> body);

    /**
     * 通过验证码登录
     */
    @POST("/auth/loginBySmsCode")
    Single<BaseResponse<UserModel>> loginWithSmsCode(@Body Map<String, Object> body);

    /**
     * 通过token 登录
     */
    @POST("/auth/loginByToken")
    Single<BaseResponse<UserModel>> loginWithToken();

    /**
     * 登出
     */
    @POST("/auth/logout")
    Single<BaseResponse<Void>> logout();

    /**
     * 更新用户昵称
     */
    @POST("/auth/updateNickname")
    Single<BaseResponse<UserModel>> updateNickname(@Body Map<String, Object> body);
}
