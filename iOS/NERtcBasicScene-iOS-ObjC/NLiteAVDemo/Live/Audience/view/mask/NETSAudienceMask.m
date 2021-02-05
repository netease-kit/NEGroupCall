//
//  NETSAudienceMask.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSAudienceMask.h"
#import "NETSAnchorTopInfoView.h"
#import "NETSAudienceNum.h"
#import "UIView+NTES.h"
#import "NETSLiveChatView.h"
#import "NETSLiveChatViewHandle.h"
#import "NETSAudienceVM.h"
#import "NETSAudienceBottomBar.h"
#import "NETSLiveConfig.h"
#import "NETSAudienceSendGiftSheet.h"
#import "NETSMoreSettingActionSheet.h"
#import "NENavigator.h"
#import "NETSChatroomService.h"
#import "NETSLiveAttachment.h"
#import "NETSLiveApi.h"
#import "NETSToast.h"
#import "NETSPkStatusBar.h"
#import "NETSLiveUtils.h"
#import "LOTAnimationView.h"
#import "NETSInviteeInfoView.h"
#import "NETSKeyboardToolbar.h"
#import <NELivePlayerFramework/NELivePlayerNotication.h>
#import "NETSGCDTimer.h"
#import "NETSGiftAnimationView.h"

#define kPkAudienceTimerQueue            "com.netease.pk.audience.timer.queue"

@interface NETSAudienceMask ()
<
    NETSLiveChatViewHandleDelegate,
    NETSAudienceBottomBarDelegate,
    NETSAudienceSendGiftSheetDelegate,
    NETSKeyboardToolbarDelegate
>

/// 主播信息
@property (nonatomic, strong)   NETSAnchorTopInfoView   *anchorInfo;
/// 直播中 观众数量视图
@property (nonatomic, strong)   NETSAudienceNum         *audienceInfo;
/// 聊天视图
@property (nonatomic, strong)   NETSLiveChatView        *chatView;
/// 聊天室代理
@property (nonatomic, strong)   NETSLiveChatViewHandle  *chatHandle;
/// viewModel
@property (nonatomic, strong)   NETSAudienceVM          *viewModel;
/// 底部视图
@property (nonatomic, strong)   NETSAudienceBottomBar   *bottomBar;
/// 键盘工具条
@property (nonatomic, strong)   NETSKeyboardToolbar     *toolBar;
/// pk状态条
@property (nonatomic, strong)   NETSPkStatusBar         *pkStatusBar;
/// 被邀请者信息视图
@property (nonatomic, strong)   NETSInviteeInfoView     *inviteeInfo;
/// 获取PK左侧打赏榜单信号
@property (nonatomic, strong)   RACSubject      *leftPkRewardSubject;
/// 获取PK右侧打赏榜单信号
@property (nonatomic, strong)   RACSubject      *rightPkRewardSubject;
/// pk胜利图标
@property (nonatomic, strong)   UIImageView     *pkSuccessIco;
/// pk失败图标
@property (nonatomic, strong)   UIImageView     *pkFailedIco;
/// 计时器操作队列
@property (nonatomic, strong) dispatch_queue_t      timerQueue;
/// 计时器,记录超时
@property (nonatomic, strong, nullable) NETSGCDTimer            *timer;
/// 礼物动画控件
@property (nonatomic, strong)   NETSGiftAnimationView   *giftAnimation;
/// 直播间状态
@property (nonatomic, assign)   NETSRoomLiveStatus      liveStatus;

@end

@implementation NETSAudienceMask

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _chatHandle = [[NETSLiveChatViewHandle alloc] initWithDelegate:self];
        
        [[NIMSDK sharedSDK].chatManager addDelegate:_chatHandle];
        [[NIMSDK sharedSDK].chatroomManager addDelegate:_chatHandle];
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:_chatHandle];
        
        [self addSubview:self.anchorInfo];
        [self addSubview:self.audienceInfo];
        [self addSubview:self.chatView];
        [self addSubview:self.bottomBar];
        
        _leftPkRewardSubject = [RACSubject subject];
        _rightPkRewardSubject = [RACSubject subject];
        [self _bindEvent];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayerFrameChanged:) name:NELivePlayerVideoSizeChangedNotification object:nil];
        
        _timerQueue = dispatch_queue_create(kPkAudienceTimerQueue, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].chatManager removeDelegate:_chatHandle];
    [[NIMSDK sharedSDK].chatroomManager removeDelegate:_chatHandle];
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:_chatHandle];
    NETSLog(@"dealloc NETSAudienceMask: %p", self);
}

