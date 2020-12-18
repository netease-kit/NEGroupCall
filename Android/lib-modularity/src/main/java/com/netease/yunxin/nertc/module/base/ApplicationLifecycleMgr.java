package com.netease.yunxin.nertc.module.base;

import android.app.Application;

import java.util.HashMap;
import java.util.Map;

/**
 * 单例，管理application 生命周期以及回调触发
 */
public final class ApplicationLifecycleMgr {
    private final Map<Class<? extends AbsApplicationLifecycle>, AbsApplicationLifecycle> lifecycleMap = new HashMap<>();

    private ApplicationLifecycleMgr() {
    }

    private static final class Holder {
        public static ApplicationLifecycleMgr INSTANCE = new ApplicationLifecycleMgr();
    }

    public static ApplicationLifecycleMgr getInstance() {
        return Holder.INSTANCE;
    }
//------------------------------------------------------------------------------------

    /**
     * 生命周期注册
     */
    public ApplicationLifecycleMgr registerLifecycle(AbsApplicationLifecycle lifecycle) {
        if (lifecycle == null) {
            return this;
        }
        if (lifecycleMap.containsKey(lifecycle.getClass()) || lifecycleMap.containsValue(lifecycle)) {
            return this;
        }
        lifecycleMap.put(lifecycle.getClass(), lifecycle);
        return this;
    }

    /**
     * @param commonRunner 各个模块通用初始化信息
     */
    public void notifyOnCreate(Application application, Runnable commonRunner) {
        if (commonRunner != null) {
            commonRunner.run();
        }
        for (AbsApplicationLifecycle lifecycle : lifecycleMap.values()) {
            if (lifecycle == null) {
                continue;
            }
            lifecycle.onModuleCreate(application);
        }
    }

    public void notifyOnCreate(Application application) {
        notifyOnCreate(application, null);
    }

    @SuppressWarnings("unchecked")
    public <T extends AbsApplicationLifecycle> T getLifecycle(Class<T> tClass) {
        Object lifecycle = lifecycleMap.get(tClass);
        return tClass.isInstance(lifecycle) ? (T) lifecycle : null;
    }
}
