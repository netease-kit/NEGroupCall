//
//  NEGroupCallVC.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEGroupVideoVC.h"
#import "NEOperationView.h"
#import "NEGroupVideoView.h"
#import "NEAccount.h"
#import <YYModel/YYModel.h>
#import <NERtcSDK/NERtcSDK.h>
#import "NETSFUManger.h"
#import "NEUserInfoTask.h"
#import "NEGroupUserModel.h"
#import <AVFoundation/AVCaptureDevice.h>
#import "NETSToast.h"

@interface NEGroupVideoVC ()<NEOperationViewDelegate,NERtcEngineDelegateEx>
@property(strong,nonatomic)NEOperationView *operationView;
@property(strong,nonatomic)NSMutableArray <NEGroupVideoView *>*views;
@property(assign,nonatomic)BOOL enableBeauty;
@property(strong,nonatomic)NSMutableArray <NEGroupUserModel *> *users;

@end

@implementation NEGroupVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self setupVideoView];
    [self setupOperationView];
    [self addOritationObserver];
    [self.view makeToast:@"本应用为测试产品、请勿商用。单次直播最长10分钟，每个频道最多4人" duration:3 position:CSToastPositionCenter];
    [self _authCamera];
}

/// 初始化Rtc并加入直播间
- (void)_setupRtcAndJoinRoom
{
    //RTCSDK
    [self setupRTCSDK];
    
    //数据
    NEGroupUserModel *user = [[NEGroupUserModel alloc] initWithUserId:self.task.avRoomUid];
    user.nickName = self.nickname;
    [self.users addObject:user];
    [self updateCanvasWithUsers:self.users];
    [self joinCurrentRoom];
}

/// 请求相机权限
- (void)_authCamera
{
    void(^quitBlock)(void) = ^(void) {
        [NETSToast showToast:@"直播需要开启相机权限"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    };
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            quitBlock();
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (!granted) {
                    quitBlock();
                } else {
                    dispatch_queue_t queue= dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), queue, ^{
                        ntes_main_async_safe(^{
                            [self _setupRtcAndJoinRoom];
                        });
                    });
                }
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized:
        {
            ntes_main_async_safe(^{
                [self _setupRtcAndJoinRoom];
            });
        }
            break;
            
        default:
            break;
    }
}

- (void)setupVideoView {
    NSInteger padding = 1;
    NSInteger numPerRow = 2.0;

    CGFloat width = (kScreenWidth - (numPerRow + 1)*padding)/numPerRow;
    CGFloat height = (kScreenHeight - (numPerRow + 1)*padding)/numPerRow;

    for (int i = 0; i < 4; i ++) {
        NSInteger row = i/numPerRow;
        NSInteger col = i%numPerRow;
        if (self.views.count > i) {
            NEGroupVideoView *videoView = self.views[i];
            videoView.frame = CGRectMake((padding + width) * col, (padding + height) * row, width, height);
        }else {
            NEGroupVideoView * videoView = [[NEGroupVideoView alloc] init];
            videoView.frame = CGRectMake((padding + width) * col, (padding + height) * row, width, height);
            [self.view addSubview:videoView];
            [self.views addObject:videoView];
        }
    }
}

- (void)setupOperationView {
    [self.view addSubview:self.operationView];
    [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(296, 60));
        make.bottom.mas_equalTo(-50);
    }];
}

