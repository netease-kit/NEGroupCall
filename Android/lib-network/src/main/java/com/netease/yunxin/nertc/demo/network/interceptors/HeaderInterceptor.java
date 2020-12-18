package com.netease.yunxin.nertc.demo.network.interceptors;

import android.text.TextUtils;

import com.netease.yunxin.nertc.demo.network.NetworkClient;

import java.io.IOException;

import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;

/**
 * Created by luc on 2020/11/7.
 */
public class HeaderInterceptor implements Interceptor {

  @Override
  public Response intercept(Chain chain) throws IOException {
    Request original = chain.request();

    Request.Builder requestBuilder = original.newBuilder();
    String token = NetworkClient.getInstance().getAccessToken();
    if (!TextUtils.isEmpty(token)) {
      requestBuilder.header("accessToken", token);
    }
    requestBuilder.header("Content-Type", " application/json");

    Request request = requestBuilder.build();
    return chain.proceed(request);
  }
}
