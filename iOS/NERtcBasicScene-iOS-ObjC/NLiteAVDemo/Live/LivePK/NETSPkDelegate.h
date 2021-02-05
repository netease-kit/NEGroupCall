//
//  NETSPkDelegate.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/7.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NETSPkEnum.h"

NS_ASSUME_NONNULL_BEGIN

@class NIMSignalingCancelInviteNotifyInfo;

///
/// pk直播服务 代理
///
@protocol NETSPkServiceDelegate <NSObject>

/**
 pk直播服务类状态变更
 @param status  - 状态枚举
 */
- (void)didPkServiceChangedStatus:(NETSPkServiceStatus)status;

/**
 获取到pk结果后代理方法
 @param error               - 错误句柄
 @param isCurrentAnchorWin  - 当前主播是否有胜利
 */
- (void)didPkServiceFetchedPkRestltWithError:(NSError * _Nullable)error
                          isCurrentAnchorWin:(BOOL)isCurrentAnchorWin;

/**
 操作超时
 @param role    - 当前角色
 */
- (void)didPkServiceTimeoutForRole:(NETSPkServiceRole)role;

@end

///
/// pk直播 邀请者 代理协议
///
@protocol NETSPkInviterDelegate <NSObject>

/**
 邀请者 收到 被邀请者 发出的同步信息
 @param inviteeImAccId - 被邀请者im账号
 */
- (void)inviterReceivedPkStatusSyncFromInviteeImAccId:(NSString *)inviteeImAccId;

/**
 邀请者 收到 被邀请者 发出的拒绝邀请信息
 @param inviteeImAccId  - 被邀请者im账号
 @param rejectType      - pk邀请被拒类型
 */
- (void)inviterReceivedPkRejectFromInviteeImAccId:(NSString *)inviteeImAccId
                                       rejectType:(NETSPkRejectedType)rejectType;

/**
 邀请者 收到 被邀请者 发出的接受邀请信息
 @param inviteeImAccId - 被邀请者im账号
 */
- (void)inviterReceivedPkAcceptFromInviteeImAccId:(NSString *)inviteeImAccId;

@end

///
/// pk直播 被邀请者 代理协议
///
@protocol NETSPkInviteeDelegate <NSObject>

/**
 被邀请者 收到 邀请者 pk邀请 的信令消息
 @param inviterNickname     - 邀请者昵称
 @param inviterImAccId      - 邀请者账号
 @param pkLiveCid           - 邀请进入pk房间ID
 */
- (void)inviteeReceivedPkInviteByInviter:(NSString *)inviterNickname
                          inviterImAccId:(NSString *)inviterImAccId
                               pkLiveCid:(NSString *)pkLiveCid;

/**
 被邀请者 收到 邀请者 取消PK邀请 的信令消息
 @param response    - 信令消息
 */
- (void)inviteeReceivedCancelPkInviteResponse:(NIMSignalingCancelInviteNotifyInfo *)response;

@end

///
/// 透传消息处理了类
///
@protocol NETSPassThroughHandleDelegate <NSObject>

/**
 收到PassThrough开始PK的消息,双方开始推流
 @param data    - 透传数据
 */
- (void)receivePassThrourhPkStartData:(NETSPassThroughHandlePkStartData *)data;

/**
 收到PassThrough开始惩罚的消息
 @param data    - 透传数据
 */
- (void)receivePassThrourhPunishStartData:(NETSPassThroughHandlePunishData *)data;

/**
 收到PassThrough打赏通知
 @param data        - passthrough打赏数据
 @param rewardMsg   - 打赏IM消息
 */
- (void)receivePassThrourhRewardData:(NETSPassThroughHandleRewardData *)data
                           rewardMsg:(NIMMessage *)rewardMsg;

/**
 收到PassThrough打赏通知
 @param data    - 打赏数据
 */
- (void)receivePassThrourhPkEndData:(NETSPassThroughHandlePkEndData *)data;

/**
 收到PassThrough开始惩罚的消息
 @param data    - 透传数据
 */
- (void)receivePassThrourhLiveStartData:(NETSPassThroughHandleStartLiveData *)data;

@end

NS_ASSUME_NONNULL_END
