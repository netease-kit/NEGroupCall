package com.netease.biz_live.yunxin.live.network;

import android.text.TextUtils;

import com.netease.biz_live.yunxin.live.chatroom.model.RewardGiftInfo;
import com.netease.biz_live.yunxin.live.constant.LiveType;
import com.netease.biz_live.yunxin.live.model.JoinInfo;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.biz_live.yunxin.live.model.response.AnchorQueryInfo;
import com.netease.biz_live.yunxin.live.model.response.LiveListResponse;
import com.netease.biz_live.yunxin.live.model.response.PkLiveContributeTotal;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.android.lib.network.common.NetworkClient;
import com.netease.yunxin.android.lib.network.common.transform.ErrorTransform;

import java.util.HashMap;
import java.util.Map;

import io.reactivex.Single;

/**
 * 直播网络访问交互
 */
public class LiveInteraction {


    /**
     * 获取直播间列表
     *
     * @param type
     * @param pageNum
     * @param pageSize
     * @return
     */
    public static Single<BaseResponse<LiveListResponse>> getLiveList(int type, int pageNum, int pageSize) {
        LiveServerApi serverApi = NetworkClient.getInstance().getService(LiveServerApi.class);
        Map<String, Object> map = new HashMap<>(2);
        map.put("live", type);
        map.put("pageNum", pageNum);
        map.put("pageSize", pageSize);
        return serverApi.getLiveRoomList(map).compose(new ErrorTransform<>())
                .map(liveInfoBaseResponse -> liveInfoBaseResponse);
    }

    /**
     * 打赏主播
     *
     * @param isPk           当前是否 pk
     * @param rewardGiftInfo 打赏信息
     */
    public static Single<Boolean> rewardAnchor(boolean isPk, RewardGiftInfo rewardGiftInfo) {
        LiveServerApi api = NetworkClient.getInstance().getService(LiveServerApi.class);
        Map<String, Object> map = new HashMap<>(5);
        map.put("liveCid", rewardGiftInfo.liveCid);
        map.put("liveType", isPk ? LiveType.PK_LIVING : LiveType.NORMAL_LIVING);
        map.put("accountId", rewardGiftInfo.rewardAccountId);
        map.put("anchorAccountId", rewardGiftInfo.anchorId);
        map.put("giftId", rewardGiftInfo.giftId);
        return api.rewardAnchor(map)
                .compose(new ErrorTransform<>())
                .map(BaseResponse::isSuccessful);
    }

    /**
     * 查询直播房间详情
     *
     * @param accountId 用户id
     * @param liveCid   待查询房间 id
     * @return 结果详情
     */
    public static Single<BaseResponse<AnchorQueryInfo>> queryAnchorRoomInfo(String accountId, String liveCid) {
        LiveServerApi api = NetworkClient.getInstance().getService(LiveServerApi.class);
        Map<String, Object> map = new HashMap<>(2);
        map.put("liveCid", liveCid);
        map.put("accountId", accountId);
        return api.queryAnchorRoomInfo(map)
                .compose(new ErrorTransform<>());
    }

    /**
     * 查询直播间贡献排行
     *
     * @param anchorAccountId 主播 accountId
     * @param liveCid         直播间 id
     * @param liveType        直播类型 是否PK 2：直播：3：PK直播 {@link com.netease.biz_live.yunxin.live.constant.LiveType}
     * @return 贡献详情
     */
    public static Single<PkLiveContributeTotal> queryPkLiveContributeTotal(String anchorAccountId, String liveCid, int liveType) {
        LiveServerApi api = NetworkClient.getInstance().getService(LiveServerApi.class);
        Map<String, Object> map = new HashMap<>(3);
        map.put("liveCid", liveCid);
        map.put("anchorAccountId", anchorAccountId);
        map.put("liveType", liveType);
        return api.queryPkContributeTotal(map)
                .compose(new ErrorTransform<>())
                .map(response -> {
                    PkLiveContributeTotal result = response.data;
                    if (result == null) {
                        result = new PkLiveContributeTotal();
                    }
                    result.accountId = anchorAccountId;
                    return result;
                });
    }

