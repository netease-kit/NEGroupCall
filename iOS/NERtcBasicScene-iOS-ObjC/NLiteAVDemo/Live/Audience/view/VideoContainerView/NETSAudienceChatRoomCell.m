//
//  NETSAudienceChatRoomCell.m
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2021/1/7.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSAudienceChatRoomCell.h"
#import <NELivePlayerFramework/NELivePlayerFramework.h>
#import "NETSLiveListVM.h"
#import "NETSAudienceMask.h"
#import "NETSLiveModel.h"
#import "NETSChatroomService.h"
#import "NENavigator.h"
#import "NETSLiveApi.h"
#import "UIView+NTES.h"
#import "NETSPullStreamErrorView.h"
#import "Reachability.h"
#import "NETSLiveEndView.h"

@interface NETSAudienceChatRoomCell ()<NETSPullStreamErrorViewDelegate, NETSAudienceMaskDelegate>

/// 蒙层
@property (nonatomic, strong) NETSAudienceMask          *mask;
/// 直播间状态
@property (nonatomic, strong) NETSLiveRoomInfoModel     *roomInfo;
/// 断网视图
@property(nonatomic, strong) NETSPullStreamErrorView    *networkFailureView;
/// 直播结束蒙层
@property(nonatomic, strong) NETSLiveEndView            *liveClosedMask;
/// 网络监测类
@property(nonatomic, strong) Reachability               *reachability;
/// 播放器
@property(nonatomic, strong) NELivePlayerController     *player;
/// 直播间状态
@property(nonatomic, assign) NETSAudienceRoomStatus     roomStatus;

@end

@implementation NETSAudienceChatRoomCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.mask];
        
        self.reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
        [self.reachability startNotifier];
        self.mask.chatRoomAvailable = [self.reachability isReachable];
        
        // 播放器视图添加向左轻扫动作
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_swipeShowMask:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.contentView addGestureRecognizer:swipeLeft];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_swipeDismissMask:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.contentView addGestureRecognizer:swipeRight];
        
        // 播放器相关通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackFinishedNotification:) name:NELivePlayerPlaybackFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerRetryNotification:) name:NELivePlayerRetryNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFirstVideoDisplayedNotification:) name:NELivePlayerFirstVideoDisplayedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLoadStateChangedNotification:) name:NELivePlayerLoadStateChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackStateChangedNotification:) name:NELivePlayerPlaybackStateChangedNotification object:nil];
        
        // 监测网络
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    NETSLog(@"dealloc NETSAudienceChatRoomCell: %p", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self shutdownPlayer];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self shutdownPlayer];
}

#pragma mark - public method

- (void)resetPageUserinterface
{
    // 添加mask之前先移除关闭直播的蒙版
    self.roomStatus = NETSAudienceRoomPullStream;
    [self.liveClosedMask removeFromSuperview];
    self.mask.left = 0;
}

- (void)shutdownPlayer;
{
    NETSLog(@"观众端 关闭播放器");
    if (!_player) { return; }
    [self.player pause];
    [self.player shutdown];
    [self.player.view removeFromSuperview];
    self.player = nil;
}

#pragma mark - get/set

- (void)setRoomModel:(NETSLiveRoomModel *)roomModel
{
    _roomModel = roomModel;
    self.mask.room = roomModel;
    [self _obtainChatroomInfo:roomModel];
}

#pragma mark - NETSPullStreamErrorViewDelegate

/// 点击返回
- (void)clickBackAction
{
    [[NENavigator shared].navigationController popViewControllerAnimated:YES];
}

/// 重新连接
- (void)clickRetryAction
{
    [self.networkFailureView removeFromSuperview];
    self.mask.roomStatus = NETSAudienceRoomPullStream;
    [self _obtainChatroomInfo:self.roomModel];
}

#pragma mark - Notification Method

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability *currentReach = [note object];
    NSCParameterAssert([currentReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [currentReach currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:{// 网络不可用
            NETSLog(@"断网了");
            [self _showLiveRoomErrorView];
            [self shutdownPlayer];
        }
            break;

        default:
            break;
    }
}

#pragma mark - player notification

/// 播放器播放完成或播放发生错误时的消息通知
- (void)playerPlaybackFinishedNotification:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    [self _playerLoadErrorInfo:info];
    NETSLog(@"观众端 播放器播放完成或播放发生错误时的消息通知, info: %@", info);
}

/// 播放器失败重试通知
- (void)playerRetryNotification:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    [self _playerLoadErrorInfo:info];
    NETSLog(@"观众端 播放器重试加载, info: %@", info);
}

/// 播放器第一帧视频显示时的消息通知
- (void)playerFirstVideoDisplayedNotification:(NSNotification *)notification
{
    NETSLog(@"观众端 播放器首帧播放");
    self.roomStatus = NETSAudienceRoomPlaying;
}

/// 播放器加载状态发生改变时的消息通知
- (void)playerLoadStateChangedNotification:(NSNotification *)notification
{
    NETSLog(@"观众端 播放器加载状态发生改变时的消息通知, info: %ld", (long)_player.loadState);
}

