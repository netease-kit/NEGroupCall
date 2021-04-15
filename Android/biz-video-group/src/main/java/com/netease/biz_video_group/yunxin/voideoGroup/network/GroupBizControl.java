package com.netease.biz_video_group.yunxin.voideoGroup.network;

import com.netease.biz_video_group.yunxin.voideoGroup.model.RoomInfo;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.android.lib.network.common.NetworkClient;
import com.netease.yunxin.nertc.demo.user.UserModel;
import com.netease.yunxin.nertc.demo.utils.TempLogUtil;

import java.util.HashMap;
import java.util.Map;

import io.reactivex.Single;
import io.reactivex.SingleTransformer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.schedulers.Schedulers;

public class GroupBizControl {
    /**
     * 请求加入房间
     *
     * @param mpRoomId
     * @param appKey
     * @return
     */
    public static Single<BaseResponse<RoomInfo>> joinRoom(String mpRoomId, String appKey, String nickName) {
        GroupServerApi serverApi = NetworkClient.getInstance().getService(GroupServerApi.class);
        Map<String, Object> map = new HashMap<>(2);
        map.put("mpRoomId", mpRoomId);
        map.put("appKey", appKey);
        map.put("nickName", nickName);
        map.put("clientType", 3);
        TempLogUtil.log("API-/mpVideoCall/room/join入参:"+map.toString());
        return serverApi.joinRoom(map).compose(scheduleThread())
                .map(roomInfoBaseResponse -> roomInfoBaseResponse);
    }

    /**
     * 获取指定uid 的用户信息
     *
     * @param avRoomUid
     * @return
     */
    public static Single<UserModel> getUserInfoByUid(String avRoomUid, String mpRoomId) {
        GroupServerApi serverApi = NetworkClient.getInstance().getService(GroupServerApi.class);
        Map<String, Object> map = new HashMap<>(2);
        map.put("avRoomUid", avRoomUid);
        map.put("mpRoomId", mpRoomId);
        return serverApi.requestUserInfoByUid(map).compose(scheduleThread())
                .map(userModelBaseResponse -> userModelBaseResponse.data);
    }

    /**
     * 提交评价
     *
     * @param feedback_type
     * @param tel
     * @param uid
     * @param content
     * @param appkey
     * @param appid
     * @return
     */
    public static Single<Boolean> submitComment(int feedback_type, String tel, String uid,
                                                String content, String appkey, String appid, String conetent_type, String feedback_source) {
        CommentServiceApi serverApi = NetworkClient.getInstance().getService(CommentServiceApi.class);
        Map<String, Object> map = new HashMap<>(2);
        map.put("feedback_type", feedback_type);
        map.put("contact", tel);
        map.put("uid", uid);
        map.put("content", content);
        map.put("appkey", appkey);
        map.put("appid", appid);
        map.put("type", 2);
        map.put("conetent_type", conetent_type);
        map.put("feedback_source", feedback_source);
        return serverApi.commentSubmit(map).map(BaseResponse::isSuccessful)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());
    }

    /***
     * 切换网络访问线程
     */
    private static <T> SingleTransformer<T, T> scheduleThread() {
        return upstream -> upstream.
                subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread());
    }
}
