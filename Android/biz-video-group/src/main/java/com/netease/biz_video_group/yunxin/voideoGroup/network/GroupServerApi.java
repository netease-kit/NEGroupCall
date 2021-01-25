package com.netease.biz_video_group.yunxin.voideoGroup.network;

import com.netease.biz_video_group.yunxin.voideoGroup.model.RoomInfo;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.nertc.demo.user.UserModel;

import java.util.Map;

import io.reactivex.Single;
import retrofit2.http.Body;
import retrofit2.http.POST;

public interface GroupServerApi {
    /**
     * 请求创建房间，加入房间
     */
    @POST("/mpVideoCall/room/join")
    Single<BaseResponse<RoomInfo>> joinRoom(@Body Map<String, Object> body);

    /**
     * 根据Uid 获取用户信息
     */
    @POST("/mpVideoCall/room/member/info")
    Single<BaseResponse<UserModel>> requestUserInfoByUid(@Body Map<String, Object> body);


}
