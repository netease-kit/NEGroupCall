package com.netease.biz_live.yunxin.live.ui.widget;

import android.content.Context;
import android.os.CountDownTimer;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.adapter.LiveBaseAdapter;
import com.netease.biz_live.yunxin.live.chatroom.model.AudienceInfo;
import com.netease.yunxin.android.lib.picture.ImageLoader;

import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.Group;
import androidx.constraintlayout.widget.Guideline;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by luc on 2020/11/23.
 * <p>
 * 用于控制 pk 浮层UI展示
 */
public class PKControlView extends FrameLayout {
    private Guideline glPkRatio;
    private TextView tvScore;
    private TextView tvOtherScore;
    private TextView tvCountTime;
    private FrameLayout flVideoContainer;

    private InnerAdapter pkRankingAdapter;
    private InnerAdapter otherPkRankingAdapter;

    private View pkResultFlag;
    private View otherPkResultFlag;

    private TextView tvOtherAnchorName;
    private ImageView ivOtherAnchorPortrait;
    private Group gpOtherAnchorInfo;

    public PKControlView(@NonNull Context context) {
        super(context);
        initView();
    }

    public PKControlView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    public PKControlView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView();
    }

    private void initView() {
        LayoutInflater.from(getContext()).inflate(R.layout.view_pk_whole_layout, this, true);

        // pk 值对比百分比控制
        glPkRatio = findViewById(R.id.gl_pk_ration);

        // pk 值比分
        tvScore = findViewById(R.id.tv_pk_score);
        tvOtherScore = findViewById(R.id.tv_other_pk_score);

        // 倒计时view
        tvCountTime = findViewById(R.id.tv_countdown_time);

        // 排行榜UI
        RecyclerView rvRanking = findViewById(R.id.rv_pk_ranking);
        rvRanking.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        pkRankingAdapter = new InnerAdapter(getContext(), false);
        rvRanking.setAdapter(pkRankingAdapter);

        RecyclerView rvOtherRanking = findViewById(R.id.rv_other_pk_ranking);
        rvOtherRanking.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, true));
        otherPkRankingAdapter = new InnerAdapter(getContext(), true);
        rvOtherRanking.setAdapter(otherPkRankingAdapter);

        // pk 结果图标
        pkResultFlag = findViewById(R.id.iv_pk_result);
        otherPkResultFlag = findViewById(R.id.iv_other_pk_result);

        // 视频播放容器
        flVideoContainer = findViewById(R.id.fl_group);

        // pk 主播信息
        tvOtherAnchorName = findViewById(R.id.tv_other_anchor_name);
        ivOtherAnchorPortrait = findViewById(R.id.iv_other_anchor_portrait);
        gpOtherAnchorInfo = findViewById(R.id.gp_other_anchor_info);
    }

    /**
     * 获取视频区域展示容器
     */
    public FrameLayout getVideoContainer() {
        return flVideoContainer;
    }

    /**
     * 更新主播信息
     *
     * @param name   主播名称
     * @param avatar 主播头像
     */
    public void updatePkAnchorInfo(String name, String avatar) {
        gpOtherAnchorInfo.setVisibility(VISIBLE);
        tvOtherAnchorName.setText(name);
        ImageLoader.with(getContext().getApplicationContext()).circleLoad(avatar, ivOtherAnchorPortrait);
    }

    /**
     * 设置分数变化
     *
     * @param score      当前主播分数
     * @param otherScore 对方主播分数
     */
    public void updateScore(long score, long otherScore) {
        tvScore.setText(String.valueOf(score));
        tvOtherScore.setText(String.valueOf(otherScore));
        // 如果有两方比分都为 0 则设置百分比为 0.5
        if (score == 0 && otherScore == 0) {
            glPkRatio.setGuidelinePercent(0.5f);
            return;
        }
        float percent = score / (score + otherScore + 0.f);
        glPkRatio.setGuidelinePercent(percent);
    }

    /**
     * 处理pk 结果图标展示
     *
     * @param show          是否展示
     * @param anchorSuccess 当前主播是否胜利
     */
    public void handleResultFlag(boolean show, boolean anchorSuccess) {
        pkResultFlag.setVisibility(show ? VISIBLE : INVISIBLE);
        otherPkResultFlag.setVisibility(show ? VISIBLE : INVISIBLE);
        if (!show) {
            return;
        }

        pkResultFlag.setEnabled(anchorSuccess);
        otherPkResultFlag.setEnabled(!anchorSuccess);
    }

    /**
     * 倒计时控制器
     *
     * @param leftMillis 倒计时时间
     */
    public WrapperCountDownTimer createCountDownTimer(long leftMillis) {
        return new WrapperCountDownTimer(leftMillis, new TimerListener() {
            @Override
            public void onStart(long startTime) {
                tvCountTime.setText(formatTime(startTime));
            }

            @Override
            public void onTick(long millisUntilFinished) {
                tvCountTime.setText(formatTime(millisUntilFinished));
            }

            @Override
            public void onStop() {
                tvCountTime.setText(formatTime(0L));
            }
        });
    }

    /**
     * 格式化倒计时格式
     *
     * @param timeMillis 时间，单位毫秒
     */
    private String formatTime(long timeMillis) {
        long timeSeconds = timeMillis / 1000L;
        long timeMinute = timeSeconds / 60L;
        long leftSeconds = timeSeconds % 60L;
        return "PK " + timeMinute + ":" + leftSeconds;
    }


    /**
     * 更新排行榜数据
     *
     * @param audienceList      当前主播排行榜
     * @param otherAudienceList 对方主播排行榜
     */
    public void updateRanking(List<AudienceInfo> audienceList, List<AudienceInfo> otherAudienceList) {
        pkRankingAdapter.updateDataSource(audienceList);
        otherPkRankingAdapter.updateDataSource(otherAudienceList);
    }

    /**
     * 重置pk 控制view
     */
    public void reset() {
        updateRanking(null, null);
        handleResultFlag(false, false);
        updateScore(0,0);
    }

    /**
     * 内部排行榜 adapter
     */
    private static class InnerAdapter extends LiveBaseAdapter<AudienceInfo> {
        private static final int MAX_AUDIENCE_COUNT = 3;
        private final boolean other;

        public InnerAdapter(Context context, boolean other) {
            super(context);
            this.other = other;
        }

        @Override
        protected int getLayoutId(int viewType) {
            return R.layout.view_item_pk_ranking_audience;
        }

        @Override
        protected LiveViewHolder onCreateViewHolder(View itemView) {
            return new LiveViewHolder(itemView);
        }

        @Override
        protected void onBindViewHolder(LiveViewHolder holder, AudienceInfo itemData, int position) {
            ImageView ivPortrait = holder.getView(R.id.iv_item_audience_portrait);
            ImageLoader.with(context.getApplicationContext()).circleLoad(itemData.avatar, ivPortrait);
            ivPortrait.setEnabled(!other);

            TextView tvOrder = holder.getView(R.id.tv_item_audience_order);
            tvOrder.setText(String.valueOf(position + 1));
            tvOrder.setEnabled(!other);
        }

        @Override
        public int getItemCount() {
            return Math.min(super.getItemCount(), MAX_AUDIENCE_COUNT);
        }
    }

    /**
     * 定时器封装
     */
    public static class WrapperCountDownTimer {
        private final CountDownTimer countDownTimer;
        private final TimerListener timerListener;
        private final long leftTimeMillis;

        public WrapperCountDownTimer(long leftMillis, TimerListener timerListener) {
            this.leftTimeMillis = leftMillis;
            this.timerListener = timerListener;
            this.countDownTimer = new CountDownTimer(leftMillis, 1000L) {
                @Override
                public void onTick(long millisUntilFinished) {
                    if (timerListener != null) {
                        timerListener.onTick(millisUntilFinished);
                    }
                }

                @Override
                public void onFinish() {
                    if (timerListener != null) {
                        timerListener.onStop();
                    }
                }
            };
        }

        /**
         * 定时器停止
         */
        public void stop() {
            countDownTimer.cancel();
            if (timerListener != null) {
                timerListener.onStop();
            }
        }

        /**
         * 定时器开始倒计时
         */
        public void start() {
            if (timerListener != null) {
                timerListener.onStart(leftTimeMillis);
            }
            countDownTimer.start();
        }
    }

    /**
     * 内部定时器回调
     */
    private interface TimerListener {
        void onStart(long startTime);

        void onTick(long millisUntilFinished);

        void onStop();
    }
}
