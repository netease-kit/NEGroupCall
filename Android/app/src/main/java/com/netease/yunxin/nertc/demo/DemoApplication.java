package com.netease.yunxin.nertc.demo;

import android.app.Application;

import com.netease.biz_video_group.yunxin.voideoGroup.VideoGroupServiceImpl;
import com.netease.lib_video_group.yunxin.video_group.VideoGroupService;
import com.netease.yunxin.nertc.baselib.NativeConfig;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserCenterServiceImpl;
import com.netease.yunxin.nertc.module.base.ApplicationLifecycleMgr;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;
import com.netease.yunxin.nertc.module.base.sdk.NESdkBase;

public class DemoApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        // 初始化相关sdk
        NESdkBase.getInstance()
                .initContext(this)
                // 初始化 IM sdk
                //此处仅设置 AppKey，其他设置请自行参看信令文档设置 https://dev.yunxin.163.com/docs/product/信令/SDK开发集成/Android开发集成/初始化
                .initIM(NativeConfig.getAppKey(), null)
                //初始化美颜(相芯)
                .initFaceunity();

        // 各个module初始化逻辑
        ApplicationLifecycleMgr.getInstance()
//                .registerLifecycle(new LiveApplicationLifecycle())
                .notifyOnCreate(this);

        // 模块方法实例注册
        ModuleServiceMgr.getInstance()
                // 用户模块
                .registerService(UserCenterService.class, getApplicationContext(), new UserCenterServiceImpl())
                //多人通话
                .registerService(VideoGroupService.class, getApplicationContext(), new VideoGroupServiceImpl());
    }
}
