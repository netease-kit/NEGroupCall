package com.netease.biz_live.yunxin.live;

import android.content.Context;

import com.netease.yunxin.nertc.module.base.ModuleService;

/**
 * Created by luc on 2020/11/10.
 */
public interface LiveService extends ModuleService {

  /**
   * 启动pk 直播
   */
  void launchPkLive(Context context);
}