- (void)setupRTCSDK {
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    
    NSDictionary *params = @{
        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户 用于美颜
    };
    [coreEngine setParameters:params];
    
    NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
    config.maxProfile = kNERtcVideoProfileHD720P;
    [coreEngine setLocalVideoConfig:config];
    
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.engineDelegate = self;
    context.appKey = self.task.nrtcAppKey;
    int res = [coreEngine setupEngineWithContext:context];
    NETSLog(@"初始化音视频引擎结果, res: %d", res);
    
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
}
- (void)addOritationObserver {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}
- (void)removeOritationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}
- (void)statusBarOrientationChange:(NSNotification *)notification {
    [self setupVideoView];
}
- (void)updateCanvasWithUsers:(NSArray *)users {
    if (users.count <= 0) {
        return;
    }
    for (int i = 0; i < self.views.count; i ++ ) {
        NEGroupVideoView *videoView = self.views[i];
        if (i < users.count) {
            NEGroupUserModel *user = [users objectAtIndex:i];
            NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
            canvas.container = videoView.videoView;
            if (user.userId == self.task.avRoomUid) {
                //自己
                [[NERtcEngine sharedEngine] setupLocalVideoCanvas:canvas];
            }else {
                [[NERtcEngine sharedEngine] setupRemoteVideoCanvas:canvas forUserID:user.userId];
            }
            videoView.userName = user.nickName;
            user.videoView = videoView;
        }else {
            videoView.userName = nil;
        }
    }
}

- (void)joinCurrentRoom
{
    [NERtcEngine.sharedEngine joinChannelWithToken:self.task.avRoomCheckSum channelName:self.task.avRoomCName myUid:self.task.avRoomUid completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
        NSLog(@"joinChannel error:%@",error);
    }];
}
- (void)hungUp {
    [self destory];
}
- (void)destory {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    //1.RTC
    [[NERtcEngine sharedEngine] leaveChannel];
    //2.移除观察者
    [self removeOritationObserver];
    
    // 销毁音视频引擎
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int res = [NERtcEngine destroyEngine];
        NETSLog(@"销毁音视频引擎, res: %d", res);
        ntes_main_async_safe(^{
            // 弹出视图
            [self dismissViewControllerAnimated:YES completion:^{
                // 通知
                if (self.delegate && [self.delegate respondsToSelector:@selector(didLeaveRoom:roomUid:)]) {
                    [self.delegate didLeaveRoom:self.task.avRoomCid roomUid:self.task.avRoomUid];
                }
            }];
        });
    });
}
- (void)requestUserInfo:(uint64_t)userID {
    NEGroupUserModel *user;
    for (NEGroupUserModel *model in self.users) {
        if (model.userId == userID) {
            user = model;
        }
    }
    NEUserInfoTask *task = [NEUserInfoTask task];
    task.req_mpRoomId = self.task.mpRoomId;
    task.req_avRoomUid = [NSString stringWithFormat:@"%llu",userID];
    [task postWithCompletion:^(NSDictionary * _Nullable data, NEUserInfoTask *task, NSError * _Nullable error) {
        user.nickName = task.nickname;
        user.videoView.userName = task.nickname;
    }];
}
#pragma mark - NERtcEngineDelegate
// 用户加入
- (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName
{
    for (NEGroupUserModel *user in self.users) {
        if (user.userId == userID) {
            return;
        }
    }
    NEGroupUserModel *model = [[NEGroupUserModel alloc] init];
    model.userId = userID;
    [self.users addObject:model];
    [self updateCanvasWithUsers:self.users];

    [self requestUserInfo:userID];
}

// 用户离开
- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID reason:(NERtcSessionLeaveReason)reason
{
    NEGroupUserModel *userModel;
    for (NEGroupUserModel *user in self.users) {
        if (user.userId == userID) {
            userModel = user;
        }
    }
    [self.users removeObject:userModel];
    [self updateCanvasWithUsers:self.users];

}

// 用户开启摄像头
- (void)onNERtcEngineUserVideoDidStartWithUserID:(uint64_t)userID videoProfile:(NERtcVideoProfileType)profile
{
    [NERtcEngine.sharedEngine subscribeRemoteVideo:YES forUserID:userID streamType:kNERtcRemoteVideoStreamTypeHigh];
}

// 用户关闭摄像头
- (void)onNERtcEngineUserVideoDidStop:(uint64_t)userID
{
    NSLog(@"对方关闭了摄像头%s",__func__);
}

// 用户开启音频
- (void)onNERtcEngineUserAudioDidStart:(uint64_t)userID {
    NSLog(@"开启音频 %lld",userID);
    for (NEGroupUserModel *user in self.users) {
        if (user.userId == userID) {
            [user.videoView updateMicroEnable:YES];
        }
    }
}

// 用户关闭麦克风
- (void)onNERtcEngineUserAudioDidStop:(uint64_t)userID {
    for (NEGroupUserModel *user in self.users) {
        if (user.userId == userID) {
            [user.videoView updateMicroEnable:NO];
        }
    }
}

- (void)onNERTCEngineLiveStreamState:(NERtcLiveStreamStateCode)state taskID:(NSString *)taskID url:(NSString *)url
{
    switch (state) {
        case kNERtcLsStatePushing:
            NSLog(@"Pushing stream for task [%@]", taskID);
            break;
        case kNERtcLsStatePushStopped:
            NSLog(@"Stream for task [%@] stopped", taskID);
            break;
        case kNERtcLsStatePushFail:
            NSLog(@"Stream for task [%@] failed", taskID);
            break;
        default:
            NSLog(@"Unknown state for task [%@]", taskID);
            break;
    }
}
// 在代理方法中对视频数据进行处理
- (void)onNERtcEngineVideoFrameCaptured:(CVPixelBufferRef)bufferRef rotation:(NERtcVideoRotationType)rotation
{
    if (self.enableBeauty) {
        [[NETSFUManger shared] renderItemsToPixelBuffer:bufferRef];
    }
}

- (void)onNERtcEngineDidError:(NERtcError)errCode {
    NSLog(@"%s:%d",__func__, errCode);
}
/**
 离开频道回调

 @param result 离开的结果
 */
- (void)onNERtcEngineDidLeaveChannelWithResult:(NERtcError)result {
    
    NSLog(@"%s:%d",__func__, result);
}

/**
 从频道断开的回调

 @param reason 断开原因
 */
- (void)onNERtcEngineDidDisconnectWithReason:(NERtcError)reason {
    
    NSString *message = @"服务器连接已断开";
    if (reason == kNERtcErrChannelBeClosed) {
        message = @"本应用为测试产品,单次通话最长10分钟";
    }else {
        message = NERtcErrorDescription(reason);
    }
    [self.view makeToast:message duration:3 position:CSToastPositionCenter];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self destory];
    });
    NSLog(@"%s:%d",__func__, reason);
}

