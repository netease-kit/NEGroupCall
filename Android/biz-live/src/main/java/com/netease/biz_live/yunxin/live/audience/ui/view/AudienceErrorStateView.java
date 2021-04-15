package com.netease.biz_live.yunxin.live.audience.ui.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.biz_live.R;
import com.netease.yunxin.android.lib.picture.ImageLoader;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.Group;

/**
 * Created by wangqiang04 on 2020/12/18.
 */
public class AudienceErrorStateView extends ConstraintLayout {
    /**
     * 正常结束直播状态
     */
    public static final int TYPE_FINISHED = 1;
    /**
     * 拉流错误或获取信息错误状态
     */
    public static final int TYPE_ERROR = 2;
    /**
     * 背景模糊大图
     */
    private ImageView ivBgView;
    /**
     * 主播头像
     */
    private ImageView ivPortrait;
    /**
     * 主播昵称
     */
    private TextView tvNickname;
    /**
     * 错误提示
     */
    private TextView tvTip;

    public AudienceErrorStateView(@NonNull Context context) {
        super(context);
        init();
    }

    public AudienceErrorStateView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public AudienceErrorStateView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.view_anchor_finishing_living, this, true);
        ivBgView = findViewById(R.id.iv_finishing_bg);
        ivPortrait = findViewById(R.id.iv_finishing_anchor_portrait);
        tvNickname = findViewById(R.id.tv_finishing_anchor_naming);
        tvTip = findViewById(R.id.tv_finishing_tip);
    }

    /**
     * 基础信息渲染
     *
     * @param portraitUrl 头像url
     * @param nickname    昵称
     */
    public void renderInfo(String portraitUrl, String nickname) {
        ImageLoader.with(getContext().getApplicationContext()).circleLoad(portraitUrl, ivPortrait);
        ImageLoader.with(getContext().getApplicationContext()).load(portraitUrl).blurCenterCrop(15, 5).into(ivBgView);
        tvNickname.setText(nickname);
    }

    /**
     * 更新错误类型
     *
     * @param type     类型详见 {@link #TYPE_ERROR} {@link #TYPE_FINISHED}
     * @param listener 按钮点击监听
     */
    public void updateType(int type, ClickButtonListener listener) {
        View back = findViewById(R.id.tv_error_back);
        View retry = findViewById(R.id.tv_error_retry);
        Group groupFinished = findViewById(R.id.group_finished);
        Group groupError = findViewById(R.id.group_error);

        if (type == TYPE_ERROR) {
            groupFinished.setVisibility(GONE);
            groupError.setVisibility(VISIBLE);
            back.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onBackClick(v);
                }
            });

            retry.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onRetryClick(v);
                }
            });
            tvTip.setText("跟主播走丢了");
        } else if (type == TYPE_FINISHED) {
            groupFinished.setVisibility(VISIBLE);
            groupError.setVisibility(GONE);
            tvTip.setText("直播已结束啦");
            View errorBack = findViewById(R.id.tv_finishing_back);
            errorBack.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onBackClick(v);
                }
            });
        }
    }

    public interface ClickButtonListener {
        void onBackClick(View view);

        void onRetryClick(View view);
    }
}
