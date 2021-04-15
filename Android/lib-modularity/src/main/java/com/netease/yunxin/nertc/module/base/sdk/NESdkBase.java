package com.netease.yunxin.nertc.module.base.sdk;

import android.annotation.SuppressLint;
import android.content.Context;

import com.faceunity.FURenderer;
import com.faceunity.utils.FileUtils;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.SDKOptions;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.yunxin.nertc.demo.utils.ThreadHelper;

public final class NESdkBase {
    private Context context;

    private NESdkBase() {
    }

    private static final class Holder {
        @SuppressLint("StaticFieldLeak")
        private static NESdkBase INSTANCE = new NESdkBase();
    }

    public static NESdkBase getInstance() {
        return Holder.INSTANCE;
    }

    public NESdkBase initContext(Context context) {
        this.context = context.getApplicationContext();
        return this;
    }

    public Context getContext(){
        return context;
    }

    /**
     * 初始化 IM sdk
     *
     * @param appKey 用户 IM sdk 的 AppKey
     * @param info   用户登录信息，如果存在会自动登录，否则设置为null
     */
    public NESdkBase initIM(String appKey, LoginInfo info) {
        SDKOptions options = new SDKOptions();
        options.appKey = appKey;
        NIMClient.init(context, info, options);
        return this;
    }

    public NESdkBase initFaceunity() {
        FURenderer.initFURenderer(context);
        ThreadHelper.getInstance().execute(new Runnable() {
            @Override
            public void run() {
                // 异步拷贝 assets 资源
                FileUtils.copyAssetsChangeFaceTemplate(context);
            }
        });
        return this;
    }

    public NESdkBase initNERtc(String appKey) {
        return this;
    }
}
