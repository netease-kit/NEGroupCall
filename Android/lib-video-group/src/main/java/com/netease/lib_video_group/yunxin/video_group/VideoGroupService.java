package com.netease.lib_video_group.yunxin.video_group;

import android.content.Context;

import com.netease.yunxin.nertc.module.base.ModuleService;

public interface VideoGroupService extends ModuleService {

    /**
     * 开始多人通话
     *
     * @param context
     */
    void startVideoGroup(Context context);
}
