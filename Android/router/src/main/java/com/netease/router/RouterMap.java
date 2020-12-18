package com.netease.router;


import android.content.Context;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import dalvik.system.DexFile;

public class RouterMap {

    protected Map<String, String> routerMap = new HashMap<>();

    protected Map<String, String> getRouterMap() {
        return routerMap;
    }

    public Map<String, String> collectMap(Context context) {
        List<String> classList = getClassName("com.netease.router.map", context);
        try {
            for (String clazzStr : classList) {
                Class<?> clazz = Class.forName(clazzStr);
                if (clazz.getSuperclass().equals(RouterMap.class)) {
                    RouterMap subRouter = (RouterMap) clazz.newInstance();
                    routerMap.putAll(subRouter.getRouterMap());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return routerMap;
    }

    public List<String> getClassName(String packageName, Context context) {
        List<String> classNameList = new ArrayList<String>();
        try {

            DexFile df = new DexFile(context.getPackageCodePath());//通过DexFile查找当前的APK中可执行文件
            Enumeration<String> enumeration = df.entries();//获取df中的元素  这里包含了所有可执行的类名 该类名包含了包名+类名的方式
            while (enumeration.hasMoreElements()) {//遍历
                String className = (String) enumeration.nextElement();

                if (className.contains(packageName)) {//在当前所有可执行的类里面查找包含有该包名的所有类
                    classNameList.add(className);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return classNameList;
    }

}


