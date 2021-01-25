package com.netease.biz_live.yunxin.live.gift;

import android.util.SparseArray;

import com.netease.biz_live.R;

import java.util.Arrays;
import java.util.List;

/**
 * Created by luc on 2020/11/19.
 * <p>
 * 礼物内容存储集合
 */
public final class GiftCache {
    private static final SparseArray<GiftInfo> TOTAL_GIFT = new SparseArray<>();

    static {
        // 礼物-荧光棒
        TOTAL_GIFT.append(1, new GiftInfo(1, "荧光棒", 9, R.drawable.icon_gift_lifght_stick, R.raw.anim_gift_light_stick));
        // 礼物-安排
        TOTAL_GIFT.append(2, new GiftInfo(2, "安排", 99, R.drawable.icon_gift_plan, R.raw.anim_gift_plan));
        // 礼物-跑车
        TOTAL_GIFT.append(3, new GiftInfo(3, "跑车", 199, R.drawable.icon_gift_super_car, R.raw.anim_gift_super_car));
        // 礼物-火箭
        TOTAL_GIFT.append(4, new GiftInfo(4, "火箭", 999, R.drawable.icon_gift_rocket, R.raw.anim_gift_rocket));
    }

    /**
     * 获取礼物详情
     *
     * @param giftId 礼物id
     */
    public static GiftInfo getGift(int giftId) {
        return TOTAL_GIFT.get(giftId);
    }

    /**
     * 获取礼物列表
     */
    public static List<GiftInfo> getGiftList() {
        return Arrays.asList(
                getGift(1),
                getGift(2),
                getGift(3),
                getGift(4)
        );
    }
}