- (void)_bindEvent
{
    @weakify(self);
    RACSignal *roomSignal = RACObserve(self, room);
    [roomSignal subscribeNext:^(NETSLiveRoomModel *x) {
        @strongify(self);
        if (x == nil) { return; }
        self.chatHandle.roomId = x.chatRoomId;
        [self _refreshAudienceInfoWitHRoomId:x.chatRoomId];
        self.anchorInfo.nickname = x.nickname;
        self.anchorInfo.avatarUrl = x.avatar;
    }];
    
    [[roomSignal zipWith:RACObserve(self, info)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        NETSLiveRoomModel *room = (NETSLiveRoomModel *)tuple.first;
        NETSLiveRoomInfoModel *info = (NETSLiveRoomInfoModel *)tuple.second;
        if (room && info) {
            // 更新主播云币
            self.anchorInfo.wealth = info.coinTotal;
            // 刷新直播间
            [self refreshWithRoom:room info:info];
        }
    }];
    
    // pk左右榜单请求结果信号
    RACSignal *signal = [self.leftPkRewardSubject zipWith:self.rightPkRewardSubject];
    [signal subscribeNext:^(RACTuple *tuple) {
        NETSPkLiveContriList *leftData = (NETSPkLiveContriList *)tuple.first;
        NETSPkLiveContriList *rightData = (NETSPkLiveContriList *)tuple.second;
        ntes_main_async_safe(^{
            @strongify(self);
            [self.pkStatusBar refreshWithLeftRewardCoins:leftData.rewardCoinTotal
                                       leftRewardAvatars:leftData.rewardAvatars
                                        rightRewardCoins:rightData.rewardCoinTotal
                                      rightRewardAvatars:rightData.rewardAvatars];
        });
    }];
}

- (void)layoutSubviews
{
    self.anchorInfo.frame = CGRectMake(8, (kIsFullScreen ? 44 : 20) + 4, 124, 36);
    self.audienceInfo.frame = CGRectMake(kScreenWidth - 8 - 195, self.anchorInfo.top + (36 - 28) / 2.0, 195, 28);
    CGFloat chatViewHeight = [self _chatViewHeight];
    self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
    self.bottomBar.frame = CGRectMake(0, kScreenHeight - (kIsFullScreen ? 34 : 0) - 36 - 14, kScreenWidth, 36);
}

- (void)setRoom:(NETSLiveRoomModel *)room
{
    _room = room;
}

