//
//  NETSPkService+Invitee.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/6.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSPkService.h"

NS_ASSUME_NONNULL_BEGIN

@class NIMSignalingInviteNotifyInfo;
@class NIMSignalingCancelInviteNotifyInfo;

/**
 PK直播服务 分类 被邀请者
 */

@interface NETSPkService (Invitee)

/// 邀请者 通信信道
@property (nonatomic, copy, nullable)   NSString  *inviterChannelId;
/// 邀请者 IM帐号ID
@property (nonatomic, copy, nullable)   NSString  *inviterImAccId;
/// 邀请者 请求ID
@property (nonatomic, copy, nullable)   NSString  *inviterRequestId;
/// pk直播间 cid
@property (nonatomic, copy, nullable)   NSString  *pkLiveCid;

/**
 被邀请者 加入pk直播间(离开单人直播间成功后调用此方法)
 @param successBlock    - 加入pk直播间成功闭包
 @param failedBlock     - 加入pk直播间失败闭包
 */
- (void)_inviteeJoinPkWithSuccessBlock:(void(^)(int64_t, uint64_t, uint64_t))successBlock
                          failedBlock:(void(^)(NSError *))failedBlock;

#pragma mark - 发送IM信令消息部分操作

/**
 被邀请者 发起接受PK邀请信令
 @param pkLiveCid       - pk直播间ID
 @param successBlock    - 信令发起成功闭包
 @param failedBlock     - 信令发起失败闭包
 */
- (void)inviteeSendAcceptPkWithLiveCid:(NSString *)pkLiveCid
                          successBlock:(void(^)(void))successBlock
                           failedBlock:(void(^)(NSError *))failedBlock;

/**
 被邀请者 发起拒绝PK邀请信令
 @param successBlock    - 信令发起成功闭包
 @param failedBlock     - 信令发起失败闭包
 */
- (void)inviteeSendRejectPkWithSuccessBlock:(void(^)(void))successBlock
                                failedBlock:(void(^)(NSError *))failedBlock;

/**
 被邀请者 接受PK邀,加入RTC房间成功后,发出自定义消息同步状态
 @param successBlock    - 信令发起成功闭包
 @param failedBlock     - 信令发起失败闭包
 */
- (void)_inviteeSendSyncPkSignalWithSuccessBlock:(void(^)(void))successBlock
                                    failedBlock:(void(^)(NSError *))failedBlock;

#pragma mark - 收到IM信令消息部分操作

/**
 被邀请者收到邀请的信令消息
 @param response    - 信令消息
 */
- (void)_inviteeReceivedInviterResponse:(NIMSignalingInviteNotifyInfo *)response;

/**
 被邀请者收到邀请者取消邀请的信令消息
 @param response    - 信令消息
 */
- (void)_inviteeReceivedCancelPkInviteResponse:(NIMSignalingCancelInviteNotifyInfo *)response;

@end

NS_ASSUME_NONNULL_END
