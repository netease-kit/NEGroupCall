package com.netease.biz_live.yunxin.live.chatroom.control;

/**
 * Created by luc on 2020/11/18.
 * <p>
 * 观众聊天室控制
 */
public interface Audience extends Member {


    /**
     * 获取观众端控制
     */
    static Audience getInstance() {
        return new AudienceImpl();
    }
}