/// 播放器播放状态发生改变时的消息通知
- (void)playerPlaybackStateChangedNotification:(NSNotification *)notification
{
    NETSLog(@"观众端 播放器播放状态发生改变时的消息通知, playbackState: %ld", (long)_player.playbackState);
}

/// 播放器加载错误处理
- (void)_playerLoadErrorInfo:(NSDictionary *)info
{
    NETSLog(@"观众端 处理播放器通知参数, info: %@", info);
    // 播放器播放结束原因的key
    NELPMovieFinishReason reason = [info[NELivePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    if (reason != NELPMovieFinishReasonPlaybackError) {
        return;
    }
    // 播放成功时，此字段为nil。播放器播放结束具体错误码。具体至含义见NELPPLayerErrorCode
    NELPPLayerErrorCode errorCode = [info[NELivePlayerPlaybackDidFinishErrorKey] integerValue];
    if (errorCode != 0) {
        [self _showLiveRoomErrorView];
    }
}

#pragma mark - NETSAudienceMaskDelegate

- (void)didChangeRoomStatus:(NETSAudienceStreamStatus)status
{
    // 视频上边缘距离设备顶部
    CGFloat top = 64 + (kIsFullScreen ? 44 : 20);
    // 获取播放器视图
    UIView *playerView = self.player.view;
    switch (status) {
        case NETSAudienceIMPkStart:
        {
            CGFloat scale = 1280 / 720.0;
            CGFloat y = top - (kScreenHeight - scale * kScreenWidth) * 0.5 * 0.5;
            CGRect origin = playerView.frame;
            playerView.frame = CGRectMake(0, y, origin.size.width * 0.5, origin.size.height * 0.5);
        }
            break;
        case NETSAudienceStreamMerge:
        {
            CGFloat y = top - (kScreenHeight - (640 / 720.0 * kScreenWidth)) / 2.0;
            playerView.frame = CGRectMake(0, y, kScreenWidth, kScreenHeight);
        }
            break;
        case NETSAudienceIMPkEnd:
        {
            playerView.frame = CGRectMake(0, 0, kScreenWidth * 2, kScreenHeight * 2);
            playerView.centerX = kScreenWidth;
            playerView.centerY = self.contentView.centerY;
        }
            break;
            
        default:
        {
            playerView.frame = self.contentView.bounds;
        }
            break;
    }
    NETSLog(@"观众端播放器状态, status: %ld", (long)status);
}

/// 直播间关闭
- (void)didLiveRoomClosed
{
    [self _showLiveRoomClosedView];
}

#pragma mark - private mehod

- (void)_showLiveRoomClosedView
{
    ntes_main_async_safe(^{
        self.roomStatus = self.mask.roomStatus = NETSAudienceRoomLiveClosed;
        [self.liveClosedMask installWithAvatar:self.roomModel.avatar nickname:self.roomModel.nickname];
        [self.mask addSubview:self.liveClosedMask];
    });
}

- (void)_showLiveRoomErrorView
{
    ntes_main_async_safe(^{
        self.roomStatus = self.mask.roomStatus = NETSAudienceRoomLiveError;
        [self.mask addSubview:self.networkFailureView];
    });
}

/// 获取直播间详情
- (void)_obtainChatroomInfo:(NETSLiveRoomModel *)roomModel
{
    @weakify(self);
    void(^joinRoomSuccess)(NETSLiveRoomModel *, NETSLiveRoomInfoModel *) = ^(NETSLiveRoomModel *room, NETSLiveRoomInfoModel *info){
        ntes_main_async_safe(^{
            @strongify(self);
            self.mask.info = info;
            CGFloat y = 0;
            if (info.pkRecord && (info.status == NETSRoomPKing || info.status == NETSRoomPunishment)) {
                CGFloat top = 64 + (kIsFullScreen ? 44 : 20);
                y = top - (kScreenHeight - (640 / 720.0 * kScreenWidth)) / 2.0;
            }
            [self _layoutPlayerWithY:y];
            NSString *urlStr = room.liveConfig.rtmpPullUrl;
            NETSLog(@"观众端 设置播放地址: %@", room.liveConfig.rtmpPullUrl);
            [self _playWithUrl:urlStr];
        });
        NETSLog(@"观众端 加入直播间成功");
    };
    
    void(^joinRoomFailed)(NSError *) = ^(NSError *error){
        @strongify(self);
        [self _alertToExitRoomWithError:error];
        NETSLog(@"观众端 加入直播间失败, error: %@", error);
    };
    
    [NETSLiveApi roomInfoWithCid:roomModel.liveCid completionHandle:^(NSDictionary * _Nonnull response) {
        @strongify(self);
        NETSLiveRoomInfoModel *info = response[@"/data"];
        if (!info) {
            NETSLog(@"获取直播间详情失败, 房间信息为空");
            return;
        }
        self.roomInfo = info;
        [self _joinChatRoom:roomModel.chatRoomId successBlock:^{
            joinRoomSuccess(roomModel, info);
        } failedBlock:joinRoomFailed];
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        @strongify(self);
        if ([self.reachability isReachable]) {
            [self.mask closeChatRoom];
        }
        NETSLog(@"获取直播间详情失败, error: %@", error);
    }];
}

/// 布局播放器
- (void)_layoutPlayerWithY:(CGFloat)y
{
    [self.contentView addSubview:self.player.view];
    [self.contentView sendSubviewToBack:self.player.view];
    
    self.player.view.top = y;
    
    
}

/// 播放指定url源
- (void)_playWithUrl:(NSString *)urlStr
{
    NSURL *url = [NSURL URLWithString:urlStr];
    [self.player setPlayUrl:url];
    [self.player prepareToPlay];
}

/// 加入聊天室
- (void)_joinChatRoom:(NSString *)roomId successBlock:(void(^)(void))successBlock failedBlock:(void(^)(NSError *))failedBlock
{
    if (isEmptyString(roomId)) {
        if (failedBlock) {
            NSError *error = [NSError errorWithDomain:@"NETSAudience" code:NETSRequestErrorMapping userInfo:@{NSLocalizedDescriptionKey: @"观众端聊天室ID为空"}];
            failedBlock(error);
        }
        return;
    }
    
   // 检查主播是否在线
    void(^checkAuthodOnline)(NSString *) = ^(NSString *roomId) {
        [NETSChatroomService isOnlineWithRoomId:roomId completion:^(BOOL isOnline) {
            if (isOnline) {
                if (successBlock) { successBlock(); }
            } else {
                if (failedBlock) {
                    NSError *error = [NSError errorWithDomain:@"NETSAudience" code:NETSRequestErrorMapping userInfo:@{NSLocalizedDescriptionKey: @"主播已下线"}];
                    failedBlock(error);
                }
            }
        }];
    };
    
    // 加入直播间
    [NETSChatroomService enterWithRoomId:roomId userMode:NETSUserModeAudience success:^(NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me) {
        checkAuthodOnline(roomId);
    } failed:^(NSError * _Nullable error) {
        if (failedBlock) { failedBlock(error); }
    }];
}

/// 直播间关闭弹窗
- (void)_alertToExitRoomWithError:(nullable NSError *)error
{
    BOOL accountErr = NO;
    if ([error.domain isEqualToString:@"NIMLocalErrorDomain"] && error.code == 13) {
        accountErr = YES;
    }
    NSString *title = accountErr ? @"您的账号已登出" : @"直播间已关闭";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"点击确定关闭该直播间" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (accountErr) {
            [[NENavigator shared].navigationController popToRootViewControllerAnimated:YES];
        } else {
            [[NENavigator shared].navigationController popViewControllerAnimated:YES];
        }
    }];
    [alert addAction:confirm];
    [[NENavigator shared].navigationController presentViewController:alert animated:YES completion:nil];
}