- (void)refreshWithRoom:(NETSLiveRoomModel *)room info:(NETSLiveRoomInfoModel *)info
{
    _liveStatus = NETSRoomLiving;
    if (info.pkRecord) {
        _liveStatus = info.pkRecord.status;
    }
    
    if (_liveStatus == NETSRoomPKing || _liveStatus == NETSRoomPunishment) {
        // 布局PK状态栏
        [self _layoutPkStatusBarWithStatus:info.status];
        // 启动PK倒计时
        int32_t totalTime = kPkLiveTotalTime;
        int64_t startTime = info.pkRecord.pkStartTime;
        if (_liveStatus == NETSRoomPunishment) {
            totalTime = kPkLivePunishTotalTime;
            startTime = info.pkRecord.punishmentStartTime;
        }
        int32_t countdown = totalTime - (int32_t)((info.pkRecord.currentTime - startTime) / 1000);
        [self.pkStatusBar countdownWithSeconds:countdown];
        
        // 获取PK榜打赏信息
        @weakify(self);
        [self _fetchRewardListWithLiveCid:room.liveCid anchorAccountId:room.accountId successBlock:^(NETSPkLiveContriList *list) {
            @strongify(self);
            [self.leftPkRewardSubject sendNext:list];
        } failedBlock:nil];
        
        NSString *rightCid = info.pkRecord.inviterLiveCid;
        NSString *rightAcid = info.pkRecord.inviter;
        if ([room.liveCid isEqualToString:info.pkRecord.inviterLiveCid]) {
            rightCid = info.pkRecord.inviteeLiveCid;
            rightAcid = info.pkRecord.invitee;
        }
        [self _fetchRewardListWithLiveCid:rightCid anchorAccountId:rightAcid successBlock:^(NETSPkLiveContriList *list) {
            @strongify(self);
            [self.rightPkRewardSubject sendNext:list];
        } failedBlock:nil];
        
        // 布局PK被邀请者信息视图
        if ([info.members count] > 1) {
            NETSLiveRoomModel *obj = [info.members firstObject];
            for (NETSLiveRoomModel *item in info.members) {
                if (![item.chatRoomCreator isEqualToString:room.chatRoomCreator]) {
                    obj = item;
                    break;
                }
            }
            [self _layoutOtherAnchorWithAvatar:obj.avatar nickname:obj.nickname status:info.status];
        }
        
        // 惩罚态获取胜负信息
        if (_liveStatus == NETSRoomPunishment) {
            // 默认当前主播为邀请者
            BOOL currentAuthorWin = info.pkRecord.inviterRewards >= info.pkRecord.inviteeRewards;
            if ([_room.liveCid isEqualToString:info.pkRecord.inviteeLiveCid]) {
                // 当前主播为被邀请者
                currentAuthorWin = info.pkRecord.inviteeRewards > info.pkRecord.inviterRewards;
            }
            [self _layoutPkResultWhenGetCurrentAnchorWin:currentAuthorWin];
        }
        
        // 设定播放器偏移
        if (_delegate && [_delegate respondsToSelector:@selector(didChangeRoomStatus:)]) {
            [_delegate didChangeRoomStatus:info.status];
        }
    } else {
        [self.inviteeInfo removeFromSuperview];
        [self.pkStatusBar removeFromSuperview];
        [self.pkSuccessIco removeFromSuperview];
        [self.pkFailedIco removeFromSuperview];
    }
}

#pragma mark - setter/getter

- (void)setRoomStatus:(NETSAudienceRoomStatus)roomStatus
{
    _roomStatus = roomStatus;
    if (roomStatus != NETSAudienceRoomPlaying) {
        [self.inviteeInfo removeFromSuperview];
        [self.pkStatusBar removeFromSuperview];
        [self.pkSuccessIco removeFromSuperview];
        [self.pkFailedIco removeFromSuperview];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeRoomStatus:)]) {
            [self.delegate didChangeRoomStatus:NETSAudienceStreamDefault];
        }
    }
}

#pragma mark - private method

/// 获取聊天视图高度
- (CGFloat)_chatViewHeight
{
    if (kScreenHeight <= 568) {
        return 100;
    } else if (kScreenHeight <= 736) {
        return 130;
    }
    return 204;
}

/// 布局另一个主播信息视图
- (void)_layoutOtherAnchorWithAvatar:(NSString *)avatar nickname:(NSString *)nickname status:(NETSRoomLiveStatus)status
{
    if (_roomStatus == NETSAudienceRoomLiveClosed || _room == NETSAudienceRoomLiveError) { return; }
    if (status == NETSRoomPKing || status == NETSRoomPunishment)  {
        CGFloat topOffset = 72 + (kIsFullScreen ? 44 : 20);
        self.inviteeInfo.frame = CGRectMake(self.right - 8 - 82, topOffset, 82, 24);
        [self.inviteeInfo reloadAvatar:avatar nickname:nickname];
        [self addSubview:self.inviteeInfo];
    } else {
        [self.inviteeInfo removeFromSuperview];
    }
}

/// 布局pk状态条
- (void)_layoutPkStatusBarWithStatus:(NETSRoomLiveStatus)status
{
    if (_roomStatus == NETSAudienceRoomLiveClosed || _room == NETSAudienceRoomLiveError) { return; }
    if (status == NETSRoomPKing || status == NETSRoomPunishment) {
        CGFloat topOffset = (kIsFullScreen ? 44 : 20) + 44 + 20 + kScreenWidth * 640 / 720.0;
        CGRect rect = CGRectMake(0, topOffset, self.width, 58);
        self.pkStatusBar.frame = rect;
        [self addSubview:self.pkStatusBar];
    }
}

