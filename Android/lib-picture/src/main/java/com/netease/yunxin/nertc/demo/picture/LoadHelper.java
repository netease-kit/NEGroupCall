package com.netease.yunxin.nertc.demo.picture;

import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.widget.ImageView;

import androidx.annotation.DrawableRes;

import com.bumptech.glide.RequestBuilder;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;

import jp.wasabeef.glide.transformations.BlurTransformation;

/**
 * Created by luc on 2020/11/13.
 */
public final class LoadHelper {

    private RequestBuilder<?> glideRequestBuilder;

    LoadHelper(RequestBuilder<?> builder) {
        this.glideRequestBuilder = builder;
    }


    public LoadHelper centerCrop() {
        glideRequestBuilder = glideRequestBuilder.centerCrop();
        return this;
    }

    public LoadHelper fitCenter() {
        glideRequestBuilder = glideRequestBuilder.fitCenter();
        return this;
    }

    public LoadHelper centerInside() {
        glideRequestBuilder = glideRequestBuilder.centerInside();
        return this;
    }

    public LoadHelper circleCrop() {
        glideRequestBuilder = glideRequestBuilder.circleCrop();
        return this;
    }

    public LoadHelper roundedCorner(int roundingRadius) {
        glideRequestBuilder = glideRequestBuilder.transform(new RoundedCorners(roundingRadius));
        return this;
    }

    public LoadHelper roundedCornerCenterCrop(int roundingRadius) {
        glideRequestBuilder = glideRequestBuilder.transform(new RoundedCornersCenterCrop(roundingRadius));
        return this;
    }

    public LoadHelper blur(int radius, int sampling) {
        glideRequestBuilder = glideRequestBuilder.apply(RequestOptions.bitmapTransform(new BlurTransformation(radius, sampling)));
        return this;
    }

    public LoadHelper blurCenterCrop(int radius, int sampling) {
        glideRequestBuilder = glideRequestBuilder.apply(RequestOptions.bitmapTransform(new BlurCenterCorp(radius, sampling)));
        return this;
    }

    public LoadHelper error(@DrawableRes int resId) {
        glideRequestBuilder = glideRequestBuilder.error(resId);
        return this;
    }

    public LoadHelper placeholder(@DrawableRes int resId) {
        glideRequestBuilder = glideRequestBuilder.placeholder(resId);
        return this;
    }

    public LoadHelper fallback(@DrawableRes int resId) {
        glideRequestBuilder = glideRequestBuilder.fallback(resId);
        return this;
    }

    public LoadHelper allHolder(@DrawableRes int resId) {
        return error(resId).placeholder(resId).fallback(resId);
    }

    public LoadHelper load(String url) {
        glideRequestBuilder = glideRequestBuilder.load(url);
        return this;
    }

    public LoadHelper load(Bitmap bitmap) {
        glideRequestBuilder = glideRequestBuilder.load(bitmap);
        return this;
    }

    public LoadHelper load(Drawable drawable) {
        glideRequestBuilder = glideRequestBuilder.load(drawable);
        return this;
    }

    public LoadHelper load(@DrawableRes int resId) {
        glideRequestBuilder = glideRequestBuilder.load(resId);
        return this;
    }

    public LoadHelper diskCacheAll() {
        glideRequestBuilder = glideRequestBuilder.diskCacheStrategy(DiskCacheStrategy.ALL);
        return this;
    }

    public LoadHelper disCacheNone() {
        glideRequestBuilder = glideRequestBuilder.diskCacheStrategy(DiskCacheStrategy.NONE);
        return this;
    }

    public LoadHelper disCacheAutomatic() {
        glideRequestBuilder = glideRequestBuilder.diskCacheStrategy(DiskCacheStrategy.AUTOMATIC);
        return this;
    }

    public LoadHelper disCacheData() {
        glideRequestBuilder = glideRequestBuilder.diskCacheStrategy(DiskCacheStrategy.DATA);
        return this;
    }

    public LoadHelper disCacheResource() {
        glideRequestBuilder = glideRequestBuilder.diskCacheStrategy(DiskCacheStrategy.RESOURCE);
        return this;
    }

    public void into(ImageView view) {
        glideRequestBuilder.into(view);
    }
}
