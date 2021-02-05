//
//  NETSLiveChatViewHandle.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 聊天视图代理类
///

@protocol NETSLiveChatViewHandleDelegate <NSObject>

@optional

///
/// 聊天室进出
/// @param member   - 成员信息
/// @param enter    - 进入/离开
/// @param sessionId    - 会话ID
///
- (void)didChatroomMember:(NIMChatroomNotificationMember *)member
                    enter:(BOOL)enter
                sessionId:(NSString *)sessionId;

///
/// 聊天室关闭
/// @param roomId   - 会话ID
///
- (void)didChatroomClosedWithRoomId:(NSString *)roomId;

/**
 聊天室收到PK消息
 @param message     - PK消息
 */
- (void)didReceivedPKMessage:(NIMMessage *)message;

/**
 聊天室收到惩罚消息
 @param message     - 惩罚消息
 */
- (void)didReceivedPunishMessage:(NIMMessage *)message;

/**
 聊天室收到主播发出的云币同步消息
 @param message     - 云币变化消息
 */
- (void)didReceivedSyncWealthMessage:(NIMMessage *)message;

/**
 聊天室收到文本消息
 @param message    - 文本消息
 */
- (void)didReceivedTextMessage:(NIMMessage *)message;

@end

@interface NETSLiveChatViewHandle : NSObject <NIMSystemNotificationManagerDelegate, NIMChatManagerDelegate, NIMChatroomManagerDelegate>

/// 聊天室ID
@property (nonatomic, copy) NSString *roomId;

///
/// 实例化聊天室代理类
/// @param delegate - 代理
///
- (instancetype)initWithDelegate:(id<NETSLiveChatViewHandleDelegate>)delegate;

///
/// 处理自定义通知
/// @param notification - 通知
///
- (void)dealWithCustomNotification:(NIMCustomSystemNotification *)notification;

///
/// 处理通知消息
/// @param message      - 消息
///
- (void)dealWithNotificationMessage:(NIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