/// 布局胜负标志: pk阶段结束,返回pk结果
- (void)_layoutPkResultWhenGetCurrentAnchorWin:(BOOL)currentAnchorWin
{
    if (_roomStatus == NETSAudienceRoomLiveClosed || _room == NETSAudienceRoomLiveError) { return; }
    CGFloat top = 64 + (kIsFullScreen ? 44 : 20) + kScreenWidth * 0.5 * 640 / 360.0 - 120;
    CGRect successRect = CGRectMake((kScreenWidth * 0.5 - 120) * 0.5, top, 120, 120);
    CGRect failedRect = CGRectMake(kScreenWidth * 0.5 + (kScreenWidth * 0.5 - 120) * 0.5, top, 120, 120);
    
    if (currentAnchorWin) {
        self.pkSuccessIco.frame = successRect;
        self.pkFailedIco.frame = failedRect;
    } else {
        self.pkSuccessIco.frame = failedRect;
        self.pkFailedIco.frame = successRect;
    }
    [self addSubview:self.pkSuccessIco];
    [self addSubview:self.pkFailedIco];
}

/// 布局胜负标志: 惩罚结束(pk结束)
- (void)_layoutPkResultWhenPunishmentEnd
{
    [self.pkSuccessIco removeFromSuperview];
    [self.pkFailedIco removeFromSuperview];
}

/// 获取打赏列表
- (void)_fetchRewardListWithLiveCid:(NSString *)liveCid anchorAccountId:(NSString *)anchorAccountId successBlock:(void(^)(NETSPkLiveContriList *))successBlock failedBlock:(void(^)(NSError *))failedBlock
{
    [NETSLiveApi getPkLiveContriListWithLiveCid:liveCid liveType:NETSLiveTypePK anchorAccountId:anchorAccountId successBlock:^(NSDictionary * _Nonnull response) {
        NETSPkLiveContriList *list = response[@"/data"];
        if (list) {
            if (successBlock) { successBlock(list); }
        } else {
            NETSLog(@"观众获取pk打赏榜数据为空...");
        }
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        NETSLog(@"观众获取pk打赏榜失败, error: %@", error);
    }];
}

/// 点击屏幕收起键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.toolBar resignFirstResponder];
    [self.bottomBar resignFirstResponder];
}

/// 主播进/出直播间操作
- (void)_didAuthorEnterLiveRoom:(BOOL)enter userId:(NSString *)userId
{
    if (![userId isEqualToString:_room.imAccid]) { return; }
    if (enter) {
        [self.timer invalidate];
        NETSLog(@"主播进入直播间,清除计时器");
    } else {
        @weakify(self);
        self.timer = [NETSGCDTimer scheduledTimerWithTimeInterval:25 repeats:NO queue:self.timerQueue triggerImmediately:NO block:^{
            @strongify(self);
            [self _liveRoomClosed];
        }];
        NETSLog(@"主播离开直播间,设定超时离开");
    }
}

/// 播放礼物动画
- (void)_playGiftWithName:(NSString *)name
{
    [self addSubview:self.giftAnimation];
    [self bringSubviewToFront:self.giftAnimation];
    [self.giftAnimation addGift:name];
}

#pragma mark - 当键盘事件

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float keyBoardHeight = keyboardRect.size.height;
    CGFloat chatViewHeight = [self _chatViewHeight];
    [UIView animateWithDuration:0.1 animations:^{
        self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - chatViewHeight - keyBoardHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
    }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    CGFloat chatViewHeight = [self _chatViewHeight];
    [UIView animateWithDuration:0.1 animations:^{
        self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
    }];
}

/// 刷新观众信息
- (void)_refreshAudienceInfoWitHRoomId:(NSString *)roomId
{
    [NETSChatroomService fetchMembersRoomId:self.room.chatRoomId limit:10 successBlock:^(NSArray<NIMChatroomMember *> * _Nullable members) {
        NETSLog(@"members: %@", members);
        [self.audienceInfo reloadWithDatas:members];
    } failedBlock:^(NSError * _Nonnull error) {
        NETSLog(@"观众端获取IM聊天室成员失败, error: %@", error);
    }];
}

#pragma mark - 播放器通知

