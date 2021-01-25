package com.netease.biz_live.yunxin.live.chatroom.custom;

import com.netease.nimlib.sdk.msg.attachment.MsgAttachment;
import com.netease.nimlib.sdk.msg.attachment.MsgAttachmentParser;

/**
 * Created by luc on 2020/11/18.
 * <p>
 * 直播自定义消息解析
 */
public class LiveAttachParser implements MsgAttachmentParser {

    @Override
    public MsgAttachment parse(String json) {
        MsgAttachment result = null;

        switch (JsonUtils.getType(json)) {
            case CustomAttachmentType.CHAT_ROOM_PK: {
                result = JsonUtils.toMsgAttachment(json, PKStatusAttachment.class);
                break;
            }
            case CustomAttachmentType.CHAT_ROOM_PUNISHMENT: {
                result = JsonUtils.toMsgAttachment(json, PunishmentStatusAttachment.class);
                break;
            }
            case CustomAttachmentType.CHAT_ROOM_ANCHOR_COIN_CHANGED: {
                result = JsonUtils.toMsgAttachment(json, AnchorCoinChangedAttachment.class);
                break;
            }
            case CustomAttachmentType.CHAT_ROOM_TEXT:{
                result = JsonUtils.toMsgAttachment(json,TextWithRoleAttachment.class);
                break;
            }
            default: {
            }
        }
        return result;
    }
}
