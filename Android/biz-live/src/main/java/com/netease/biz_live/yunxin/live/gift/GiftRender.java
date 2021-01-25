package com.netease.biz_live.yunxin.live.gift;

import android.animation.Animator;
import android.view.View;

import com.airbnb.lottie.LottieAnimationView;

import java.util.LinkedList;
import java.util.Queue;

import androidx.annotation.RawRes;

/**
 * Created by luc on 2020/11/24.
 */
public class GiftRender {
    private final Queue<Integer> giftQueue = new LinkedList<>();
    private LottieAnimationView animationView;
    private boolean isAnimating = false;

    public void init(LottieAnimationView animationView) {
        this.animationView = animationView;
        this.animationView.addAnimatorListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                animationView.setVisibility(View.GONE);
                if (!giftQueue.isEmpty()) {
                    playAnim(giftQueue.poll());
                } else {
                    isAnimating = false;
                }
            }

            @Override
            public void onAnimationCancel(Animator animation) {
                isAnimating = !giftQueue.isEmpty();
            }

            @Override
            public void onAnimationRepeat(Animator animation) {
            }
        });
    }

    public synchronized void addGift(@RawRes int gitResId) {
        giftQueue.add(gitResId);
        if (!isAnimating) {
            isAnimating = true;
            playAnim(giftQueue.poll());
        }
    }

    public void release() {
        giftQueue.clear();
        if (animationView != null) {
            animationView.cancelAnimation();
            animationView.setVisibility(View.GONE);
        }
    }

    private void playAnim(@RawRes Integer gitResId) {
        if (gitResId == null) {
            return;
        }
        animationView.setVisibility(View.VISIBLE);
        animationView.setAnimation(gitResId);
        animationView.playAnimation();
    }
}