- (void)didPlayerFrameChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeRoomStatus:)]) {
        CGFloat height = [userInfo[NELivePlayerVideoHeightKey] floatValue];
        NETSAudienceStreamStatus status = NETSAudienceStreamDefault;
        if (height == 640) {
            status = NETSAudienceStreamMerge;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate didChangeRoomStatus:status];
        });
    }
    
    NETSLog(@"video size changed, width: %@, height: %@", userInfo[NELivePlayerVideoWidthKey] ?: @"-", userInfo[NELivePlayerVideoHeightKey] ?: @"-");
}

#pragma mark - NETSLiveChatViewHandleDelegate 聊天室代理

/// 进入或离开房间
- (void)didChatroomMember:(NIMChatroomNotificationMember *)member enter:(BOOL)enter sessionId:(NSString *)sessionId
{
    if (![sessionId isEqualToString:_room.chatRoomId]) {
        return;
    }
    [self _didAuthorEnterLiveRoom:enter userId:member.userId];
    
    if (enter) {
        _viewModel.chatroom.onlineUserCount++;
        NETSLog(@"[demo] user %@ enter room.", member.userId);
    } else {
        _viewModel.chatroom.onlineUserCount--;
        NETSLog(@"[demo] user %@ leaved room.", member.userId);
    }
    
    NIMMessage *message = [[NIMMessage alloc] init];
    message.text = [NSString stringWithFormat:@"\"%@\" %@房间", member.nick, (enter ? @"加入":@"离开")];
    message.remoteExt = @{@"type":@(1)};
    [_chatView addMessages:@[message]];
    
    [self _refreshAudienceInfoWitHRoomId:_room.chatRoomId];
}

/// 直播间关闭
- (void)didChatroomClosedWithRoomId:(NSString *)roomId
{
    if (![roomId isEqualToString:_room.chatRoomId]) {
        return;
    }
    NETSLog(@"聊天室关闭");
    [self _liveRoomClosed];
}

/// 聊天室收到PK消息
- (void)didReceivedPKMessage:(NIMMessage *)message
{
    if (![message.session.sessionId isEqualToString:_room.chatRoomId]) {
        return;
    }
    NETSLivePKAttachment *attch = [NETSLivePKAttachment getAttachmentWithMessage:message];
    NETSLog(@"观众端 聊天室收到PK消息, status: %lu", (unsigned long)attch.state);
    
    if (attch.state == NETSLiveAttachmentStatusStart) {
        _liveStatus = NETSRoomPKing;
    }
    
    // pk开始:通知外围变更播放器frame
    if (attch.state == NETSLiveAttachmentStatusStart && self.delegate && [self.delegate respondsToSelector:@selector(didChangeRoomStatus:)]) {
        [self.delegate didChangeRoomStatus:NETSAudienceIMPkStart];
    }
    
    // pk第二主播信息载入
    [self _layoutOtherAnchorWithAvatar:attch.otherAnchorAvatar nickname:attch.otherAnchorNickname status:_liveStatus];
    // pk状态栏变更
    [self _layoutPkStatusBarWithStatus:_liveStatus];
    // pk开始: 启动倒计时,刷新内容
    if (attch.state == NETSLiveAttachmentStatusStart) {
        int32_t countdown = kPkLiveTotalTime - (int32_t)((attch.currentTimestamp - attch.startedTimestamp) / 1000);
        [self.pkStatusBar countdownWithSeconds:countdown];
        [self.pkStatusBar refreshWithLeftRewardCoins:0 leftRewardAvatars:@[] rightRewardCoins:0 rightRewardAvatars:@[]];
    }
    // 显示pk结果
    if (attch.state == NETSLiveAttachmentStatusEnd) {
        [self _layoutPkResultWhenGetCurrentAnchorWin:attch.currentAnchorWin];
    }
}

