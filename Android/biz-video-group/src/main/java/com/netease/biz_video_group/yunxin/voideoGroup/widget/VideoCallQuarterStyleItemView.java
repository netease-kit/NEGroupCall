package com.netease.biz_video_group.yunxin.voideoGroup.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.blankj.utilcode.util.ScreenUtils;
import com.blankj.utilcode.util.SizeUtils;
import com.netease.biz_video_group.R;
import com.netease.biz_video_group.yunxin.voideoGroup.model.UserStatusInfo;
import com.netease.biz_video_group.yunxin.voideoGroup.util.ScreenUtil;

/**
 * @author sunkeding
 * 视频通话占四分之一大小的卡片样式
 */
public class VideoCallQuarterStyleItemView extends FrameLayout {
    private VideoCallBaseItemView videoCallBaseItemView;

    public VideoCallQuarterStyleItemView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public VideoCallQuarterStyleItemView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public VideoCallQuarterStyleItemView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        inflate(context, R.layout.video_group_listitem_quarter_style_layout, this);
        videoCallBaseItemView = findViewById(R.id.video_call_base_view);
        ViewGroup.LayoutParams layoutParams = videoCallBaseItemView.getLayoutParams();
        layoutParams.width = (ScreenUtils.getScreenWidth()- SizeUtils.dp2px(2))  / 2;
        layoutParams.height = (ScreenUtil.getDisplayHeight(context)- SizeUtils.dp2px(2)) / 2;
        videoCallBaseItemView.setLayoutParams(layoutParams);
        videoCallBaseItemView.setFullScreenButtonClickListener(userStatusInfo -> {
            if (fullScreenButtonClickListener!=null){
                fullScreenButtonClickListener.fullScreenButtonClick(userStatusInfo);
            }
        });
    }

    public void setData(UserStatusInfo userStatusInfo) {
        videoCallBaseItemView.setData(userStatusInfo);
    }

    public void setFullScreenButtonClickListener(FullScreenButtonClickListener fullScreenButtonClickListener) {
        this.fullScreenButtonClickListener = fullScreenButtonClickListener;
    }

    private FullScreenButtonClickListener fullScreenButtonClickListener;

    public interface FullScreenButtonClickListener {
        void fullScreenButtonClick(UserStatusInfo userStatusInfo);
    }
}
