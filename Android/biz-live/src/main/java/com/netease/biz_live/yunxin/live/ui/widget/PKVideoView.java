package com.netease.biz_live.yunxin.live.ui.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;

import com.netease.biz_live.R;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;

public class PKVideoView extends LinearLayout {

    private NERtcVideoView localVideo;

    private NERtcVideoView remoteVideo;

    public PKVideoView(Context context) {
        super(context);
        initView();
    }

    public PKVideoView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    public PKVideoView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView();
    }

    private void initView() {
        LayoutInflater.from(getContext()).inflate(R.layout.pk_video_view_layout, this, true);
        localVideo = findViewById(R.id.local_video);
        remoteVideo = findViewById(R.id.remote_video);
    }

    public NERtcVideoView getLocalVideo() {
        return localVideo;
    }

    public NERtcVideoView getRemoteVideo() {
        return remoteVideo;
    }
}
