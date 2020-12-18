package com.netease.biz_video_group.yunxin.voideoGroup.network;

import com.netease.yunxin.nertc.demo.network.BaseResponse;
import com.netease.yunxin.nertc.demo.network.BaseUrl;

import java.util.Map;

import io.reactivex.Single;
import retrofit2.http.Body;
import retrofit2.http.POST;

@BaseUrl("https://statistic.live.126.net/")
public interface CommentServiceApi {
    /**
     * 请求创建房间，加入房间
     */
    @POST("/statics/report/feedback/demoSuggest")
    Single<BaseResponse<Void>> commentSubmit(@Body Map<String, Object> body);
}