/// 聊天室收到惩罚消息
- (void)didReceivedPunishMessage:(NIMMessage *)message
{
    if (![message.session.sessionId isEqualToString:_room.chatRoomId]) {
        return;
    }
    NETSLivePunishAttachment *attch = [NETSLivePunishAttachment getAttachmentWithMessage:message];
    NETSLog(@"观众端 聊天室收到惩罚消息, status: %lu", (unsigned long)attch.state);
    // pk状态条
    if (attch.state == NETSLiveAttachmentStatusStart) {
        _liveStatus = NETSRoomPunishment;
        int32_t seconds = kPkLivePunishTotalTime - (int32_t)((attch.startedTimestamp - attch.currentTimestamp) / 1000);
        [self.pkStatusBar countdownWithSeconds:seconds];
    } else {
        _liveStatus = NETSRoomPKEnd;
        
        [self.pkStatusBar stopCountdown];
        [self.pkStatusBar removeFromSuperview];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeRoomStatus:)]) {
            ntes_main_async_safe(^{
                [self.delegate didChangeRoomStatus:NETSAudienceStreamDefault];
            });
        }
    }
    // pk结束:通知外围变更播放器frame(因视频帧尺寸变化和信令可能有时差,取消该处操作)
//    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeRoomStatus:)] && attch.state == NETSLiveAttachmentStatusEnd) {
//        [self.delegate didChangeRoomStatus:NETSAudienceIMPkEnd];
//    }
    // 第二主播信息载入
    [self _layoutOtherAnchorWithAvatar:attch.otherAnchorAvatar nickname:attch.otherAnchorNickname status:_liveStatus];
    // 移除pk结果
    if (attch.state == NETSLiveAttachmentStatusEnd) {
        [self _layoutPkResultWhenPunishmentEnd];
    }
}

/// 收到主播发出的云币同步消息
- (void)didReceivedSyncWealthMessage:(NIMMessage *)message
{
    if (![message.session.sessionId isEqualToString:_room.chatRoomId]) {
        return;
    }
    NETSLog(@"观众端 收到主播发出的云币同步消息");
    NETSLiveWealthChangeAttachment *attach = [NETSLiveWealthChangeAttachment getAttachmentWithMessage:message];
    
    // pk状态栏变更
    [self.pkStatusBar refreshWithLeftRewardCoins:attach.PKCoinCount
                               leftRewardAvatars:[attach originRewardAvatars]
                                rightRewardCoins:attach.otherPKCoinCount
                              rightRewardAvatars:[attach originOtherRewardAvatars]];
    
    // 更新主播云币值
    self.anchorInfo.wealth = attach.totalCoinCount;
    
    // 确认是给当前直播间打赏
    if ([attach.fromUserAvRoomUid isEqualToString:_room.roomUid]) {
        // 展示礼物动画
        NETSGiftModel *giftModel = [NETSLiveUtils getRewardWithGiftId:attach.giftId];
        if (giftModel) {
            NSString *giftName = [NSString stringWithFormat:@"anim_gift_0%d",giftModel.giftId];
            [self _playGiftWithName:giftName];
        }
        
        // 聊天室增加打赏信息
        [self.chatView addMessages:@[message]];
    }
}

/// 收到文本消息
- (void)didReceivedTextMessage:(NIMMessage *)message
{
    if (![message.session.sessionId isEqualToString:_room.chatRoomId]) {
        return;
    }
    NETSLog(@"观众端 收到文本消息");
    [self.chatView addMessages:@[message]];
}

/// 直播间关闭
- (void)_liveRoomClosed
{
    // 关闭计时器
    [self.timer invalidate];
    
    // 调用代理
    if (_delegate && [_delegate respondsToSelector:@selector(didLiveRoomClosed)]) {
        [_delegate didLiveRoomClosed];
    }
    self.chatRoomAvailable = NO;
}

#pragma mark - NETSAudienceBottomBarDelegate 底部工具条代理

- (void)clickTextLabel:(UILabel *)label
{
    NETSLog(@"点击输入框");
    [self.toolBar becomeFirstResponder];
}

- (void)clickGiftBtn
{
    NETSLog(@"点击礼物");
    NSArray *gifts = [NETSLiveConfig shared].gifts;
    [NETSAudienceSendGiftSheet showWithTarget:self gifts:gifts];
}

- (void)clickCloseBtn
{
    NETSLog(@"退出直播间");
    // 关闭计时器
    [self.timer invalidate];
    [NETSChatroomService exitWithRoomId:_room.chatRoomId];
    [[NENavigator shared].navigationController popViewControllerAnimated:YES];
}

#pragma mark -  NETSAudienceSendGiftSheetDelegate 打赏面板代理事件

