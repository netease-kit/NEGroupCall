package com.netease.biz_live.yunxin.live.audience.utils;

import android.graphics.Matrix;
import android.graphics.PointF;
import android.view.TextureView;

import com.netease.biz_live.yunxin.live.constant.LiveParams;

/**
 * Created by wangqiang04 on 1/8/21.
 * <p>
 * 当用户观看主播 pk 状态与 单人状态互相切换时需要更改当前视频 view 的尺寸大小适配
 */
public final class PlayerVideoSizeUtils {
    private PlayerVideoSizeUtils() {
    }

    /**
     * 调整播放区域以及位置（更改成 单人直播状态）
     */
    public static void adjustViewSizePosition(TextureView renderView) {
        adjustViewSizePosition(renderView, false, null);
    }

    /**
     * 调整播放区域以及位置，单人直播下以{@link LiveParams#SIGNAL_HOST_LIVE_HEIGHT,LiveParams#SIGNAL_HOST_LIVE_WIDTH}
     * 比例确定播放区域的大小，放缩到没有黑边；
     * <p>
     * pk 直播下以{@link LiveParams#PK_LIVE_HEIGHT,LiveParams#PK_LIVE_WIDTH}
     * 比例确定播放区域大小，放缩到一边填充完全为准；
     *
     * @param isPk 是否为 pk 状态
     */
    public static void adjustViewSizePosition(TextureView renderView, boolean isPk, PointF pivot) {
        if (renderView == null) {
            return;
        }

        renderView.post(() -> {
            if (renderView == null) {
                return;
            }
            int width = renderView.getWidth();
            int height = renderView.getHeight();

            if (isPk) {
                adjustForPk(renderView, width, height, pivot);
            } else {
                adjustForNormal(renderView, width, height);
            }
        });
    }

    /**
     * pk 态下页面调整
     */
    private static void adjustForPk(TextureView renderView, int viewWidth, int viewHeight, PointF pivot) {
        float videoWidth = LiveParams.PK_LIVE_WIDTH * 2;
        float videoHeight = LiveParams.PK_LIVE_HEIGHT;

        Matrix matrix = new Matrix();
        matrix.preTranslate((viewWidth - videoWidth) / 2f, (viewHeight - videoHeight) / 2f);
        matrix.preScale(videoWidth / viewWidth, videoHeight / viewHeight);
        matrix.postScale(1.0f, 1.0f, viewWidth / 2f, viewHeight / 2f);

        // 填充满页面整体区域
        float sx = viewWidth / videoWidth;
        float sy = viewHeight / videoHeight;
        float minScale = Math.min(sx, sy);
        matrix.postScale(minScale, minScale, viewWidth / 2f, viewHeight / 2f);
        matrix.postTranslate(pivot.x - viewWidth / 2f, pivot.y - viewHeight / 2f);

        renderView.setTransform(matrix);
        renderView.postInvalidate();
    }

    /**
     * 单人直播下页面调整
     */
    private static void adjustForNormal(TextureView renderView, float viewWidth, float viewHeight) {
        // 目标视频比例
        float videoWidth = LiveParams.SIGNAL_HOST_LIVE_WIDTH;
        float videoHeight = LiveParams.SIGNAL_HOST_LIVE_HEIGHT;

        // 填充满 720*1280区域
        Matrix matrix = new Matrix();
        // 平移 使 view 中心和 video 中心一致
        matrix.preTranslate((viewWidth - videoWidth) / 2f, (viewHeight - videoHeight) / 2f);
        // 缩放 view 至原视频大小
        matrix.preScale(videoWidth / viewWidth, videoHeight / viewHeight);
        // 放缩至 720*1280
        matrix.postScale(1.0f, 1.0f, viewWidth / 2f, viewHeight / 2f);

        // 填充满页面整体区域
        float sx = viewWidth / videoWidth;
        float sy = viewHeight / videoHeight;
        float maxScale = Math.max(sx, sy);
        matrix.postScale(maxScale, maxScale, viewWidth / 2f, viewHeight / 2f);
        renderView.setTransform(matrix);
        renderView.postInvalidate();
    }

    /**
     * 直播拉流时，当用户从单人进入 pk 状态由于拉流延迟问题出现 信令和视频流不匹配状态，因此当接受到 pk 消息时，先将视频尺寸适配成 pk 尺寸宽度的一半，避免
     * 视频流拉伸
     */
    public static void adjustForPreparePk(TextureView renderView, PointF pivot) {
        if (renderView == null) {
            return;
        }

        renderView.post(() -> {
            if (renderView == null) {
                return;
            }
            int width = renderView.getWidth();
            int height = renderView.getHeight();
            adjustForPreparePk(renderView, width, height, pivot);
        });
    }

    private static void adjustForPreparePk(TextureView renderView, int viewWidth, int viewHeight, PointF pivot) {
        float tempWidth = LiveParams.PK_LIVE_WIDTH;
        float tempHeight = LiveParams.PK_LIVE_HEIGHT;

        float videoWidth = LiveParams.SIGNAL_HOST_LIVE_WIDTH;
        float videoHeight = LiveParams.SIGNAL_HOST_LIVE_HEIGHT;

        float sx = tempWidth / videoWidth;
        float sy = tempHeight / videoHeight;
        float maxScale = Math.max(sx, sy);

        Matrix matrix = new Matrix();
        matrix.preTranslate((viewWidth - videoWidth) / 2f, (viewHeight - videoHeight) / 2f);
        matrix.preScale(videoWidth / viewWidth, videoHeight / viewHeight);
        matrix.postScale(maxScale, maxScale, viewWidth / 2f, viewHeight / 2f);

        // 填充满页面整体区域
        sx = viewWidth / 2f / tempWidth;
        sy = viewHeight / tempHeight;
        float minScale = Math.min(sx, sy);
        matrix.postScale(minScale, minScale, viewWidth / 2f, viewHeight / 2f);
        matrix.postTranslate(-viewWidth / 4f, pivot.y - viewHeight / 2f);

        renderView.setTransform(matrix);
        renderView.postInvalidate();

    }
}
