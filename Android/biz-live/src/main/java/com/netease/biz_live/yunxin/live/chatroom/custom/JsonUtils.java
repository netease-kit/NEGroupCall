package com.netease.biz_live.yunxin.live.chatroom.custom;

import com.google.gson.Gson;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by luc on 2020/11/18.
 */
final class JsonUtils {
    /**
     * 获取当前结构体类型
     *
     * @param json 结构体
     * @return 类型信息
     */
    @CustomAttachmentType
    static int getType(String json) {
        int type = CustomAttachmentType.UNKNOWN;
        try {
            JSONObject object = new JSONObject(json);
            type = object.optInt(BaseCustomAttachment.KEY_JSON_TYPE, CustomAttachmentType.UNKNOWN);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return type;
    }

    static <T extends BaseCustomAttachment> T toMsgAttachment(String json, Class<T> clazz) {
        return new Gson().fromJson(json, clazz);
    }
}
