package com.netease.biz_video_group.yunxin.voideoGroup.widget;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Outline;
import android.graphics.Rect;
import android.os.Build;
import android.util.AttributeSet;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewOutlineProvider;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.blankj.utilcode.util.SizeUtils;
import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.model.UserStatusInfo;
import com.netease.biz_video_group.yunxin.voideoGroup.util.VideoViewUtil;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;

/**
 * @author sunkeding
 * 方形视频View
 */
public class SquareVideoCallItemView extends FrameLayout {
    private ImageView ivMute;
    private TextView tvNicknameBottom;
    private FrameLayout flRoot;
    private NERtcVideoView videoView;
    private UserStatusInfo userStatusInfo;

    public SquareVideoCallItemView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public SquareVideoCallItemView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);

    }

    public SquareVideoCallItemView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);

    }

    private void init(Context context) {
        inflate(context, R.layout.video_group_speaker_square_layout, this);
        flRoot = findViewById(R.id.fl_root);
        ivMute = findViewById(R.id.iv);
        tvNicknameBottom = findViewById(R.id.tv);
        videoView = findViewById(R.id.video_view);
        findViewById(R.id.fl_root).setOnClickListener(v -> {
            if (onItemClickListener != null) {
                onItemClickListener.onItemClick(userStatusInfo);
            }
        });
        setdefaultStatus();
    }

    private void setdefaultStatus() {
        videoView.setVisibility(View.INVISIBLE);
        ivMute.setVisibility(VISIBLE);
        ivMute.setImageResource(R.drawable.voice_off);
    }

    public void setData(UserStatusInfo userStatusInfo) {
        this.userStatusInfo = userStatusInfo;
        if (userStatusInfo.isSelf) {
            VideoViewUtil.setupLocalVideo(videoView,true);
        } else {
            VideoViewUtil.setupRemoteVideo(videoView, userStatusInfo.userId, true);
        }
        if (!userStatusInfo.enableVideo) {
            videoView.setVisibility(View.INVISIBLE);
        } else {
            videoView.setVisibility(View.VISIBLE);
        }

        if (userStatusInfo.enableMicphone) {
            ivMute.setVisibility(GONE);
        } else {
            ivMute.setVisibility(VISIBLE);
            ivMute.setImageResource(R.drawable.voice_off);
        }
        tvNicknameBottom.setText(userStatusInfo.nickname);
//         setBgRadius(flRoot,SizeUtils.dp2px(4));
    }
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private void setBgRadius(View layoutContent, int bgRadius) {
        layoutContent.setOutlineProvider(new ViewOutlineProvider() {
            @Override
            public void getOutline(View view, Outline outline) {
//                outline.setRoundRect(0, 0, view.getWidth(), view.getHeight(), bgRadius);
                Rect rect = new Rect();
                view.getGlobalVisibleRect(rect);
                int leftMargin = 0;
                int topMargin = 0;
                Rect selfRect = new Rect(leftMargin, topMargin,
                        rect.right - rect.left - leftMargin,
                        rect.bottom - rect.top - topMargin);
                outline.setRoundRect(selfRect, bgRadius);
            }
        });
        layoutContent.setClipToOutline(true);
    }

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    private OnItemClickListener onItemClickListener;

    public interface OnItemClickListener {
        void onItemClick(UserStatusInfo userStatusInfo);
    }
}
