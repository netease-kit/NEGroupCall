package com.netease.biz_live.yunxin.live.liveroom.model.state;

import com.netease.biz_live.yunxin.live.liveroom.model.impl.NERTCLiveRoomImpl;

/**
 * 对方已经接受，或者已经接受对方，即将进入PK状态
 */
public class AcceptState extends LiveState {

    public AcceptState(NERTCLiveRoomImpl liveRoom) {
        super(liveRoom);
        status = STATE_ACCEPTED;
    }

    @Override
    public void callPk() {

    }

    @Override
    public void invited() {

    }

    @Override
    public void startPk() {
        this.liveRoom.setState(liveRoom.getPkingState());
    }

    @Override
    public void accept() {

    }

    @Override
    public void release() {
        this.liveRoom.setState(liveRoom.getIdleState());
    }

    @Override
    public void offLive() {
        liveRoom.setState(liveRoom.getOffState());
    }
}
