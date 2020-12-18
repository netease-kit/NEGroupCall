package com.netease.yunxin.nertc.module.base;

import android.content.Context;

import java.util.HashMap;
import java.util.Map;

public final class ModuleServiceMgr {
    private final Map<Class<?>, ModuleService> serviceMap = new HashMap<>();

    private ModuleServiceMgr() {
    }

    private static final class Holder {
        private static ModuleServiceMgr INSTANCE = new ModuleServiceMgr();
    }

    public static ModuleServiceMgr getInstance() {
        return Holder.INSTANCE;
    }

    public ModuleServiceMgr registerService(Class<?> clazz, Context context, ModuleService service) {
        if (clazz == null || service == null) {
            return this;
        }
        if (serviceMap.containsValue(service)) {
            return this;
        }
        serviceMap.put(clazz, service);
        service.onInit(context);
        return this;
    }

    /**
     * 获取方法服务实例
     *
     * @param tClass 服务类型
     * @return 服务实例
     */
    @SuppressWarnings("unchecked")
    public <T extends ModuleService> T getService(Class<T> tClass) {
        Object lifecycle = serviceMap.get(tClass);
        T result = tClass.isInstance(lifecycle) ? (T) lifecycle : null;
        return result != null ? result : (T) getService(tClass.getCanonicalName());
    }

    @SuppressWarnings("unchecked")
    public <T extends ModuleService> T getService(String className) {
        Class<?> tClass = null;
        try {
            tClass = Class.forName(className);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        if (tClass == null) {
            return null;
        }
        Object service = serviceMap.get(tClass);
        T result = null;
        try {
            result = (T) service;
        } catch (ClassCastException e) {
            e.printStackTrace();
        }
        if (result != null) {
            return result;
        }
        try {
            result = (T) tClass.newInstance();
            serviceMap.put(tClass, result);
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InstantiationException e) {
            e.printStackTrace();
        }
        return result;
    }
}
