package com.netease.yunxin.nertc.demo.network;

/**
 * Created by luc on 2020/11/7.
 */
public class BaseResponse<T> {
    public int code;
    public T data;
    public String msg;

    public boolean isSuccessful() {
        return code == NetworkConstant.SUCCESS_RESPONSE_CODE;
    }
}
