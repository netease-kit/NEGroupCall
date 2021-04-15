package com.netease.biz_live.yunxin.live.chatroom.control;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import com.netease.biz_live.yunxin.live.chatroom.ChatRoomMsgCreator;
import com.netease.biz_live.yunxin.live.chatroom.custom.AnchorCoinChangedAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.LiveAttachParser;
import com.netease.biz_live.yunxin.live.chatroom.custom.PKStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PunishmentStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.TextWithRoleAttachment;
import com.netease.biz_live.yunxin.live.chatroom.model.AudienceInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.LiveChatRoomInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.RewardGiftInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.RoomMsg;
import com.netease.biz_live.yunxin.live.gift.GiftCache;
import com.netease.biz_live.yunxin.live.gift.GiftInfo;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.chatroom.ChatRoomMessageBuilder;
import com.netease.nimlib.sdk.chatroom.ChatRoomService;
import com.netease.nimlib.sdk.chatroom.ChatRoomServiceObserver;
import com.netease.nimlib.sdk.chatroom.constant.MemberQueryType;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomInfo;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomKickOutEvent;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomMember;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomMessage;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomNotificationAttachment;
import com.netease.nimlib.sdk.chatroom.model.EnterChatRoomData;
import com.netease.nimlib.sdk.chatroom.model.EnterChatRoomResultData;
import com.netease.nimlib.sdk.msg.MsgService;
import com.netease.nimlib.sdk.msg.attachment.MsgAttachment;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;
import com.netease.yunxin.android.lib.historian.Historian;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserModel;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import androidx.annotation.NonNull;

/**
 * Created by luc on 2020/R11/18.
 * <p>
 * 聊天室消息控制
 */
final class ChatRoomControl {
    /**
     * 扩展账号信息
     */
    private static final String EXTENSION_KEY_ACCOUNT_ID = "accountId";
    /**
     * 加入聊天室失败的重试次数
     */
    private static final int JOIN_ROOM_RETRY_COUNT = 1;

    /**
     * 延时时间 3s
     */
    private static final long HANDLER_DELAY_TIME = 3000;

    /**
     * handler 消息通知类型，主播离开
     */
    private static final int MSG_TYPE_ANCHOR_LEAVE = 1;

