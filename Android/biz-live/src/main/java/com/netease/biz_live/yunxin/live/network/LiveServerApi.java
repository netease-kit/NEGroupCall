package com.netease.biz_live.yunxin.live.network;

import com.netease.biz_live.yunxin.live.model.JoinInfo;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.biz_live.yunxin.live.model.response.AnchorQueryInfo;
import com.netease.biz_live.yunxin.live.model.response.LiveListResponse;
import com.netease.biz_live.yunxin.live.model.response.PkLiveContributeTotal;
import com.netease.yunxin.android.lib.network.common.BaseResponse;

import java.util.Map;

import io.reactivex.Single;
import retrofit2.http.Body;
import retrofit2.http.POST;

/**
 * 直播网络访问
 */
public interface LiveServerApi {
    /**
     * 直播频道不存在
     */
    int ERROR_CODE_ROOM_NOT_EXIST = 655;

    /**
     * 用户不在直播房间内
     */
    int ERROR_CODE_USER_NOT_IN_ROOM = 2101;

    /**
     * 获取直播间列表
     */
    @POST("/v1/pkLive/getLiveRoomList")
    Single<BaseResponse<LiveListResponse>> getLiveRoomList(@Body Map<String, Object> body);

    /**
     * 打赏主播礼物
     *
     * @param body accountId - 打赏用户 id
     *             anchorAccountId -  被打赏主播 id
     *             giftId -  礼物 id
     *             liveCid - 直播间房间号
     *             liveType - 是否pk，1 - pk； 0 - 非pk
     */
    @POST("/v1/pkLive/reward")
    Single<BaseResponse<Void>> rewardAnchor(@Body Map<String, Object> body);

    /**
     * 获取直播间详情
     *
     * @param body accountId - 当前账号id
     *             liveCid - 直播房间 id
     */
    @POST("/v1/pkLive/liveRoom/info")
    Single<BaseResponse<AnchorQueryInfo>> queryAnchorRoomInfo(@Body Map<String, Object> body);

    /**
     * 直播pk 时段打赏主播贡献排行榜查询
     *
     * @param body anchorAccountId - 主播账号id
     *             liveCid - 直播房间id
     *             liveType - 直播类型
     * @return 排行榜详情
     */
    @POST("/v1/pkLive/getPkLiveContriList")
    Single<BaseResponse<PkLiveContributeTotal>> queryPkContributeTotal(@Body Map<String, Object> body);

    /**
     * 主播创建直播间，开始直播
     *
     * @param body
     * @return
     */
    @POST("/v1/pkLive/liveRoomCreate")
    Single<BaseResponse<LiveInfo>> createLiveRoom(@Body Map<String, Object> body);

    /**
     * 加入RTC房间之前预占位，并返回checksum
     *
     * @param body
     * @return
     */
    @POST("/v1/pkLive/join")
    Single<BaseResponse<JoinInfo>> joinLiveRoom(@Body Map<String, Object> body);

    /**
     * 主播结束PK
     *
     * @param body
     * @return
     */
    @POST("/v1/pkLive/pkLiveRoomClose")
    Single<BaseResponse<Boolean>> stopPK(@Body Map<String, Object> body);

    /**
     * 主播结束直播
     *
     * @param body
     * @return
     */
    @POST("/v1/pkLive/liveRoomClose")
    Single<BaseResponse<Boolean>> stopLive(@Body Map<String, Object> body);


    /**
     * 获取房间主题
     *
     * @param body
     * @return
     */
    @POST("/v1/pkLive/liveRoom/getRandomRoomTopic")
    Single<BaseResponse<String>> getTopic(@Body Map<String, Object> body);

    /**
     * 获取房间封面
     *
     * @param body
     * @return
     */
    @POST("/v1/pkLive/liveRoom/getRandomLivePic")
    Single<BaseResponse<String>> getCover(@Body Map<String, Object> body);
}