    /**
     * 创建直播间
     *
     * @param accountId     用户id
     * @param roomTopic     直播间主题
     * @param parentLiveCid 之前的cid，pk房间的时候需要
     * @param liveCoverPic  封面
     * @param type          3，pk 2，单主播
     * @return
     */
    public static Single<BaseResponse<LiveInfo>> createLiveRoom(String accountId, String roomTopic, String parentLiveCid, String liveCoverPic, int type) {
        LiveServerApi api = NetworkClient.getInstance().getService(LiveServerApi.class);
        Map<String, Object> params = new HashMap<>(3);
        params.put("accountId", accountId);
        params.put("roomTopic", roomTopic);
        params.put("liveType", type);
        params.put("liveCoverPic", liveCoverPic);
        if (!TextUtils.isEmpty(parentLiveCid)) {
            params.put("parentLiveCid", parentLiveCid);
        }
        return api.createLiveRoom(params).compose(new ErrorTransform<>())
                .map(liveInfoBaseResponse -> liveInfoBaseResponse);
    }

    /**
     * 加入房间，join rtc channel之前调用，获得checkSum，channelName，UID
     *
     * @param liveCid       直播cid
     * @param parentLiveCid 之前的cid，pk直播需要
     * @param liveType      isPk ? 3 : 2
     * @return
     */
    public static Single<BaseResponse<JoinInfo>> joinLiveRoom(String liveCid, String parentLiveCid, int liveType) {
        LiveServerApi api = NetworkClient.getInstance().getService(LiveServerApi.class);
        Map<String, Object> params = new HashMap<>(2);
        params.put("liveCid", liveCid);
        params.put("liveType", liveType);
        if (!TextUtils.isEmpty(parentLiveCid)) {
            params.put("parentLiveCid", parentLiveCid);
        }
        return api.joinLiveRoom(params).compose(new ErrorTransform<>())
                .map(joinInfoResponse -> joinInfoResponse);
    }

    /**
     * 结束PK
     *
     * @param liveCid
     * @return
     */
    public static Single<BaseResponse<Boolean>> stopPk(String liveCid) {
        LiveServerApi api = NetworkClient.getInstance().getService(LiveServerApi.class);
        Map<String, Object> params = new HashMap<>(1);
        params.put("liveCid", liveCid);
        return api.stopPK(params).compose(new ErrorTransform<>())
                .map(booleanBaseResponse -> booleanBaseResponse);
    }

    /**
     * 获取随机主题
     *
     * @return
     */
    public static Single<BaseResponse<String>> getTopic() {
        LiveServerApi api = NetworkClient.getInstance().getService(LiveServerApi.class);
        Map<String, Object> params = new HashMap<>(1);
        return api.getTopic(params).compose(new ErrorTransform<>())
                .map(stringBaseResponse -> stringBaseResponse);
    }

    /**
     * 获取随机封面
     *
     * @return
     */
    public static Single<BaseResponse<String>> getCover() {
        LiveServerApi api = NetworkClient.getInstance().getService(LiveServerApi.class);
        Map<String, Object> params = new HashMap<>(1);
        return api.getCover(params).compose(new ErrorTransform<>())
                .map(stringBaseResponse -> stringBaseResponse);
    }

    /**
     * 结束直播
     *
     * @param liveCid
     * @return
     */
    public static Single<BaseResponse<Boolean>> stopLive(String liveCid) {
        LiveServerApi api = NetworkClient.getInstance().getService(LiveServerApi.class);
        Map<String, Object> params = new HashMap<>(1);
        params.put("liveCid", liveCid);
        return api.stopLive(params)
                .compose(new ErrorTransform<>())
                .map(booleanBaseResponse -> booleanBaseResponse);
    }

}
