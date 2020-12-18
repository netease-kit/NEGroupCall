package com.netease.yunxin.nertc.demo.network;

import android.text.TextUtils;
import android.util.Log;

import com.netease.yunxin.nertc.baselib.NativeConfig;
import com.netease.yunxin.nertc.demo.network.interceptors.HeaderInterceptor;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory;
import retrofit2.converter.gson.GsonConverterFactory;

/**
 * Created by luc on 2020/11/7.
 */
public final class NetworkClient {
    private static final String TAG = NetworkClient.class.getSimpleName();
    private static final Map<String, String> configMap = new HashMap<>();
    private static final String BASE_URL = NativeConfig.getBaseURL();

    private final Map<String, Retrofit> URL_RETROFIT_CACHE = new HashMap<>();

    private NetworkClient() {
    }

    private static final class Holder {
        private static final NetworkClient INSTANCE = new NetworkClient();
    }

    public static NetworkClient getInstance() {
        return Holder.INSTANCE;
    }

    private Retrofit initRetrofit(String baseUrl) {

        OkHttpClient.Builder clientBuilder =
                new OkHttpClient.Builder()
                        .connectTimeout(5, TimeUnit.SECONDS)
                        .readTimeout(5, TimeUnit.SECONDS)
                        .writeTimeout(5, TimeUnit.SECONDS)
                        .addInterceptor(new HeaderInterceptor());
        if (BuildConfig.DEBUG) {
            HttpLoggingInterceptor logging = new HttpLoggingInterceptor(new HttpLoggingInterceptor.Logger() {
                @Override
                public void log(String message) {
                    Log.e(TAG, message);
                }
            });
            logging.setLevel(HttpLoggingInterceptor.Level.BODY);
            clientBuilder.addInterceptor(logging);
        }

        return new Retrofit.Builder().baseUrl(baseUrl)
                .client(clientBuilder.build())
                .addConverterFactory(GsonConverterFactory.create())
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                .build();
    }

    public synchronized <T> T getService(Class<T> service) {
        BaseUrl url = service.getAnnotation(BaseUrl.class);
        String baseUrl = BASE_URL;
        if (url != null && !TextUtils.isEmpty(url.value())) {
            baseUrl = url.value();
        }
        return getService(baseUrl, service);
    }

    public synchronized <T> T getService(String baseUrl, Class<T> service) {
        Retrofit retrofit = URL_RETROFIT_CACHE.get(baseUrl);
        if (retrofit == null) {
            retrofit = initRetrofit(baseUrl);
            URL_RETROFIT_CACHE.put(baseUrl, retrofit);
        }
        return retrofit.create(service);
    }

    public void configAccessToken(String token) {
        configParam(NetworkConstant.CONFIG_ACCESS_TOKEN, token);
    }

    public String getAccessToken() {
        return getConfigValue(NetworkConstant.CONFIG_ACCESS_TOKEN);
    }

    public static void configParam(String key, String value) {
        configMap.put(key, value);
    }

    public static String getConfigValue(String key) {
        return configMap.get(key);
    }
}