#pragma mark - NEOperationViewDelegate
- (void)didSelectIndex:(NSInteger)index button:(UIButton *)button {
    switch (index) {
        case 0:
            [self enableLocalAudio:!button.selected];
            break;
        case 1:
            [[NERtcEngine sharedEngine] enableLocalVideo:!button.selected];
            break;
        case 2:
            [[NERtcEngine sharedEngine] switchCamera];
            break;
        case 3:
            self.enableBeauty = button.selected;
            break;
        case 4:
            [self hungUp];
            break;
        default:
            break;
    }
}
#pragma mark - NEOperationEvent
- (void)enableLocalAudio:(BOOL)enable {
    [[NERtcEngine sharedEngine] enableLocalAudio:enable];
    for (NEGroupUserModel *model in self.users) {
        if (model.userId == self.task.avRoomUid) {
            [model.videoView updateMicroEnable:enable];
        }
    }
}

#pragma mark - get
- (NEOperationView *)operationView {
    if (!_operationView) {
        NSArray *images = @[@"group_voice_on",@"group_camera_on",@"group_camera_switch",@"group_beauty",@"hangup"];
        NSArray *selectedImages = @[@"group_voice_off",@"group_camera_off",@"group_camera_switch_select",@"group_beauty_select",@"hangup"];
        _operationView = [[NEOperationView alloc] initWithImages:images selectedImages:selectedImages];
        _operationView.layer.cornerRadius = 30;
        _operationView.delegate = self;
    }
    return _operationView;
}

- (NSMutableArray <NEGroupVideoView *>*)views {
    if (!_views) {
        _views = [NSMutableArray array];
    }
    return _views;
}

- (NSMutableArray<NEGroupUserModel *> *)users {
    if (!_users) {
        _users = [NSMutableArray array];
    }
    return _users;
}

- (void)dealloc
{
    NSLog(@"%@:%s",[self class],__func__);
}
@end
