package com.netease.biz_live.yunxin.live.gift;

import androidx.annotation.DrawableRes;
import androidx.annotation.RawRes;

/**
 * Created by luc on 2020/11/19.
 */
public class GiftInfo {
    /**
     * 礼物id
     */
    public final int giftId;
    /**
     * 礼物名称
     */
    public final String name;
    /**
     * 价值云币数量
     */
    public final long coinCount;
    /**
     * 静态图资源
     */
    public final @DrawableRes
    int staticIconResId;
    /**
     * 动态图资源
     */
    public final @RawRes
    int dynamicIconResId;

    public GiftInfo(int giftId, String name, long coinCount, int staticIconResId, int dynamicIconResId) {
        this.giftId = giftId;
        this.name = name;
        this.coinCount = coinCount;
        this.staticIconResId = staticIconResId;
        this.dynamicIconResId = dynamicIconResId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        GiftInfo info = (GiftInfo) o;

        return giftId == info.giftId;
    }

    @Override
    public int hashCode() {
        return giftId;
    }
}
