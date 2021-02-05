//
//  NETSPkService+Inviter.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/6.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSPkService.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSCreateLiveRoomModel, NIMSignalingChannelDetailedInfo, NIMSignalingNotifyInfo, NIMSignalingCallRequest;

/**
 PK直播服务 分类 邀请者
 */

@interface NETSPkService (Inviter)

/// 邀请者 邀请请求
@property (nonatomic, strong, nullable) NIMSignalingCallRequest         *inviteRequest;
/// 邀请者 邀请请求返回信息
@property (nonatomic, strong, nullable) NIMSignalingChannelDetailedInfo *invitePkResponseInfo;
/// 邀请者 昵称
@property (nonatomic, copy, nullable)   NSString    *inviterNickname;


/**
 邀请者 加入pk直播间(离开单人直播间成功后调用此方法)
 @param successBlock    - 加入pk直播间成功闭包
 @param failedBlock     - 加入pk直播间失败闭包
 */
- (void)_inviterJoinPkWithSuccessBlock:(void(^)(int64_t, uint64_t, uint64_t))successBlock
                           failedBlock:(void(^)(NSError *))failedBlock;

#pragma mark - 发送IM信令消息部分操作

/**
 邀请者 发出pk邀请
 @param inviteeRoom     - 被邀请PK的直播间
 @param successBlock    - 信令发起成功闭包
 @param failedBlock     - 信令发起失败闭包
 */
- (void)inviterSendPkInviteWithInviteeRoom:(NETSLiveRoomModel *)inviteeRoom
                              successBlock:(void(^)(NETSCreateLiveRoomModel *, NIMSignalingChannelDetailedInfo *))successBlock
                               failedBlock:(void(^)(NSError * _Nullable))failedBlock;

/**
 邀请者 取消PK邀请
 @param successBlock    - 信令发起成功闭包
 @param failedBlock     - 信令发起失败闭包
 */
- (void)inviterSendCancelPkWithSuccessBlock:(void(^)(void))successBlock
                                failedBlock:(void(^)(NSError *))failedBlock;

#pragma mark - 收到IM信令消息部分操作

/**
 邀请者 收到 被邀请的PK同步信令消息(子类被邀请者无需实现该方法)
 @param response    - 信令消息
 */
- (void)_inviterReceivedPkSyncWithInviteeResponse:(NIMSignalingNotifyInfo *)response;

/**
 邀请者 收到 被邀请的拒绝pk邀请信令消息(子类被邀请者无需实现该方法)
 @param response    - 信令消息
 */
- (void)_inviterReceivedPkRejectWithInviteeResponse:(NIMSignalingNotifyInfo *)response;

/**
 邀请者 收到 被邀请的接受pk邀请信令消息(子类被邀请者无需实现该方法)
 @param response    - 信令消息
 */
- (void)_inviterReceivedPkAcceptWithInviteeResponse:(NIMSignalingNotifyInfo *)response;

@end

NS_ASSUME_NONNULL_END
