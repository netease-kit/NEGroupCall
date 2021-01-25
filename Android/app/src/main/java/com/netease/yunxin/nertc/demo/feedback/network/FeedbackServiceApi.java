package com.netease.yunxin.nertc.demo.feedback.network;


import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.android.lib.network.common.BaseUrl;

import java.util.Map;

import io.reactivex.Single;
import retrofit2.http.Body;
import retrofit2.http.POST;

/**
 * Created by luc on 2020/11/16.
 */
@BaseUrl("https://statistic.live.126.net/")
public interface FeedbackServiceApi {
    /**
     * 反馈上报
     *
     * @param body 反馈参数
     */
    @POST("/statics/report/feedback/demoSuggest")
    Single<BaseResponse<Void>> demoSuggest(@Body Map<String, Object> body);
}
