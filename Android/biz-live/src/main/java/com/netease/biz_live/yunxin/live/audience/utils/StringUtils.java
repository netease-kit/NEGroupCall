package com.netease.biz_live.yunxin.live.audience.utils;

import java.text.DecimalFormat;

/**
 * Created by luc on 2020/12/1.
 */
public final class StringUtils {

    /**
     * 格式化展示云币数量，超过10000 展示为 xx万
     *
     * @param coinCount 云币总数
     * @return 云币数字符串
     */
    public static String getCoinCount(long coinCount) {
        if (coinCount < 10000) {
            return coinCount + "云币";
        }
        DecimalFormat decimalFormat = new DecimalFormat("#.##");
        return decimalFormat.format(coinCount / 10000.f) + "万云币";
    }

    /**
     * 格式化展示观众数，超过 1w 展示 xx万，超过 1亿展示 xx亿
     *
     * @param audienceCount 观众实际数
     * @return 观众数字符串
     */
    public static String getAudienceCount(int audienceCount) {
        if (audienceCount < 1000) {
            return String.valueOf(Math.max(audienceCount, 0));
        }
        if (audienceCount < 100000000) {
            DecimalFormat decimalFormat = new DecimalFormat("#.##");
            return decimalFormat.format(audienceCount / 10000.f) + "万";
        }
        DecimalFormat decimalFormat = new DecimalFormat("#.##");
        return decimalFormat.format(audienceCount / 100000000.f) + "亿";
    }
}
