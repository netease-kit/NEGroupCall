package com.netease.biz_live.yunxin.live.audience.utils;

import android.graphics.SurfaceTexture;
import android.text.TextUtils;
import android.util.Log;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;

import com.netease.neliveplayer.sdk.NELivePlayer;
import com.netease.neliveplayer.sdk.constant.NEBufferStrategy;
import com.netease.neliveplayer.sdk.model.NEAutoRetryConfig;
import com.netease.yunxin.android.lib.historian.Historian;
import com.netease.yunxin.nertc.demo.basic.BaseActivity;

import java.io.IOException;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;

/**
 * Created by luc on 2020/11/11.
 * <p>
 * 包含播放器整体控制逻辑
 * <p>
 * 画面比例 single-720:1280, pk-720:640
 */
public final class PlayerControl {

    /**
     * 视频播放回调
     */
    private final PlayerNotify notify;
    /**
     * 播放器实例
     */
    private final NELivePlayer player = NELivePlayer.create();
    /**
     * 内部播放器回调代理
     */
    private final PlayerNotify innerNotify = new PlayerNotify() {
        @Override
        public void onPreparing() {
            if (isReleased()) {
                return;
            }
            if (notify != null) {
                notify.onPreparing();
            }
        }

        @Override
        public void onPlaying() {
            if (isReleased()) {
                return;
            }
            if (notify != null) {
                notify.onPlaying();
            }
        }

        @Override
        public void onError() {
            if (isReleased()) {
                return;
            }

            if (notify != null) {
                notify.onError();
            }
        }

        @Override
        public void onVideoSizeChanged(int width, int height) {
            if (isReleased()) {
                return;
            }
            if (notify != null) {
                notify.onVideoSizeChanged(width, height);
            }
        }
    };

    /**
     * 播放器拉流准备完成回调
     */
    private final NELivePlayer.OnPreparedListener preparedListener = neLivePlayer -> {
        if (isReleased()) {
            return;
        }
        // 视频开始播放
        if (player != null) {
            player.start();
        }
        Historian.e("PlayerControl", "player is playing.");
        // 播放回调
        innerNotify.onPlaying();
    };

    /**
     * 播放器拉流错误回调
     */
    private final NELivePlayer.OnErrorListener errorListener = (neLivePlayer, errorCode, extra) -> {
        player.release();
        Historian.e("PlayerControl", "errorCode is " + errorCode + ", extra info is " + extra);
        innerNotify.onError();
        return true;
    };

    /**
     * 播放器拉流尺寸变化回调
     */
    private final NELivePlayer.OnVideoSizeChangedListener videoSizeChangedListener = (neLivePlayer, width, height, sarNum, sarDen) -> {
        if (isReleased()) {
            return;
        }
        Historian.e("PlayerControl", "video size is Changed, width is " + width + ", height is " + height);
        innerNotify.onVideoSizeChanged(width, height);
    };

    /**
     * 视频渲染区域
     */
    private TextureView renderView;
    /**
     * 当前播放的视频Url
     */
    private String currentUrl;

    /**
     * 播放器构造
     *
     * @param activity 播放器所在 activity，通过声明周期监听控制播放器暂停，播放
     * @param notify   视频控制回调
     */
    public PlayerControl(@NonNull BaseActivity activity, PlayerNotify notify) {
        this.notify = notify;

        // 页面声明周期监听 控制播放器 播放/暂停
        activity.getLifecycle().addObserver((LifecycleEventObserver) (source, event) -> {
            if (event == Lifecycle.Event.ON_DESTROY || (event == Lifecycle.Event.ON_PAUSE && activity.isFinishing())) {
                release();
            }
        });
    }

    /**
     * 播放器重置
     */
    public void reset() {
        player.reset();
    }

    /**
     * 进行播放准备，设置 拉流地址，视频渲染区域
     *
     * @param url        拉流地址
     * @param renderView 视频渲染区域
     */
    public void prepareToPlay(String url, TextureView renderView) {
        this.currentUrl = url;
        this.renderView = renderView;
        renderView.setVisibility(View.VISIBLE);
        doPreparePlayAction();
    }

    /**
     * 执行预播放准备动作
     */
    private void doPreparePlayAction() {
        // 回调准备中回调
        innerNotify.onPreparing();
        if (isReleased()) {
            return;
        }
        NEAutoRetryConfig retryConfig = new NEAutoRetryConfig();
        retryConfig.count = 1;
        retryConfig.delayArray = new long[]{5};
        player.setAutoRetryConfig(retryConfig);
        // 直播缓存策略，速度优先
        player.setBufferStrategy(NEBufferStrategy.NELPTOPSPEED);
        // 设置相关回调
        player.setOnPreparedListener(preparedListener);
        player.setOnErrorListener(errorListener);
        player.setOnVideoSizeChangedListener(videoSizeChangedListener);
        // 保证渲染view为可见的
        renderView.setVisibility(View.VISIBLE);
        // 设置拉流地址
        try {
            player.setDataSource(currentUrl);
        } catch (IOException e) {
            e.printStackTrace();
            // 拉流错误直接回到错误
            innerNotify.onError();
        }
        // prepare 阶段，当前 textureView 存在可用的 surface
        if (renderView.isAvailable()) {
            // 设置surface并调用异步接口
            player.setSurface(new Surface(renderView.getSurfaceTexture()));
            player.prepareAsync();
        } else {
            // 若 surface 不可用，需要监听回调信息
            renderView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
                @Override
                public void onSurfaceTextureAvailable(@NonNull SurfaceTexture surface, int width, int height) {
                    player.setSurface(new Surface(surface));
                    player.prepareAsync();
                }

                @Override
                public void onSurfaceTextureSizeChanged(@NonNull SurfaceTexture surface, int width, int height) {
                }

                @Override
                public boolean onSurfaceTextureDestroyed(@NonNull SurfaceTexture surface) {
                    return true;
                }

                @Override
                public void onSurfaceTextureUpdated(@NonNull SurfaceTexture surface) {
                }
            });
        }
    }

    /**
     * 播放器资源释放避免内存占用过大
     */
    public void release() {
        if (player != null) {
            player.release();
        }
        renderView = null;
        currentUrl = null;
    }

    /**
     * 当前播放器是否已经资源释放
     */
    public boolean isReleased() {
        return TextUtils.isEmpty(currentUrl) || renderView == null || player == null;
    }

    /**
     * 自定义封装播放器回调
     */
    public interface PlayerNotify {
        /**
         * 播放器开始准备阶段调用
         */
        void onPreparing();

        /**
         * 播放器完成准备刚进入播放时回调
         */
        void onPlaying();

        /**
         * 拉流过程中出现错误或设置拉流地址有误回调
         */
        void onError();

        /**
         * 拉流资源尺寸发生变化时回调
         *
         * @param width  当前视频流宽度
         * @param height 当前视频流高度
         */
        void onVideoSizeChanged(int width, int height);
    }
}