    private static final Handler DELAY_HANDLER = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(@NonNull Message msg) {
            super.handleMessage(msg);
            if (msg.what != MSG_TYPE_ANCHOR_LEAVE) {
                return;
            }
            ChatRoomControl.getInstance().isAnchorOnline = false;
            ChatRoomControl.getInstance().chatRoomNotify.onAnchorLeave();
        }
    };

    /**
     * 聊天室服务（IM SDK）
     */
    private final ChatRoomService chatRoomService = NIMClient.getService(ChatRoomService.class);
    /**
     * 用户服务
     */
    private final UserCenterService userCenterService = ModuleServiceMgr.getInstance().getService(UserCenterService.class);
    /**
     * 已注册的聊天室消息回调
     */
    private final List<ChatRoomNotify> notifyList = new ArrayList<>(4);

    /**
     * 注册的全局聊天室消息回调
     */
    private final ChatRoomNotify chatRoomNotify = new ChatRoomNotify() {

        @Override
        public void onJoinRoom(boolean success, int code) {
            notifyAllRegisteredInfo(notify -> notify.onJoinRoom(success, code));
        }

        @Override
        public void onRoomDestroyed(LiveChatRoomInfo roomInfo) {
            notifyAllRegisteredInfo(notify -> notify.onRoomDestroyed(roomInfo));
        }

        @Override
        public void onAnchorLeave() {
            notifyAllRegisteredInfo(ChatRoomNotify::onAnchorLeave);
        }

        @Override
        public void onKickedOut() {
            notifyAllRegisteredInfo(ChatRoomNotify::onKickedOut);
        }

        @Override
        public void onMsgArrived(RoomMsg msg) {
            notifyAllRegisteredInfo(notify -> notify.onMsgArrived(msg));
        }

        @Override
        public void onGiftArrived(RewardGiftInfo giftInfo) {
            notifyAllRegisteredInfo(notify -> notify.onGiftArrived(giftInfo));
        }

        @Override
        public void onUserCountChanged(int count) {
            notifyAllRegisteredInfo(notify -> notify.onUserCountChanged(count));
        }

        @Override
        public void onAnchorCoinChanged(AnchorCoinChangedAttachment attachment) {
            notifyAllRegisteredInfo(notify -> notify.onAnchorCoinChanged(attachment));
        }

        @Override
        public void onPKStatusChanged(PKStatusAttachment pkStatus) {
            notifyAllRegisteredInfo(notify -> notify.onPKStatusChanged(pkStatus));
        }

        @Override
        public void onPunishmentStatusChanged(PunishmentStatusAttachment punishmentStatus) {
            notifyAllRegisteredInfo(notify -> notify.onPunishmentStatusChanged(punishmentStatus));
        }
    };


    /**
     * 聊天室服务回调监听（IM SDK）
     */
    private final Observer<List<ChatRoomMessage>> chatRoomMsgObserver = new Observer<List<ChatRoomMessage>>() {
        @Override
        public void onEvent(List<ChatRoomMessage> chatRoomMessages) {
            if (chatRoomMessages == null || chatRoomMessages.isEmpty()) {
                return;
            }
            if (roomInfo == null) {
                return;
            }

            final String roomId = roomInfo.roomId;

            for (ChatRoomMessage message : chatRoomMessages) {
                // 只接收此聊天室的相应消息
                if ((message.getSessionType() != SessionTypeEnum.ChatRoom) ||
                        !roomId.equals(message.getSessionId())) {
                    continue;
                }
                // 聊天室通知消息处理（用户进入/离开，关闭）
                MsgAttachment attachment = message.getAttachment();
                if (attachment instanceof ChatRoomNotificationAttachment) {
                    onNotification((ChatRoomNotificationAttachment) attachment);
                    return;
                }
                // pk状态处理
                if (attachment instanceof PKStatusAttachment) {
                    onPKState((PKStatusAttachment) attachment);
                    return;
                }
                // 惩罚状态处理
                if (attachment instanceof PunishmentStatusAttachment) {
                    onPunishmentState((PunishmentStatusAttachment) attachment);
                    return;
                }
                // 主播云币变化通知处理
                if (attachment instanceof AnchorCoinChangedAttachment) {
                    onAnchorCoinChanged((AnchorCoinChangedAttachment) attachment);
                    return;
                }
                // 聊天室文本消息处理
                if (attachment instanceof TextWithRoleAttachment) {
                    onTextMsg(message.getChatRoomMessageExtension().getSenderNick(), (TextWithRoleAttachment) attachment);
                    return;
                }
            }
        }
    };

    /**
     * 监听聊天室解散
     */
    private final Observer<ChatRoomKickOutEvent> chatRoomKickOutEventObserver = new Observer<ChatRoomKickOutEvent>() {
        @Override
        public void onEvent(ChatRoomKickOutEvent chatRoomKickOutEvent) {
            if (chatRoomKickOutEvent == null) {
                return;
            }
            if (roomInfo == null) {
                return;
            }
            if (!roomInfo.roomId.equals(chatRoomKickOutEvent.getRoomId())) {
                return;
            }

            if (chatRoomKickOutEvent.getReason().getValue() == MemberKickedReasonType.KICK_OUT_BY_CONFLICT_LOGIN) {
                chatRoomNotify.onKickedOut();
            } else {
                chatRoomNotify.onAnchorLeave();
            }
        }
    };

    /**
     * 聊天室基本信息
     */
    private LiveChatRoomInfo roomInfo;

    /**
     * 主播 im 登录id
     */
    private String anchorImAccId;

    /**
     * 是否主播在线
     */
    private boolean isAnchorOnline = false;

    /**
     * 当前实例是否release
     */
    private boolean isReleased = true;


    //------------------- 单例
    private ChatRoomControl() {
    }

    private static final class Holder {
        private static final ChatRoomControl INSTANCE = new ChatRoomControl();
    }

    static ChatRoomControl getInstance() {
        return Holder.INSTANCE;
    }
    //--------------------/ 单例


    /**
     * 加入聊天室
     *
     * @param roomInfo 聊天室房间信息
     */
    public void joinRoom(LiveChatRoomInfo roomInfo) {
        Historian.e("====>", "joinRoom");
        DELAY_HANDLER.removeMessages(MSG_TYPE_ANCHOR_LEAVE);
        // 加入新房间，信息重置
        if (this.roomInfo != null) {
            chatRoomService.exitChatRoom(this.roomInfo.roomId);
        }
        resetAllStates();
        this.roomInfo = roomInfo;
        // 注册自定义消息类型解析器
        NIMClient.getService(MsgService.class).registerCustomAttachmentParser(new LiveAttachParser());
        // 注册聊天室消息接收
        listen(true);

        // 采用非独立模式进入聊天室，聊天室昵称和用户昵称一致
        UserModel user = getCurrentUser();
        EnterChatRoomData chatRoomData = new EnterChatRoomData(roomInfo.roomId);
        chatRoomData.setNick(user.getNickname());
        chatRoomData.setAvatar(user.avatar);

        Map<String, Object> extension = new HashMap<>();
        extension.put(EXTENSION_KEY_ACCOUNT_ID, user.accountId);
        chatRoomData.setExtension(extension);
        // 调用聊天室服务，进入聊天室重试次数为 JOIN_ROOM_RETRY_COUNT
        //noinspection unchecked
        chatRoomService.enterChatRoomEx(chatRoomData, JOIN_ROOM_RETRY_COUNT)
                .setCallback(new RequestCallback<EnterChatRoomResultData>() {
                    @Override
                    public void onSuccess(EnterChatRoomResultData param) {
                        if (isReleased) {
                            return;
                        }
                        chatRoomNotify.onJoinRoom(true, 0);
                        queryRoomInfoAndNotify();
                    }

                    @Override
                    public void onFailed(int code) {
                        chatRoomNotify.onJoinRoom(false, code);
                    }

                    @Override
                    public void onException(Throwable exception) {
                        chatRoomNotify.onJoinRoom(false, -1);
                    }
                });
        isReleased = false;
    }

    /**
     * 更新聊天室用户数
     */
    private void queryRoomInfoAndNotify() {
        chatRoomService.fetchRoomInfo(roomInfo.roomId).setCallback(new RequestCallback<ChatRoomInfo>() {
            @Override
            public void onSuccess(ChatRoomInfo param) {
                if (isReleased) {
                    return;
                }
                if (roomInfo == null || param == null) {
                    return;
                }
                // 获取主播 登录 imAccId
                anchorImAccId = param.getCreator();
                roomInfo.setOnlineUserCount(param.getOnlineUserCount());
                // 查询主播在线情况
                queryAnchorOnlineStatusAndNotify(anchorImAccId);
            }

            @Override
            public void onFailed(int code) {
            }

            @Override
            public void onException(Throwable exception) {
            }
        });
    }

    /**
     * 查询主播在线情况
     *
     * @param anchorImAccId 主播登录 im id
     */
    private void queryAnchorOnlineStatusAndNotify(String anchorImAccId) {
        if (isAnchor(String.valueOf(getCurrentUser().imAccid))) {
            isAnchorOnline = true;
        }
        chatRoomService.fetchRoomMembersByIds(roomInfo.roomId, Collections.singletonList(anchorImAccId))
                .setCallback(new RequestCallback<List<ChatRoomMember>>() {
                    @Override
                    public void onSuccess(List<ChatRoomMember> param) {
                        if (isReleased) {
                            return;
                        }
                        // 主播不在线通知主播离开
                        isAnchorOnline = !param.isEmpty() && param.get(0).isOnline();
                        if (!isAnchorOnline) {
                            chatRoomNotify.onAnchorLeave();
                        }
                        notifyUserCountChanged();
                    }

                    @Override
                    public void onFailed(int code) {
                        isAnchorOnline = false;
                        chatRoomNotify.onAnchorLeave();
                    }

                    @Override
                    public void onException(Throwable exception) {
                        isAnchorOnline = false;
                        chatRoomNotify.onAnchorLeave();
                    }
                });
    }

    /**
     * 离开聊天室
     */
    public void leaveRoom() {
        Historian.e("====>", "leaveRoom");
        isReleased = true;
        if (roomInfo != null) {
            chatRoomService.exitChatRoom(roomInfo.roomId);
        }
        resetAllStates();
    }

    /**
     * 发送文本信息
     *
     * @param isAnchor 是否为主播
     * @param msg      文本
     */
    public void sendTextMsg(boolean isAnchor, String msg) {
        TextWithRoleAttachment attachment = new TextWithRoleAttachment(isAnchor, msg);
        sendCustomMsg(attachment);
    }

    /**
     * 发送自定义消息
     *
     * @param attachment 自定义消息内容
     */
    public void sendCustomMsg(MsgAttachment attachment) {
        if (roomInfo == null) {
            return;
        }
        chatRoomService.sendMessage(
                ChatRoomMessageBuilder.createChatRoomCustomMessage(roomInfo.roomId, attachment), false);

        // pk状态处理
        if (attachment instanceof PKStatusAttachment) {
            onPKState((PKStatusAttachment) attachment);
            return;
        }
        // 惩罚状态处理
        if (attachment instanceof PunishmentStatusAttachment) {
            onPunishmentState((PunishmentStatusAttachment) attachment);
            return;
        }
        // 主播云币变化通知处理
        if (attachment instanceof AnchorCoinChangedAttachment) {
            onAnchorCoinChanged((AnchorCoinChangedAttachment) attachment);
            return;
        }
        // 聊天室文本消息处理
        if (attachment instanceof TextWithRoleAttachment) {
            onTextMsg(getCurrentUser().nickname, (TextWithRoleAttachment) attachment);
        }
    }

    /**
     * 聊天室消息回调注册
     *
     * @param notify   聊天室消息回调
     * @param register true 注册，false 反注册
     */
    public void registerNotify(ChatRoomNotify notify, boolean register) {
        if (register && !notifyList.contains(notify)) {
            notifyList.add(notify);
        } else if (!register) {
            notifyList.remove(notify);
        }
    }

    /**
     * 查询聊天室成员列表
     *
     * @param size            查询数量
     * @param requestCallback 结果回调
     */
    public void queryRoomTempMembers(int size, RequestCallback<List<AudienceInfo>> requestCallback) {
        Objects.requireNonNull(requestCallback);

        chatRoomService.fetchRoomMembers(roomInfo.roomId, MemberQueryType.GUEST, 0, size)
                .setCallback(new RequestCallback<List<ChatRoomMember>>() {
                    @Override
                    public void onSuccess(List<ChatRoomMember> param) {
                        if (isReleased) {
                            return;
                        }
                        if (param == null || param.isEmpty()) {
                            requestCallback.onSuccess(Collections.emptyList());
                            return;
                        }
                        List<AudienceInfo> result = new ArrayList<>(param.size());
                        convertToAudienceInfo(param, new RoomMemberToAudience() {
                            @Override
                            public void onItemConverted(AudienceInfo audienceInfo) {
                                result.add(audienceInfo);
                            }

                            @Override
                            public void onFinished() {
                                requestCallback.onSuccess(result);
                            }
                        });
                    }

                    @Override
                    public void onFailed(int code) {
                        requestCallback.onFailed(code);
                    }

                    @Override
                    public void onException(Throwable exception) {
                        requestCallback.onException(exception);
                    }
                });
    }

    /**
     * 注册/反注册 聊天室（IM SDK）
     *
     * @param register true 注册，false 反注册
     */
    private void listen(boolean register) {
        NIMClient.getService(ChatRoomServiceObserver.class).observeReceiveMessage(chatRoomMsgObserver, register);
        NIMClient.getService(ChatRoomServiceObserver.class).observeKickOutEvent(chatRoomKickOutEventObserver, register);
    }

    /**
     * 获取当前登录用户信息
     */
    private UserModel getCurrentUser() {
        return userCenterService.getCurrentUser();
    }

    /**
     * 重置清空所有状态
     */
    private void resetAllStates() {
        this.roomInfo = null;
        this.notifyList.clear();
        this.isAnchorOnline = false;
        this.anchorImAccId = null;
        listen(false);
        DELAY_HANDLER.removeMessages(MSG_TYPE_ANCHOR_LEAVE);
    }

    /**
     * 接收聊天室中 notification 类型消息
     */
    private void onNotification(ChatRoomNotificationAttachment notification) {
        Historian.e("======>", "notification is " + notification + ", type is " + notification.getType());
        switch (notification.getType()) {
            // 用户进入聊天室
            case ChatRoomMemberIn: {
                notifyUserIO(true, notification.getTargetNicks(), notification.getTargets());
                break;
            }
            //  用户离开聊天室
            case ChatRoomMemberExit: {
                notifyUserIO(false, notification.getTargetNicks(), notification.getTargets());
                break;
            }
            // 聊天室关闭
            case ChatRoomClose: {
                chatRoomNotify.onRoomDestroyed(roomInfo);
                break;
            }
            default: {
            }
        }
    }

    /**
     * 通知用户进出聊天室情况
     *
     * @param enter        true 进入，false 离开
     * @param nicknameList 影响用户昵称列表
     */
    private void notifyUserIO(boolean enter, List<String> nicknameList, List<String> imAccIdList) {

        if (nicknameList == null
                || nicknameList.isEmpty()
                || imAccIdList == null
                || imAccIdList.isEmpty()
                || nicknameList.size() != imAccIdList.size()) {
            return;
        }

        for (int i = 0; i < imAccIdList.size(); i++) {
            String imAccId = imAccIdList.get(i);
            String nickname = nicknameList.get(i);
            if (enter) {
                if (isNotUserSelf(imAccId)) {
                    roomInfo.increaseCount();
                }
                if (isAnchor(imAccId)) {
                    DELAY_HANDLER.removeMessages(MSG_TYPE_ANCHOR_LEAVE);
                } else {
                    chatRoomNotify.onMsgArrived(new RoomMsg(RoomMsg.MsgType.USER_IN, ChatRoomMsgCreator.createRoomEnter(nickname)));
                }
            } else {
                if (isNotUserSelf(imAccId)) {
                    roomInfo.decreaseCount();
                }
                if (isAnchor(imAccId)) {
                    DELAY_HANDLER.sendEmptyMessageDelayed(MSG_TYPE_ANCHOR_LEAVE, HANDLER_DELAY_TIME);
                } else {
                    chatRoomNotify.onMsgArrived(new RoomMsg(RoomMsg.MsgType.USER_OUT, ChatRoomMsgCreator.createRoomExit(nickname)));
                }
            }
            notifyUserCountChanged();
        }
    }

    private void notifyUserCountChanged() {
        // 去除主播
        int extraCount = isAnchorOnline ? 1 : 0;
        int userCount = roomInfo.getOnlineUserCount() - extraCount;
        chatRoomNotify.onUserCountChanged(userCount);
    }

    /**
     * 接收聊天室内文本消息
     */
    private void onTextMsg(String nickname, TextWithRoleAttachment attachment) {
        String content = attachment.msg;
        boolean isAnchor = attachment.isAnchor;
        chatRoomNotify.onMsgArrived(new RoomMsg(RoomMsg.MsgType.TEXT, ChatRoomMsgCreator.createText(isAnchor, nickname, content)));
    }

    /**
     * 接收聊天室 PK 状态消息
     */
    private void onPKState(PKStatusAttachment attachment) {
        chatRoomNotify.onPKStatusChanged(attachment);
    }

    /**
     * 接收聊天室 惩罚 状态消息
     */
    private void onPunishmentState(PunishmentStatusAttachment attachment) {
        chatRoomNotify.onPunishmentStatusChanged(attachment);
    }

    /**
     * 接收聊天室打赏消息
     */
    private void onGiftReward(int giftId, String nickname) {
        GiftInfo info = GiftCache.getGift(giftId);
        if (info == null) {
            return;
        }
        chatRoomNotify.onMsgArrived(new RoomMsg(RoomMsg.MsgType.GIFT, ChatRoomMsgCreator.createGiftReward(nickname, 1, info.staticIconResId)));
        chatRoomNotify.onGiftArrived(new RewardGiftInfo(roomInfo.roomId, getCurrentUser().accountId, nickname, roomInfo.creator, giftId));
    }

    /**
     * 接收聊天室主播云币变化时
     */
    private void onAnchorCoinChanged(AnchorCoinChangedAttachment attachment) {
        chatRoomNotify.onAnchorCoinChanged(attachment);
        if (roomInfo == null || roomInfo.fromUserAvRoomId == null) {
            return;
        }

        if (roomInfo.fromUserAvRoomId.equals(attachment.toAnchorId)) {
            onGiftReward((int) attachment.giftId, attachment.nickname);
        }
    }

    /**
     * 通知所有已经注册接口
     */
    private void notifyAllRegisteredInfo(NotifyHelper helper) {
        for (ChatRoomNotify notify : notifyList) {
            helper.onNotifyAction(notify);
        }
    }

    /**
     * 聊天室成员转换成观众信息
     *
     * @param members 聊天室成员列表
     * @param convert 转换结果通知
     */
    private void convertToAudienceInfo(List<ChatRoomMember> members, RoomMemberToAudience convert) {
        for (ChatRoomMember member : members) {
            Map<String, Object> extension = member.getExtension();
            if (extension == null) {
                extension = new HashMap<>(0);
            }
            String accountId = String.valueOf(extension.get(EXTENSION_KEY_ACCOUNT_ID));
            AudienceInfo info = new AudienceInfo(accountId, Long.parseLong(member.getAccount()), member.getNick(), member.getAvatar());
            convert.onItemConverted(info);
        }
        convert.onFinished();
    }

    /**
     * 对应用户是否为主播
     */
    private boolean isAnchor(String imAccId) {
        return imAccId != null && imAccId.equals(anchorImAccId);
    }

    /**
     * 判断此用户是否为当前用户
     *
     * @param imAccId 用户im 登录账号id
     */
    private boolean isNotUserSelf(String imAccId) {
        return !String.valueOf(getCurrentUser().imAccid).equals(imAccId);
    }

    /**
     * 通知帮助接口
     */
    private interface NotifyHelper {
        void onNotifyAction(ChatRoomNotify notify);
    }

    /**
     * 聊天室成员转换至观众信息
     */
    private interface RoomMemberToAudience {
        /**
         * 成员转换结果
         *
         * @param audienceInfo 观众信息
         */
        void onItemConverted(AudienceInfo audienceInfo);

        /**
         * 转换完成
         */
        void onFinished();
    }
}
