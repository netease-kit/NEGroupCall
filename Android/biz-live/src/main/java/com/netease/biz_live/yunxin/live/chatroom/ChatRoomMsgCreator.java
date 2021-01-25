package com.netease.biz_live.yunxin.live.chatroom;

import android.content.Context;
import android.graphics.Color;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.utils.ChatMessageSpannableStr;
import com.netease.yunxin.nertc.demo.utils.SpUtils;
import com.netease.yunxin.nertc.module.base.sdk.NESdkBase;

/**
 * Created by luc on 2020/11/11.
 */
public class ChatRoomMsgCreator {
    /**
     * 文字高亮颜色
     */
    private static final int HIGH_COLOR = Color.parseColor("#99ffffff");
    /**
     * 文本信息颜色
     */
    private static final int COMMON_COLOR = Color.WHITE;


    /**
     * 进入房间
     */
    public static CharSequence createRoomEnter(String userNickName) {
        return new ChatMessageSpannableStr.Builder()
                .append(userNickName, HIGH_COLOR)
                .append(" ")
                .append("进入直播间", HIGH_COLOR)
                .build()
                .getMessageInfo();
    }

    /**
     * 离开房间
     */
    public static CharSequence createRoomExit(String userNickName) {
        return new ChatMessageSpannableStr.Builder()
                .append(userNickName, HIGH_COLOR)
                .append(" ")
                .append("离开直播间", HIGH_COLOR)
                .build()
                .getMessageInfo();
    }

    /**
     * 创建非主播发送的文本消息
     */
    public static CharSequence createText(String userNickName, String msg) {
        return createText(false, userNickName, msg);
    }

    /**
     * 创建文本消息并标记是否由主播发送
     *
     * @param isAnchor     true 主播发送，false 非主播发送
     * @param userNickName 发送方昵称
     * @param msg          消息内容
     */
    public static CharSequence createText(boolean isAnchor, String userNickName, String msg) {
        ChatMessageSpannableStr.Builder builder = new ChatMessageSpannableStr.Builder();
        if (isAnchor) {
            Context context = NESdkBase.getInstance().getContext();
            int width = SpUtils.dp2pix(context, 30);
            int height = SpUtils.dp2pix(context, 15);
            builder.append(context, R.drawable.icon_msg_anchor_flag, width, height)
                    .append(" ");
        }
        return builder
                .append(userNickName, HIGH_COLOR)
                .append(": ", HIGH_COLOR)
                .append(msg, COMMON_COLOR)
                .build()
                .getMessageInfo();
    }

    /**
     * 创建发送礼物消息
     *
     * @param userNickName 发送方昵称
     * @param giftCount    赠送礼物数量
     * @param giftRes      礼物资源id
     */
    public static CharSequence createGiftReward(String userNickName, int giftCount, int giftRes) {
        Context context = NESdkBase.getInstance().getContext();
        int gifSize = SpUtils.dp2pix(context, 22);
        return new ChatMessageSpannableStr.Builder()
                .append(userNickName, HIGH_COLOR)
                .append(": ", HIGH_COLOR)
                .append("赠送了 × ", COMMON_COLOR)
                .append(String.valueOf(giftCount), COMMON_COLOR)
                .append("个", COMMON_COLOR)
                .append(" ")
                .append(context, giftRes, gifSize, gifSize)
                .build()
                .getMessageInfo();
    }

}
