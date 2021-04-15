//
//  NETSPkService+Inviter.m
//  NLiteAVDemo
//
//  Created by Think on 2021/1/6.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSPkService+Inviter.h"
#import "NETSLiveApi.h"
#import "NETSPushStreamService.h"
#import "SKVObject.h"
#import <NIMSDK/NIMSDK.h>
#import <NERtcSDK/NERtcSDK.h>

static const void *InviteRequestKey = &InviteRequestKey;
static const void *InvitePkResponseInfoKey = &InvitePkResponseInfoKey;
static const void *InviterNicknameKey = &InviterNicknameKey;

@implementation NETSPkService (Inviter)

@dynamic inviteRequest, invitePkResponseInfo, inviterNickname;

#pragma mark - setter / getter

- (NIMSignalingCallRequest *)inviteRequest
{
    return objc_getAssociatedObject(self, InviteRequestKey);
}

- (void)setInviteRequest:(NIMSignalingCallRequest *)inviteRequest
{
    objc_setAssociatedObject(self, InviteRequestKey, inviteRequest, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NIMSignalingChannelDetailedInfo *)invitePkResponseInfo
{
    return objc_getAssociatedObject(self, InvitePkResponseInfoKey);
}

- (void)setInvitePkResponseInfo:(NIMSignalingChannelDetailedInfo *)invitePkResponseInfo
{
    objc_setAssociatedObject(self, InvitePkResponseInfoKey, invitePkResponseInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)inviterNickname
{
    return objc_getAssociatedObject(self, InviterNicknameKey);
}

- (void)setInviterNickname:(NSString *)inviterNickname
{
    objc_setAssociatedObject(self, InviterNicknameKey, inviterNickname, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - public method

- (void)_inviterJoinPkWithSuccessBlock:(void(^)(int64_t, uint64_t, uint64_t))successBlock
                           failedBlock:(void(^)(NSError *))failedBlock
{
    NSString *liveCid = self.singleRoom.liveCid;
    if (isEmptyString(liveCid)) {
        NSError *error = [NSError errorWithDomain:@"NETSInterfaceErrorParamDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: @"无PK房间信息"}];
        if (failedBlock) { failedBlock(error); }
        return;
    }
    
    [self _tryToJoinPkRoomWithLiveCid:liveCid parentLiveCid:liveCid successBlock:successBlock failedBlock:failedBlock];
}


#pragma mark - 发送IM信令消息部分操作

- (void)inviterSendPkInviteWithInviteeRoom:(NETSLiveRoomModel *)inviteeRoom
                              successBlock:(void(^)(NETSCreateLiveRoomModel *, NIMSignalingChannelDetailedInfo *))successBlock
                               failedBlock:(void(^)(NSError *))failedBlock
{
    self.liveStatus = NETSPkServicePkInviting;
    self.liveRole = NETSPkServiceInviter;
    
    __weak __typeof(self) wSelf = self;
    
    void(^failedBlockWapper)(NSError * _Nonnull) = ^(NSError * _Nonnull err) {
        __strong __typeof(self) sSelf = wSelf;
        sSelf.liveStatus = NETSPkServiceSingleLive;
        sSelf.liveRole = NETSPkServiceDefault;
        
        if (failedBlock) { failedBlock(err); }
    };
    
    [self _buildPkRoomWithInviterRoom:self.singleRoom successBlock:^(NETSCreateLiveRoomModel *pkRoom) {
        __strong __typeof(self) sSelf = wSelf;
        [sSelf _sendPkSignalWithInviteeImAccId:inviteeRoom.imAccid inviterNickname:self.singleRoom.nickname pkRoom:pkRoom successBlock:successBlock failedBlock:^(NSError * error) {
            NETSLog(@"邀请方 发送pk邀请信令失败, error: %@", error);
            failedBlockWapper(error);
        }];
    } failedBlock:failedBlockWapper];
}

/// 创建PK直播间
- (void)_buildPkRoomWithInviterRoom:(NETSCreateLiveRoomModel *)inviterRoom
                       successBlock:(void(^)(NETSCreateLiveRoomModel *))successBlock
                        failedBlock:(void(^)(NSError *))failedBlock
{
    [NETSLiveApi createLiveRoomWithTopic:inviterRoom.roomTopic coverUrl:inviterRoom.liveCoverPic type:NETSLiveTypePK parentLiveCid:inviterRoom.liveCid completionHandle:^(NSDictionary * _Nonnull response) {
        NETSCreateLiveRoomModel *pkRoom = response[@"/data"];
        if (!pkRoom) {
            NSError *error = [NSError errorWithDomain:NETSRequestErrorParseDomain code:NETSRequestErrorMapping userInfo:@{NSLocalizedDescriptionKey: @"创建PK直播间失败"}];
            if (failedBlock) { failedBlock(error); }
        } else {
            if (successBlock) { successBlock(pkRoom); }
        }
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        NETSLog(@"创建PK直播间失败, error: %@", error);
        if (error) {
            if (failedBlock) { failedBlock(error); }
        }
    }];
}

/// 发送PK邀请信令
- (void)_sendPkSignalWithInviteeImAccId:(NSString *)inviteeImAccId
                 inviterNickname:(NSString *)inviterNickname
                          pkRoom:(NETSCreateLiveRoomModel *)pkRoom
                    successBlock:(void(^)(NETSCreateLiveRoomModel *, NIMSignalingChannelDetailedInfo *))successBlock
                     failedBlock:(void(^)(NSError *))failedBlock
{
    NIMSignalingCallRequest *request = [[NIMSignalingCallRequest alloc] init];
    request.requestId = [NSString stringWithFormat:@"%.0f%d", [[NSDate date] timeIntervalSince1970] * 1000, arc4random() % 1000];
    request.accountId = inviteeImAccId;
    request.channelType = NIMSignalingChannelTypeCustom;
    NSDictionary *param = @{@"inviterNickname": inviterNickname, @"pkLiveCid": pkRoom.liveCid};
    request.customInfo = [param yy_modelToJSONString];
    
    [[NIMSDK sharedSDK].signalManager signalingCall:request completion:^(NSError * _Nullable error, NIMSignalingChannelDetailedInfo * _Nullable response) {
        if (error) {
            NETSLog(@"邀请方 发送pk邀请信令失败, error: %@", error);
            self.inviteRequest = nil;
            self.inviterNickname = nil;
            self.pkRoom = nil;
            if (failedBlock) { failedBlock(error); }
            
            return;
        }
        
        self.invitePkResponseInfo = response;
        self.inviteRequest = request;
        self.inviterNickname = inviterNickname;
        self.pkRoom = pkRoom;
        if (successBlock) { successBlock(pkRoom, response); }
        
        // pk邀请者,启动计时器
        if (self.timer) { [self.timer invalidate]; }
        __weak __typeof(self) wSelf = self;
        self.timer = [NETSGCDTimer scheduledTimerWithTimeInterval:kPkServiceTimeoutMax repeats:NO queue:self.timerQueue triggerImmediately:NO block:^{
            __strong __typeof(self) sSelf = wSelf;
            // 发送取消pk邀请信令
            [sSelf inviterSendCancelPkWithSuccessBlock:^{
                NETSLog(@"邀请方 发送pk邀请信令超时,发送取消pk邀请信令成功");
            } failedBlock:^(NSError * _Nonnull error) {
                NETSLog(@"邀请方 发送pk邀请信令超时,发送取消pk邀请信令失败, error: %@", error);
            }];
            
            // 执行超时代理
            if (sSelf.delegate && [sSelf.delegate respondsToSelector:@selector(didPkServiceTimeoutForRole:)]) {
                [sSelf.delegate didPkServiceTimeoutForRole:NETSPkServiceInviter];
            }
        }];
    }];
}

- (void)inviterSendCancelPkWithSuccessBlock:(void(^)(void))successBlock
                                failedBlock:(void(^)(NSError * _Nullable))failedBlock
{
    // 超时计时器: 停止
    [self.timer invalidate];
    
    if (!self.inviteRequest) {
        NSError *error = [NSError errorWithDomain:@"NETSInterfaceErrorParamDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: @"无PK邀请请求"}];
        if (failedBlock) { failedBlock(error); }
        return;
    }
    
    NIMSignalingCancelInviteRequest *request = [[NIMSignalingCancelInviteRequest alloc] init];
    request.channelId = self.invitePkResponseInfo.channelId;
    request.accountId = self.inviteRequest.accountId;
    request.requestId = self.inviteRequest.requestId;
    [[[NIMSDK sharedSDK] signalManager] signalingCancelInvite:request completion:^(NSError * _Nullable error) {
        if (error) {
            if (failedBlock) { failedBlock(error); }
        } else {
            self.liveRole = NETSPkServiceDefault;
            self.liveStatus = NETSPkServiceSingleLive;
            if (successBlock) { successBlock(); }
        }
        self.invitePkResponseInfo = nil;
    }];
}

#pragma mark - 收到IM信令消息部分操作

- (void)_inviterReceivedPkSyncWithInviteeResponse:(NIMSignalingNotifyInfo *)response
{
    // 校验自定义参数
    SKVObject *obj = [NETSPushStreamService parseCutomInfoForResponse:response];
    if (!obj) {
        return;
    }
    
    NSDictionary *info = [obj dictionaryValue];
    NSInteger cid = [info[@"cid"] integerValue];
    if (cid != 1) {
        NETSLog(@"非法CID信息,不是邀请方PK同步信令");
        return;
    }
    
    void(^runDelegateBlock)(void) = ^(void){
        // 离开当前房间
        int res = [[NERtcEngine sharedEngine] leaveChannel];
        if (res != 0) {
            NETSLog(@"发起pk用户,离开当前直播间失败");
        } else {
            NETSLog(@"发起pk用户,离开当前直播间成功");
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(inviterReceivedPkStatusSyncFromInviteeImAccId:)]) {
                [self.delegate inviterReceivedPkStatusSyncFromInviteeImAccId:response.fromAccountId];
            }
        }
    };
    
    if (isEmptyString(self.streamTask.taskID)) {
        runDelegateBlock();
    } else {
        [NETSPushStreamService removeStreamTask:self.streamTask.taskID successBlock:^{
            NETSLog(@"邀请者 收到被邀请者同步信息, 移除推流 taskId: %@, success", self.streamTask.taskID);
            runDelegateBlock();
        } failedBlock:^(NSError * _Nonnull error) {
            NETSLog(@"邀请者 收到被邀请者同步信息, 移除推流 taskId: %@, error: %@", self.streamTask.taskID, error);
        }];
    }
}

- (void)_inviterReceivedPkRejectWithInviteeResponse:(NIMSignalingRejectNotifyInfo *)response
{
    // 校验requestId
    if (![response.requestId isEqualToString:self.inviteRequest.requestId]) {
        NETSLog(@"非法PK邀请请求");
        return;
    }
    
    self.liveStatus = NETSPkServiceSingleLive;
    // 超时计时器: 停止
    [self.timer invalidate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inviterReceivedPkRejectFromInviteeImAccId:rejectType:)]) {
        NETSPkRejectedType rejectType = NETSPkRejectedArtificial;
        if ([response.customInfo isEqualToString:kInviteeBusyRejectPk]) {
            rejectType = NETSPkRejectedForBusyInvitee;
        }
        [self.delegate inviterReceivedPkRejectFromInviteeImAccId:response.fromAccountId rejectType:rejectType];
    }
}

- (void)_inviterReceivedPkAcceptWithInviteeResponse:(NIMSignalingAcceptNotifyInfo *)response
{
    // 校验requestId
    if (![response.requestId isEqualToString:self.inviteRequest.requestId]) {
        NETSLog(@"非法PK邀请请求");
        return;
    }
    
    self.liveStatus = NETSPkServicePkLive;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inviterReceivedPkAcceptFromInviteeImAccId:)]) {
        [self.delegate inviterReceivedPkAcceptFromInviteeImAccId:response.fromAccountId];
    }
}

@end
