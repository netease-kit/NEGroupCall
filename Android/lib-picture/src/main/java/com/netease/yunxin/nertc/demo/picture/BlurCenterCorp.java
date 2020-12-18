package com.netease.yunxin.nertc.demo.picture;

import android.content.Context;
import android.graphics.Bitmap;

import androidx.annotation.NonNull;

import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool;
import com.bumptech.glide.load.resource.bitmap.TransformationUtils;
import com.bumptech.glide.util.Util;

import java.nio.ByteBuffer;
import java.security.MessageDigest;

import jp.wasabeef.glide.transformations.BlurTransformation;

/**
 * Created by luc on 2020/12/2.
 * <p>
 * 合并高斯模糊以及中心裁切效果。
 */
class BlurCenterCorp extends BlurTransformation {
    private static final String ID = "com.netease.yunxin.nertc.demo.picture.BlurCenterCorp";
    private static final byte[] ID_BYTES = ID.getBytes(CHARSET);

    private final int tempRadius;

    private final int tempSampling;


    public BlurCenterCorp(int radius, int sampling) {
        super(radius, sampling);
        this.tempRadius = radius;
        this.tempSampling = sampling;
    }

    @Override
    protected Bitmap transform(@NonNull Context context, @NonNull BitmapPool pool, @NonNull Bitmap toTransform, int outWidth, int outHeight) {
        Bitmap bitmap = TransformationUtils.centerCrop(pool, toTransform, outWidth, outHeight);
        return super.transform(context, pool, bitmap, outWidth, outHeight);
    }

    @Override
    public int hashCode() {
        int code = Util.hashCode(tempRadius, tempSampling);
        return Util.hashCode(ID.hashCode(), Util.hashCode(code));
    }

    @Override
    public void updateDiskCacheKey(@NonNull MessageDigest messageDigest) {
        messageDigest.update(ID_BYTES);

        byte[] radiusData = ByteBuffer.allocate(8).putInt(tempRadius).putInt(tempSampling).array();
        messageDigest.update(radiusData);
    }
}
