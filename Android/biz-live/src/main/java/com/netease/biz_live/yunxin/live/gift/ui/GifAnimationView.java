package com.netease.biz_live.yunxin.live.gift.ui;

import android.content.Context;
import android.util.AttributeSet;

import com.airbnb.lottie.LottieAnimationView;

/**
 * Created by luc on 2020/12/7.
 * <p>
 * 当礼物接收到礼物发送时如果为未展示状态则忽略当前礼物动画，即使当前onDetachWindow 也不会暂停动画，
 * 当直播结束手动调用资源释放
 */
public class GifAnimationView extends LottieAnimationView {
    public GifAnimationView(Context context) {
        super(context);
    }

    public GifAnimationView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public GifAnimationView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    public boolean isShown() {
        return true;
    }

    @Override
    public boolean isAnimating() {
        return false;
    }
}
