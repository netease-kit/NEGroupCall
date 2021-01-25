package com.netease.biz_live.yunxin.live.liveroom.model.state;

import com.netease.biz_live.yunxin.live.liveroom.model.impl.NERTCLiveRoomImpl;

public class CalloutState extends LiveState {

    public CalloutState(NERTCLiveRoomImpl liveRoom) {
        super(liveRoom);
        status = STATE_CALL_OUT;
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
        liveRoom.setState(liveRoom.getAcceptState());
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
