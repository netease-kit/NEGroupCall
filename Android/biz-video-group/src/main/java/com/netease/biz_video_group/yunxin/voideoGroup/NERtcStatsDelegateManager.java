package com.netease.biz_video_group.yunxin.voideoGroup;

import com.netease.biz_video_group.yunxin.voideoGroup.model.NERtcStatsObserverTemp;
import com.netease.lava.nertc.sdk.stats.NERtcAudioRecvStats;
import com.netease.lava.nertc.sdk.stats.NERtcAudioSendStats;
import com.netease.lava.nertc.sdk.stats.NERtcNetworkQualityInfo;
import com.netease.lava.nertc.sdk.stats.NERtcStats;
import com.netease.lava.nertc.sdk.stats.NERtcVideoRecvStats;
import com.netease.lava.nertc.sdk.stats.NERtcVideoSendStats;

import java.util.ArrayList;

public class NERtcStatsDelegateManager extends NERtcStatsObserverTemp {
    private ArrayList<NERtcStatsObserverTemp> statsList;

    private volatile static NERtcStatsDelegateManager instance;

    public static NERtcStatsDelegateManager getInstance(){
        if(instance == null){
            synchronized (NERtcStatsDelegateManager.class){
                if(instance == null){
                    instance = new NERtcStatsDelegateManager();
                }
            }
        }
        return instance;
    }

    private NERtcStatsDelegateManager(){
        statsList = new ArrayList<>();
    }



    public void addObserver(NERtcStatsObserverTemp observerTemp){
        statsList.add(observerTemp);
    }

    public void removeObserver(NERtcStatsObserverTemp observerTemp){
        statsList.remove(observerTemp);
    }

    public void clearAll(){
        statsList.clear();
    }

    @Override
    public void onRtcStats(NERtcStats neRtcStats) {
        for(NERtcStatsObserverTemp observerTemp:statsList){
            observerTemp.onRtcStats(neRtcStats);
        }
    }

    @Override
    public void onLocalAudioStats(NERtcAudioSendStats neRtcAudioSendStats) {
        for(NERtcStatsObserverTemp observerTemp:statsList){
            observerTemp.onLocalAudioStats(neRtcAudioSendStats);
        }
    }

    @Override
    public void onRemoteAudioStats(NERtcAudioRecvStats[] neRtcAudioRecvStats) {
        for(NERtcStatsObserverTemp observerTemp:statsList){
            observerTemp.onRemoteAudioStats(neRtcAudioRecvStats);
        }
    }

    @Override
    public void onLocalVideoStats(NERtcVideoSendStats neRtcVideoSendStats) {
        for(NERtcStatsObserverTemp observerTemp:statsList){
            observerTemp.onLocalVideoStats(neRtcVideoSendStats);
        }
    }

    @Override
    public void onRemoteVideoStats(NERtcVideoRecvStats[] neRtcVideoRecvStats) {
        for(NERtcStatsObserverTemp observerTemp:statsList){
            observerTemp.onRemoteVideoStats(neRtcVideoRecvStats);
        }
    }

    @Override
    public void onNetworkQuality(NERtcNetworkQualityInfo[] neRtcNetworkQualityInfos) {
        for(NERtcStatsObserverTemp observerTemp:statsList){
            observerTemp.onNetworkQuality(neRtcNetworkQualityInfos);
        }
    }
}
