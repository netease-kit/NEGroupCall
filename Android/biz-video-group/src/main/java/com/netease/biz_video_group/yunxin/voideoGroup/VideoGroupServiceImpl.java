package com.netease.biz_video_group.yunxin.voideoGroup;

import android.content.Context;
import android.content.Intent;

import com.netease.biz_video_group.yunxin.voideoGroup.ui.VideoRoomSetActivity;
import com.netease.lib_video_group.yunxin.video_group.VideoGroupService;

public class VideoGroupServiceImpl implements VideoGroupService {
    @Override
    public void startVideoGroup(Context context) {
        Intent intent = new Intent(context, VideoRoomSetActivity.class);
        context.startActivity(intent);
    }

    @Override
    public void onInit(Context context) {

    }
}