/// 向左轻扫显示蒙层
- (void)_swipeShowMask:(UISwipeGestureRecognizer *)gesture
{
    NETSLog(@"向左轻扫显示蒙层");
    if (self.mask.left > kScreenWidth/2.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.mask.left = 0;
        }];
    }
}
- (void)_swipeDismissMask:(UISwipeGestureRecognizer *)gesture
{
    if (_roomStatus == NETSAudienceRoomLiveClosed || _roomStatus == NETSAudienceRoomLiveError) {
        NETSLog(@"页面故障,阻止向右轻扫隐藏蒙层");
        return;
    }
    NETSLog(@"向右轻扫隐藏蒙层");
    if (self.mask.left < kScreenWidth/2.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.mask.left = kScreenWidth;
        }];
    }
}

#pragma mark - lazy load

- (NETSAudienceMask *)mask
{
    if (!_mask) {
        _mask = [[NETSAudienceMask alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _mask.delegate = self;
    }
    return _mask;
}

- (NETSPullStreamErrorView *)networkFailureView
{
    if (!_networkFailureView) {
        _networkFailureView = [[NETSPullStreamErrorView alloc]init];
        [_networkFailureView installWithAvatar:self.roomModel.avatar nickname:self.roomModel.nickname];
        _networkFailureView.delegate = self;
        _networkFailureView.userInteractionEnabled = YES;
    }
    return _networkFailureView;
}

- (NETSLiveEndView *)liveClosedMask
{
    if (!_liveClosedMask) {
        _liveClosedMask = [[NETSLiveEndView alloc] init];
    }
    return _liveClosedMask;
}

- (NELivePlayerController *)player
{
    if (!_player) {
        _player = [[NELivePlayerController alloc] init];
        [_player setBufferStrategy:NELPTopSpeed];
        [_player setScalingMode:NELPMovieScalingModeNone];
        [_player setShouldAutoplay:YES];
        [_player setHardwareDecoder:YES];
        [_player setPauseInBackground:NO];
        [_player setPlaybackTimeout:(3 * 1000)];
        
        NELPRetryConfig *retryConfig = [[NELPRetryConfig alloc] init];
        retryConfig.count = 1;
        [_player setRetryConfig:retryConfig];
    }
    return _player;
}

@end
