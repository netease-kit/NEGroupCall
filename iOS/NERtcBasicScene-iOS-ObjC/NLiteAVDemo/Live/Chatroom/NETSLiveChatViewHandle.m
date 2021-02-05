//
//  NETSLiveChatViewHandle.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveChatViewHandle.h"
#import "NSMacro.h"
#import "NETSLiveAttachment.h"

@interface NETSLiveChatViewHandle ()

/// 代理对象
@property (nonatomic, weak) id<NETSLiveChatViewHandleDelegate> delegate;

@end

@implementation NETSLiveChatViewHandle

- (instancetype)initWithDelegate:(id<NETSLiveChatViewHandleDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void)dealWithCustomNotification:(NIMCustomSystemNotification *)notification
{
    
}

- (void)dealWithNotificationMessage:(NIMMessage *)message
{
    NIMNotificationObject *object = (NIMNotificationObject *)message.messageObject;
    switch (object.notificationType) {
        case NIMNotificationTypeChatroom:{
            NIMChatroomNotificationContent *content = (NIMChatroomNotificationContent *)object.content;
            if (content.eventType == NIMChatroomEventTypeEnter) { //进入聊天室
                NIMChatroomNotificationMember *member = content.source;
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomMember:enter:sessionId:)]) {
                    [_delegate didChatroomMember:member enter:YES sessionId:message.session.sessionId];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatroomUserEnter object:member];
            }
            else if (content.eventType == NIMChatroomEventTypeExit) { //离开聊天室
                NIMChatroomNotificationMember *member = content.source;
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomMember:enter:sessionId:)]) {
                    [_delegate didChatroomMember:member enter:NO sessionId:message.session.sessionId];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatroomUserLeave object:member];
            }
            else if (content.eventType == NIMChatroomEventTypeClosed) { //聊天室被关闭
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomClosedWithRoomId:)]) {
                    [_delegate didChatroomClosedWithRoomId:message.session.sessionId];
                }
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - NIMSystemNotificationManagerDelegate

- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification
{
    [self dealWithCustomNotification:notification];
}

#pragma mark - NIMChatManagerDelegate

- (void)willSendMessage:(NIMMessage *)message
{
    switch (message.messageType) {
        case NIMMessageTypeCustom:
        {
            NIMCustomObject *object = message.messageObject;
            if ([object.attachment isKindOfClass:[NETSLivePKAttachment class]] && _delegate && [_delegate respondsToSelector:@selector(didReceivedPKMessage:)]) {
                [_delegate didReceivedPKMessage:message];
            }
            else if ([object.attachment isKindOfClass:[NETSLivePunishAttachment class]] && _delegate && [_delegate respondsToSelector:@selector(didReceivedPunishMessage:)]) {
                [_delegate didReceivedPunishMessage:message];
            }
            else if ([object.attachment isKindOfClass:[NETSLiveTextAttachment class]] && _delegate && [_delegate respondsToSelector:@selector(didReceivedTextMessage:)]) {
                [_delegate didReceivedTextMessage:message];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)onRecvMessages:(NSArray *)messages
{
    for (NIMMessage *message in messages) {
        if (![message.session.sessionId isEqualToString:_roomId]
            && message.session.sessionType == NIMSessionTypeChatroom) {
            //不属于这个聊天室的消息
            return;
        }
        switch (message.messageType) {
            case NIMMessageTypeCustom:
            {
                NIMCustomObject *object = message.messageObject;
                if ([object.attachment isKindOfClass:[NETSLivePKAttachment class]] && _delegate && [_delegate respondsToSelector:@selector(didReceivedPKMessage:)]) {
                    [_delegate didReceivedPKMessage:message];
                }
                else if ([object.attachment isKindOfClass:[NETSLivePunishAttachment class]] && _delegate && [_delegate respondsToSelector:@selector(didReceivedPunishMessage:)]) {
                    [_delegate didReceivedPunishMessage:message];
                }
                else if ([object.attachment isKindOfClass:[NETSLiveWealthChangeAttachment class]] && _delegate && [_delegate respondsToSelector:@selector(didReceivedSyncWealthMessage:)]) {
                    [_delegate didReceivedSyncWealthMessage:message];
                }
                else if ([object.attachment isKindOfClass:[NETSLiveTextAttachment class]] && _delegate && [_delegate respondsToSelector:@selector(didReceivedTextMessage:)]) {
                    [_delegate didReceivedTextMessage:message];
                }
                break;
            }
            case NIMMessageTypeNotification:{
                [self dealWithNotificationMessage:message];
            }
                break;
            default:
                break;
        }
    }
}

/// 识别
- (BOOL)_isGiftMessage:(NIMMessage *)message
{
    int32_t type = [message.remoteExt[@"type"] intValue];
    return type == 13;
}

- (void)chatroomBeKicked:(NIMChatroomBeKickedResult *)result
{
    if (result.reason == NIMChatroomKickReasonInvalidRoom) {
        if (_delegate && [_delegate respondsToSelector:@selector(didChatroomClosedWithRoomId:)]) {
            [_delegate didChatroomClosedWithRoomId:result.roomId];
        }
    }
}

@end
