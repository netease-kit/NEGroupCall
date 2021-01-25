package com.netease.biz_live.yunxin.live.chatroom.control;

import com.netease.biz_live.yunxin.live.chatroom.custom.AnchorCoinChangedAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PKStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PunishmentStatusAttachment;

/**
 * Created by luc on 2020/11/18.
 * <p>
 * 主播聊天室控制
 */
public interface Anchor extends Member {
    /**
     * 通知 pk 状态
     *
     * @param pkStatus pk 数据
     */
    void notifyPKStatus(PKStatusAttachment pkStatus);

    /**
     * 开始惩罚
     *
     * @param punishmentStatus 惩罚数据
     */
    void notifyPunishmentStatus(PunishmentStatusAttachment punishmentStatus);

    /**
     * 主播云币变化
     *
     * @param attachment 变化数据
     */
    void notifyCoinChanged(AnchorCoinChangedAttachment attachment);

    /**
     * 获取主播端控制
     */
    static Anchor getInstance() {
        return new AnchorImpl();
    }
}
