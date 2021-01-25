package com.netease.biz_live.yunxin.live.liveroom.model;

import android.content.Context;

import com.netease.biz_live.yunxin.live.liveroom.model.impl.NERTCLiveRoomImpl;
import com.netease.biz_live.yunxin.live.liveroom.model.state.LiveState;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.lava.nertc.sdk.NERtcOption;
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioEffectOption;
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioMixingOption;
import com.netease.lava.nertc.sdk.video.NERtcVideoCallback;
import com.netease.lava.nertc.sdk.video.NERtcVideoConfig;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.avsignalling.builder.InviteParamBuilder;

/**
 * 直播间抽象类（主播端）
 */
public abstract class NERTCLiveRoom {

    public static NERTCLiveRoom sharedInstance() {
        return NERTCLiveRoomImpl.sharedInstance();
    }


    /**
     * 设置组件回调接口
     * <p>
     * 您可以通过 NERTCLiveRoomDelegate 获得 NERTCLiveRoom 的各种状态通知
     *
     * @param delegate 回调接口
     */
    public abstract void setDelegate(NERTCLiveRoomDelegate delegate);

    /**
     * 结束直播后调用
     */
    public static void destroySharedInstance() {
        NERTCLiveRoomImpl.destroySharedInstance();
    }

    /**
     * 初始化，每场直播只需调用一次
     *
     * @param context
     * @param appKey
     * @param option
     */
    public abstract void init(Context context, String appKey,
                              NERtcOption option);

    /**
     * 创建直播间（主播端调用）
     *
     * @param liveInfo       单主播直播间信息
     * @param profile        分辨率
     * @param frameRate      码率
     * @param mAudioScenario 音频
     * @param callBack
     * @param isFrontCam     是否前置摄像头
     */
    public abstract void createRoom(LiveInfo liveInfo,
                                    int profile, NERtcVideoConfig.NERtcVideoFrameRate frameRate,
                                    int mAudioScenario,
                                    boolean isFrontCam,
                                    LiveRoomCallBack callBack);

    /**
     * 邀请直播
     *
     * @param selfAccid         自己的im id
     * @param accountId         accid
     * @param pkLiveCid
     * @param cdnURL            推流地址
     * @param selfNickname      自己的昵称
     * @param pkRequestCallback
     */
    public abstract void requestPK(String selfAccid, String accountId, String pkLiveCid, String cdnURL, String selfNickname, LiveRoomCallBack pkRequestCallback);


    /**
     * 结束直播
     */
    public abstract void stopLive();

    /**
     * 设置远端的视频接受播放器
     *
     * @param videoRender
     * @param uid
     */
    public abstract void setupRemoteView(NERtcVideoView videoRender, long uid);


    /**
     * 接受PK
     *
     * @param pkLiveCid  pk直播间cid
     * @param accountId
     * @param requestId
     * @param accId
     * @param pkCallback
     */
    public abstract void acceptPk(String pkLiveCid, String accountId, String requestId, String accId, LiveRoomCallBack pkCallback);

    /**
     * 设置本端的视频接受播放器
     *
     * @param videoRender
     */
    public abstract void setupLocalView(NERtcVideoView videoRender);

    /**
     * 设置视频callback，用于美颜
     *
     * @param callback
     * @param needI420 是否需要同时返回YUVI420的数据（该操作会有一定耗时，只有在第三方滤镜库要求一定要yuv数据时才需要打开）
     */
    public abstract void setVideoCallback(NERtcVideoCallback callback, boolean needI420);

    /**
     * 拒绝pk邀请
     *
     * @param inviteParam
     * @param callBack
     */
    public abstract void rejectPkRequest(InviteParamBuilder inviteParam, LiveRoomCallBack callBack);

    /**
     * 加入rtc房间，在获取checkSum 之后调用
     *
     * @param checkSum
     * @param channelName
     * @param uid
     * @param roomCid     音视频房间标识
     */
    public abstract void joinRtcChannel(String checkSum, String channelName, long uid, String roomCid);

    /**
     * 获取当前的状态
     *
     * @return
     */
    public abstract LiveState getLiveCurrentState();

    /**
     * 开始预览
     */
    public abstract void startVideoPreview();

    /**
     * 停止预览
     */
    public abstract void stopVideoPreview();

    /**
     * 结束混音
     */
    public abstract void stopAudioMixing();

    /**
     * 设置混音发送音量
     *
     * @param progress
     */
    public abstract void setAudioMixingSendVolume(int progress);

    /**
     * 设置混音耳返音量
     *
     * @param progress
     */
    public abstract void setAudioMixingPlaybackVolume(int progress);

    /**
     * 设置伴音音量
     *
     * @param id
     * @param volume
     */
    public abstract void setEffectSendVolume(int id, int volume);

    /**
     * 设置伴音耳返音量
     *
     * @param id
     * @param volume
     */
    public abstract void setEffectPlaybackVolume(int id, int volume);

    /**
     * 切换摄像头
     */
    public abstract boolean switchCamera();

    /**
     * 是否打开摄像头
     *
     * @param enable
     * @return
     */
    public abstract boolean enableLocalVideo(boolean enable);

    /**
     * 是否打开麦克风
     *
     * @param isMute
     * @return
     */
    public abstract boolean muteLocalAudio(boolean isMute);

    /**
     * 打开关闭耳返
     *
     * @param enable
     * @param volume
     * @return
     */
    public abstract boolean enableEarback(boolean enable, int volume);

    /**
     * 取消邀请
     *
     * @param callback
     */
    public abstract void cancelPkRequest(RequestCallback<Void> callback, boolean byUser);

    /**
     * 停止伴音
     *
     * @param id
     * @return
     */
    public abstract int stopEffect(int id);

    /**
     * 开始伴音
     *
     * @param id
     * @param option
     * @return
     */
    public abstract int playEffect(int id, NERtcCreateAudioEffectOption option);

    /**
     * 开始混音
     *
     * @param option
     * @return
     */
    public abstract int startAudioMixing(NERtcCreateAudioMixingOption option);

    /**
     * 停止所有伴音
     */
    public abstract void stopAllEffects();
}
