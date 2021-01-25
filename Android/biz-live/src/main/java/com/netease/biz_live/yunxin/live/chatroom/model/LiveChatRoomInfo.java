package com.netease.biz_live.yunxin.live.chatroom.model;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by luc on 2020/11/18.
 * <p>
 * 聊天室房间信息
 */
public final class LiveChatRoomInfo {
    /**
     * 聊天室 id
     */
    public final String roomId;
    /**
     * 聊天室创建者（当前主播）
     */
    public final String creator;

    /**
     * 主播在 rtc 房间内id标示
     */
    public final String fromUserAvRoomId;
    /**
     * 聊天室在线用户量
     */
    private final AtomicInteger onlineUserCount = new AtomicInteger(0);

    public LiveChatRoomInfo(String roomId, String creator, String fromUserAvRoomId) {
        this(roomId, creator, fromUserAvRoomId, 0);
    }

    public LiveChatRoomInfo(String roomId, String creator, String fromUserAvRoomId, int onlineUserCount) {
        this.roomId = roomId;
        this.fromUserAvRoomId = fromUserAvRoomId;
        this.creator = creator;
        this.onlineUserCount.set(onlineUserCount);
    }

    /**
     * 用户增加
     */
    public int increaseCount() {
        return onlineUserCount.incrementAndGet();
    }

    /**
     * 用户减少
     */
    public int decreaseCount() {
        return onlineUserCount.decrementAndGet();
    }

    /**
     * 房间用户数量
     */
    public int getOnlineUserCount() {
        return onlineUserCount.intValue();
    }

    /**
     * 设置房间用户数
     */
    public void setOnlineUserCount(int onlineUserCount) {
        this.onlineUserCount.set(onlineUserCount);
    }
}
