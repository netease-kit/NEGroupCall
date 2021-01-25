package com.netease.biz_live.yunxin.live.liveroom.model.state;

import com.netease.biz_live.yunxin.live.liveroom.model.impl.NERTCLiveRoomImpl;

public class IdleLiveState extends LiveState {

    public IdleLiveState(NERTCLiveRoomImpl liveRoom) {
        super(liveRoom);
        status = STATE_LIVE_ON;
    }

    @Override
    public void callPk() {
        this.liveRoom.setState(liveRoom.getCallOutState());
    }

    @Override
    public void invited() {
        this.liveRoom.setState(liveRoom.getInvitedState());
    }

    @Override
    public void startPk() {

    }

    @Override
    public void accept() {

    }

    @Override
    public void release() {

    }

    @Override
    public void offLive() {
        liveRoom.setState(liveRoom.getOffState());
    }
}
