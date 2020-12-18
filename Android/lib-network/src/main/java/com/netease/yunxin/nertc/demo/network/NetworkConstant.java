package com.netease.yunxin.nertc.demo.network;

/**
 * Created by luc on 2020/11/7.
 */
public @interface NetworkConstant {

    String CONFIG_ACCESS_TOKEN = "config_access_token";

    int SUCCESS_RESPONSE_CODE = 200;

    int ERROR_RESPONSE_CODE_TOKEN_FAIL = 300; // 令牌验证失败
}
