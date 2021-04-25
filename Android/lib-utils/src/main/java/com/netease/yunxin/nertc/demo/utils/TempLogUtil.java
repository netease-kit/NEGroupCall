package com.netease.yunxin.nertc.demo.utils;

import com.netease.yunxin.kit.alog.ALog;

/**
 * @author sunkeding
 */
public class TempLogUtil {
    public static void log(String msg){
        ALog.d("TempLogUtil",msg);
        ALog.flush(true);
    }
}
