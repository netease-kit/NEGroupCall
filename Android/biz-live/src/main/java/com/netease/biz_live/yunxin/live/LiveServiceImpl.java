package com.netease.biz_live.yunxin.live;

import android.content.Context;
import android.content.Intent;

import com.netease.biz_live.yunxin.live.ui.LiveListActivity;

/**
 * Created by luc on 2020/11/10.
 */
public class LiveServiceImpl implements LiveService {

    @Override
    public void onInit(Context context) {

    }

    @Override
    public void launchPkLive(Context context) {
        context.startActivity(new Intent(context, LiveListActivity.class));
    }
}
