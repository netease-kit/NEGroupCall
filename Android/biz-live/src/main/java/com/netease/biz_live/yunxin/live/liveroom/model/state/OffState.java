package com.netease.biz_live.yunxin.live.liveroom.model.state;

import com.netease.biz_live.yunxin.live.liveroom.model.impl.NERTCLiveRoomImpl;

public class OffState extends LiveState {
    public OffState(NERTCLiveRoomImpl liveRoom) {
        super(liveRoom);
        status = LiveState.STATE_LIVE_OFF;
    }

    @Override
    public void callPk() {

    }

    @Override
    public void invited() {

    }

    @Override
    public void startPk() {

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

    }
}
