//
//  NETSPkService+Invitee.m
//  NLiteAVDemo
//
//  Created by Think on 2021/1/6.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSPkService+Invitee.h"
#import <NIMSDK/NIMSDK.h>
#import "NETSLiveApi.h"
#import <NERtcSDK/NERtcSDK.h>
#import "NETSPushStreamService.h"
#import "SKVObject.h"
#import "NENavigator.h"
#import <objc/runtime.h>
#import "NETSToast.h"

static const void *InviterChannelIdKey = &InviterChannelIdKey;
static const void *InviterImAccIdKey = &InviterImAccIdKey;
static const void *InviterRequestIdKey = &InviterRequestIdKey;
static const void *PkLiveCidKey = &PkLiveCidKey;

@implementation NETSPkService (Invitee)

@dynamic inviterChannelId, inviterImAccId, inviterRequestId, pkLiveCid;

#pragma mark - setter / getter

- (NSString *)inviterChannelId
{
    return objc_getAssociatedObject(self, InviterChannelIdKey);
}

- (void)setInviterChannelId:(NSString *)inviterChannelId
{
    objc_setAssociatedObject(self, InviterChannelIdKey, inviterChannelId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)inviterImAccId
{
    return objc_getAssociatedObject(self, InviterImAccIdKey);
}

- (void)setInviterImAccId:(NSString *)inviterImAccId
{
    objc_setAssociatedObject(self, InviterImAccIdKey, inviterImAccId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)inviterRequestId
{
    return objc_getAssociatedObject(self, InviterRequestIdKey);
}

- (void)setInviterRequestId:(NSString *)inviterRequestId
{
    objc_setAssociatedObject(self, InviterRequestIdKey, inviterRequestId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)pkLiveCid
{
    return objc_getAssociatedObject(self, PkLiveCidKey);
}

- (void)setPkLiveCid:(NSString *)pkLiveCid
{
    objc_setAssociatedObject(self, PkLiveCidKey, pkLiveCid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 发送IM信令消息部分操作

- (void)inviteeSendAcceptPkWithLiveCid:(NSString *)pkLiveCid
                          successBlock:(void(^)(void))successBlock
                           failedBlock:(void(^)(NSError *))failedBlock
{
    if (isEmptyString(self.inviterChannelId) || isEmptyString(self.inviterImAccId) || isEmptyString(self.inviterRequestId)) {
        NSError *error = [NSError errorWithDomain:@"NETSInterfaceErrorParamDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: @"被邀请 方发送接受pk信令失败"}];
        if (failedBlock) { failedBlock(error); }
        return;
    }
    
    
    void(^sendAcceptBlock)(void) = ^(void){
        NIMSignalingAcceptRequest *request = [[NIMSignalingAcceptRequest alloc] init];
        request.channelId = self.inviterChannelId;
        request.accountId = self.inviterImAccId;
        request.requestId = self.inviterRequestId;
        request.autoJoin = YES;
        [[[NIMSDK sharedSDK] signalManager] signalingAccept:request completion:^(NSError * _Nullable error, NIMSignalingChannelDetailedInfo * _Nullable response) {
            if (error) {
                if (failedBlock) { failedBlock(error); }
            } else {
                self.pkLiveCid = pkLiveCid;
                self.liveStatus = NETSPkServicePkLive;
                self.liveRole = NETSPkServiceInvitee;
                
                if (successBlock) { successBlock(); }
            }
        }];
    };
    
    if (isEmptyString(self.streamTask.taskID)) {
        sendAcceptBlock();
    } else {
        [NETSPushStreamService removeStreamTask:self.streamTask.taskID successBlock:^{
            NETSLog(@"被邀请者 准备发送接收pk信令, 移除推流 taskId: %@ success", self.streamTask.taskID);
            sendAcceptBlock();
        } failedBlock:^(NSError * _Nonnull error) {
            NETSLog(@"被邀请者 准备发送接收pk信令, 移除推流失败 taskId: %@ error: %@", self.streamTask.taskID, error);
            if (failedBlock) { failedBlock(error); }
        }];
    }
}

- (void)inviteeSendRejectPkWithSuccessBlock:(void(^)(void))successBlock
                                failedBlock:(void(^)(NSError *))failedBlock
{
    // 拒绝pk邀请,关闭计时器
    [self.timer invalidate];
    
    self.liveStatus = NETSPkServiceSingleLive;
    self.liveRole = NETSPkServiceDefault;
    
    NSString *inviterImAccId = self.inviterImAccId;
    NSString *inviterRequestId = self.inviterRequestId;
    NSString *inviterChannelId = self.inviterChannelId;
    
    [self _sendRejectPkWithInviterImAccId:inviterImAccId inviterRequestId:inviterRequestId inviterChannelId:inviterChannelId rejectType:NETSPkRejectedArtificial successBlock:successBlock failedBlock:failedBlock];
}

- (void)_inviteeSendSyncPkSignalWithSuccessBlock:(void(^)(void))successBlock
                                    failedBlock:(void(^)(NSError *))failedBlock
{
    if (isEmptyString(self.inviterChannelId) || isEmptyString(self.inviterImAccId) || isEmptyString(self.inviterRequestId)) {
        NSError *error = [NSError errorWithDomain:@"NETSInterfaceErrorParamDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: @"被邀请 方发送pk同步信令失败"}];
        if (failedBlock) { failedBlock(error); }
        return;
    }
    
    NIMSignalingControlRequest *control = [[NIMSignalingControlRequest alloc] init];
    control.channelId = self.inviterChannelId;
    control.accountId = self.inviterImAccId;
    NSDictionary *param = @{@"cid": @(1)};
    control.customInfo = [param yy_modelToJSONString];;
    
    [NIMSDK.sharedSDK.signalManager signalingControl:control completion:^(NSError * _Nullable error) {
        if (error) {
            if (failedBlock) { failedBlock(error); }
        } else {
            if (successBlock) { successBlock(); }
        }
    }];
}

- (void)_inviteeJoinPkWithSuccessBlock:(void(^)(int64_t, uint64_t, uint64_t))successBlock
                           failedBlock:(void(^)(NSError *))failedBlock
{
    // 校验参数
    NSString *parentLiveCid = self.singleRoom.liveCid;
    if (isEmptyString(self.pkLiveCid) || isEmptyString(parentLiveCid)) {
        NSError *error = [NSError errorWithDomain:@"NETSRtcErrorParamDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: @"被邀请者 尝试加入pk直播间失败, 参数有误"}];
        if (failedBlock) { failedBlock(error); }
        return;
    }
    
    __weak __typeof(self) wSelf = self;
    [self _tryToJoinPkRoomWithLiveCid:self.pkLiveCid parentLiveCid:parentLiveCid successBlock:^(int64_t uid, uint64_t channelId, uint64_t elapesd) {
        __strong __typeof(wSelf) sSelf = wSelf;
        // 被邀请者 向 邀请方 发送同步信令信号
        [sSelf _inviteeSendSyncPkSignalWithSuccessBlock:^{
            NETSLog(@"被邀请者发送pk同步信号成功");
            if (successBlock) {
                successBlock(uid, channelId, elapesd);
            }
        } failedBlock:^(NSError * _Nonnull error) {
            NETSLog(@"被邀请者发送pk同步信号成功失败, error: %@", error);
        }];
    } failedBlock:failedBlock];
}

#pragma mark - 收到IM信令消息部分操作

- (void)_inviteeReceivedInviterResponse:(NIMSignalingInviteNotifyInfo *)response
{
    SKVObject *obj = [NETSPushStreamService parseCutomInfoForResponse:response];
    if (!obj) {
        return;
    }
    
    NSDictionary *info = [obj dictionaryValue];
    NSString *inviterNickname = info[@"inviterNickname"];
    NSString *pkLiveCid = info[@"pkLiveCid"];
    if (isEmptyString(inviterNickname) || isEmptyString(pkLiveCid) || isEmptyString(response.fromAccountId)) {
        NETSLog(@"收到PK邀请自定义字段缺失");
        return;
    }
    
    if (self.liveStatus == NETSPkServicePkInviting || self.liveStatus == NETSPkServicePkLive) {
        // 正在pk邀请链接中,拒绝其他pk邀请
        NSString *inviterImAccId = response.fromAccountId;
        NSString *inviterRequestId = response.requestId;
        NSString *inviterChannelId = response.channelInfo.channelId;
        
        [self _sendRejectPkWithInviterImAccId:inviterImAccId inviterRequestId:inviterRequestId inviterChannelId:inviterChannelId rejectType:NETSPkRejectedForBusyInvitee successBlock:^{
            NETSLog(@"当前主播正在pk邀请中,拒绝新的pk邀请成功...");
        } failedBlock:^(NSError *error) {
            NETSLog(@"当前主播正在pk邀请中,拒绝新的pk邀请失败, error: %@", error);
        }];
        return;
    }
    
    self.liveStatus = NETSPkServicePkInviting;
    self.liveRole = NETSPkServiceInvitee;
    
    self.inviterImAccId = response.fromAccountId;
    self.inviterRequestId = response.requestId;
    self.inviterChannelId = response.channelInfo.channelId;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inviteeReceivedPkInviteByInviter:inviterImAccId:pkLiveCid:)]) {
        [self.delegate inviteeReceivedPkInviteByInviter:inviterNickname inviterImAccId:response.fromAccountId pkLiveCid:pkLiveCid];
    } else {
        NETSLog(@"被邀请者 未实现收到pk邀请的代理方法");
    }
    
    // 超时计时器: 启动
    if (self.timer) { [self.timer invalidate]; }
    __weak __typeof(self) wSelf = self;
    self.timer = [NETSGCDTimer scheduledTimerWithTimeInterval:kPkServiceTimeoutMax repeats:NO queue:self.timerQueue triggerImmediately:NO block:^{
        __strong __typeof(self) sSelf = wSelf;
        // 超时发送拒绝pk信令
        [sSelf inviteeSendRejectPkWithSuccessBlock:^{
            NETSLog(@"被邀请者 pk邀请超时,发送拒绝pk邀请信令成功");
        } failedBlock:^(NSError * _Nonnull error) {
            NETSLog(@"被邀请者 pk邀请超时,发送拒绝pk邀请信令失败, error: %@", error);
        }];
        
        if (sSelf.delegate && [sSelf.delegate respondsToSelector:@selector(didPkServiceTimeoutForRole:)]) {
            [sSelf.delegate didPkServiceTimeoutForRole:NETSPkServiceInvitee];
        }
    }];
}

- (void)_inviteeReceivedCancelPkInviteResponse:(NIMSignalingCancelInviteNotifyInfo *)response
{
    self.liveStatus = NETSPkServiceSingleLive;
    self.liveRole = NETSPkServiceDefault;
    
    // 超时计时器: 停止
    [self.timer invalidate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inviteeReceivedCancelPkInviteResponse:)]) {
        [self.delegate inviteeReceivedCancelPkInviteResponse:response];
    } else {
        NETSLog(@"被邀请者 未实现收到 邀请方取消pk邀请的代理方法");
    }
}

#pragma mark - private methods

/// 发送拒绝pk邀请信令
- (void)_sendRejectPkWithInviterImAccId:(NSString *)inviterImAccId
                       inviterRequestId:(NSString *)inviterRequestId
                       inviterChannelId:(NSString *)inviterChannelId
                             rejectType:(NETSPkRejectedType)rejectType
                           successBlock:(void(^)(void))successBlock
                            failedBlock:(void(^)(NSError *))failedBlock
{
    if (isEmptyString(inviterImAccId) || isEmptyString(inviterRequestId) || isEmptyString(inviterChannelId)) {
        NSError *error = [NSError errorWithDomain:@"NETSRtcErrorParamDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: @"邀请方参数不完整,拒绝pk邀请失败"}];
        if (failedBlock) { failedBlock(error); }
        return;
    }
    
    NIMSignalingRejectRequest *rejectRequest = [[NIMSignalingRejectRequest alloc] init];
    rejectRequest.channelId = inviterChannelId;
    rejectRequest.accountId = inviterImAccId;
    rejectRequest.requestId = inviterRequestId;
    if (rejectType == NETSPkRejectedForBusyInvitee) {
        rejectRequest.customInfo = kInviteeBusyRejectPk;
    }
    [[[NIMSDK sharedSDK] signalManager] signalingReject:rejectRequest completion:^(NSError * _Nullable error) {
        if (error) {
            if (failedBlock) { failedBlock(error); }
        } else {
            if (successBlock) { successBlock(); }
        }
    }];
}

@end