- (void)didSendGift:(NETSGiftModel *)gift onSheet:(NETSAudienceSendGiftSheet *)sheet
{
    [sheet dismiss];
    
    if (isEmptyString(_room.accountId) || isEmptyString(_room.liveCid)) {
        NETSLog(@"观众打赏参数错误 Error");
        return;
    }
    NETSLiveType type = NETSLiveTypeNormal;
    if (_liveStatus == NETSRoomPKing || _liveStatus == NETSRoomPunishment) {
        type = NETSLiveTypePK;
    }
    [NETSLiveApi rewardLiveCid:_room.liveCid liveType:type anchorAccountId:_room.accountId giftId:gift.giftId completionHandle:^(NSDictionary * _Nonnull response) {
        NSDictionary *res = response[@"/"];
        NSInteger code = [res[@"code"] integerValue];
        if (code != 200) {
            NETSLog(@"观众打赏失败, Error: %ld", (long)code);
        }
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        if (error) {
            NETSLog(@"观众打赏失败, Error: %@", error);
        }
    }];
}

#pragma mark - NETSKeyboardToolbarDelegate

- (void)didToolBar:(NETSKeyboardToolbar *)toolBar sendText:(NSString *)text
{
    if (isEmptyString(text)) {
        [NETSToast showToast:@"消息内容为空"];
        return;
    }
    NSString *roomId = self.room.chatRoomId;
    NSString *nickname = self.room.nickname;
    NSError *error = nil;
    [NETSChatroomService sendMessage:text inRoomId:roomId userMode:NETSUserModeAudience nickname:nickname errorPtr:&error];
    if (error) {
        NETSLog(@"观众端发送消息失败: %@", error);
    }
}

// 关闭直播间
- (void)closeChatRoom {
    [self _liveRoomClosed];
}

#pragma mark - lazy load

- (NETSAnchorTopInfoView *)anchorInfo
{
    if (!_anchorInfo) {
        _anchorInfo = [[NETSAnchorTopInfoView alloc] init];
    }
    return _anchorInfo;
}

- (NETSAudienceNum *)audienceInfo
{
    if (!_audienceInfo) {
        _audienceInfo = [[NETSAudienceNum alloc] initWithFrame:CGRectZero];
    }
    return _audienceInfo;
}

- (NETSLiveChatView *)chatView
{
    if (!_chatView) {
        CGRect frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - 204, kScreenWidth - 16 - 60 - 20, 204);
        _chatView = [[NETSLiveChatView alloc] initWithFrame:frame];
    }
    return _chatView;
}

- (NETSAudienceBottomBar *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [[NETSAudienceBottomBar alloc] init];
        _bottomBar.textField.inputAccessoryView = self.toolBar;
        _bottomBar.delegate = self;
    }
    return _bottomBar;
}

- (NETSKeyboardToolbar *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[NETSKeyboardToolbar alloc] init];
        _toolBar.cusDelegate = self;
    }
    return _toolBar;
}

- (NETSPkStatusBar *)pkStatusBar
{
    if (!_pkStatusBar) {
        _pkStatusBar = [[NETSPkStatusBar alloc] init];
    }
    return _pkStatusBar;
}

- (NETSInviteeInfoView *)inviteeInfo
{
    if (!_inviteeInfo) {
        _inviteeInfo = [[NETSInviteeInfoView alloc] init];
    }
    return _inviteeInfo;
}

- (UIImageView *)pkSuccessIco
{
    if (!_pkSuccessIco) {
        UIImage *image = [UIImage imageNamed:@"pk_succeed_ico"];
        _pkSuccessIco = [[UIImageView alloc] initWithImage:image];
    }
    return _pkSuccessIco;
}

- (UIImageView *)pkFailedIco
{
    if (!_pkFailedIco) {
        UIImage *image = [UIImage imageNamed:@"pk_failed_ico"];
        _pkFailedIco = [[UIImageView alloc] initWithImage:image];
    }
    return _pkFailedIco;
}

- (NETSGiftAnimationView *)giftAnimation
{
    if (!_giftAnimation) {
        _giftAnimation = [[NETSGiftAnimationView alloc] init];
    }
    return _giftAnimation;
}

@end
