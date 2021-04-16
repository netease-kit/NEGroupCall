package com.netease.yunxin.nertc.demo;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.github.moduth.blockcanary.BlockCanary;
import com.netease.biz_video_group.yunxin.voideoGroup.VideoGroupServiceImpl;
import com.netease.lib_video_group.yunxin.video_group.VideoGroupService;
import com.netease.yunxin.android.lib.network.common.NetworkClient;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.alog.BasicInfo;
import com.netease.yunxin.nertc.demo.basic.BuildConfig;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserCenterServiceImpl;
import com.netease.yunxin.nertc.demo.util.AppBlockCanaryContext;
import com.netease.yunxin.nertc.demo.util.CrashHandler;
import com.netease.yunxin.nertc.demo.utils.TempLogUtil;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;
import com.netease.yunxin.nertc.module.base.sdk.NESdkBase;

import java.io.File;

public class DemoApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        // 在主进程初始化调用哈
        BlockCanary.install(this, new AppBlockCanaryContext()).start();
        CrashHandler crashHandler = CrashHandler.getInstance();
        crashHandler.init(this);
        // 日志库初始化
        ALog.init(ALog.LEVEL_DEBUG,getExternalFilesDir("").getAbsolutePath()+ File.separator+"videogrouplog","videogroup");
        BasicInfo basicInfo = new BasicInfo.Builder()
                .packageName(this)
                .name("多人通话")
                .nertcVersion("4.0.1")
                .version("1.0.0")
                .deviceId(this)
                .build();
        ALog.logFirst(basicInfo);
        // 配置网络基础 url 以及 debug 开关
        NetworkClient.getInstance()
                .configBaseUrl(BuildConfig.BASE_URL)
                .appKey(BuildConfig.APP_KEY)
                .configDebuggable(true);
        // 初始化相关sdk
        NESdkBase.getInstance()
                .initContext(this)
                // 初始化 IM sdk
                //此处仅设置 AppKey，其他设置请自行参看信令文档设置 https://dev.yunxin.163.com/docs/product/信令/SDK开发集成/Android开发集成/初始化
                .initIM(BuildConfig.APP_KEY, null)
                //初始化美颜(相芯)
                .initFaceunity();


        // 模块方法实例注册
        ModuleServiceMgr.getInstance()
                // 用户模块
                .registerService(UserCenterService.class, getApplicationContext(), new UserCenterServiceImpl())
                //多人通话
                .registerService(VideoGroupService.class, getApplicationContext(), new VideoGroupServiceImpl());

        registerActivityLifecycleCallbacks(new ActivityLifecycleCallbacks() {
            @Override
            public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {
                TempLogUtil.log("ActivityLifecycle->onActivityCreated:"+activity.getClass().getSimpleName());
            }

            @Override
            public void onActivityStarted(@NonNull Activity activity) {

            }

            @Override
            public void onActivityResumed(@NonNull Activity activity) {

            }

            @Override
            public void onActivityPaused(@NonNull Activity activity) {

            }

            @Override
            public void onActivityStopped(@NonNull Activity activity) {

            }

            @Override
            public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {
                TempLogUtil.log("onActivitySaveInstanceState:"+activity.getClass().getSimpleName());
            }

            @Override
            public void onActivityDestroyed(@NonNull Activity activity) {
                TempLogUtil.log("onActivityDestroyed:"+activity.getClass().getSimpleName());
            }
        });
    }
}
