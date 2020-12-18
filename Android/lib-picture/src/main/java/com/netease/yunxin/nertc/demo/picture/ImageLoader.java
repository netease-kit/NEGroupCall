package com.netease.yunxin.nertc.demo.picture;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.widget.ImageView;

import androidx.annotation.DrawableRes;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;

import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestManager;

/**
 * Created by luc on 2020/11/13.
 */
public final class ImageLoader {
    private final RequestManager glideRequestManager;

    private ImageLoader(RequestManager manager) {
        this.glideRequestManager = manager;
    }

    public static ImageLoader with(Context context) {
        return new ImageLoader(Glide.with(context));
    }

    public static ImageLoader with(Activity activity) {
        return new ImageLoader(Glide.with(activity));
    }

    public static ImageLoader with(FragmentActivity activity) {
        return new ImageLoader(Glide.with(activity));
    }

    public static ImageLoader with(Fragment fragment) {
        return new ImageLoader(Glide.with(fragment));
    }

    public static ImageLoader with(View view) {
        return new ImageLoader(Glide.with(view));
    }

    public LoadHelper asGif() {
        return new LoadHelper(glideRequestManager.asGif());
    }

    public LoadHelper asBitmap() {
        return new LoadHelper(glideRequestManager.asBitmap());
    }

    public LoadHelper asDrawable() {
        return new LoadHelper(glideRequestManager.asDrawable());
    }


    public LoadHelper load(String url) {
        return new LoadHelper(glideRequestManager.load(url));
    }

    public LoadHelper load(Bitmap bitmap) {
        return new LoadHelper(glideRequestManager.load(bitmap));
    }

    public LoadHelper load(Drawable drawable) {
        return new LoadHelper(glideRequestManager.load(drawable));
    }

    public LoadHelper load(@DrawableRes int resId) {
        return new LoadHelper(glideRequestManager.load(resId));
    }

    public void commonLoad(String url, ImageView view) {
        load(url).centerCrop().diskCacheAll().into(view);
    }

    public void commonLoad(@DrawableRes int resId, ImageView view) {
        load(resId).centerCrop().diskCacheAll().into(view);
    }

    public void circleLoad(String url, ImageView view) {
        load(url).circleCrop().diskCacheAll().into(view);
    }

    public void circleLoad(@DrawableRes int resId, ImageView view) {
        load(resId).circleCrop().diskCacheAll().into(view);
    }

    public void roundedCorner(String url, int roundingRadius, ImageView view) {
        load(url).diskCacheAll().roundedCornerCenterCrop(roundingRadius).into(view);
    }

    public void roundedCorner(@DrawableRes int resId, int roundingRadius, ImageView view) {
        load(resId).diskCacheAll().roundedCornerCenterCrop(roundingRadius).into(view);
    }
}
