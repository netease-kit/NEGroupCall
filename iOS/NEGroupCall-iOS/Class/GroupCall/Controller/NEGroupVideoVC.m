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
#import "NEStatsInfoVC.h"
#import "NEActionSheetNavigationController.h"
#import "NEChannelSetupService.h"

@interface NEGroupVideoVC ()<NEOperationViewDelegate,NERtcEngineDelegateEx,NEGroupVideoViewDelegate,NERtcEngineMediaStatsObserver>
@property(strong,nonatomic)NEOperationView *operationView;
@property(strong,nonatomic)NSMutableArray <NEGroupVideoView *>*views;
@property(assign,nonatomic)BOOL enableBeauty;
@property(strong,nonatomic)NSMutableArray <NEGroupUserModel *> *users;
//是否进入演讲者模式
@property(nonatomic, assign) BOOL isSpeakerMode;
//进入演讲者的userid
@property(nonatomic, assign) NSInteger selectUserId;

@end

@implementation NEGroupVideoVC


- (void)ne_initializeConfig {
    [self enableLocalAudio:self.isMicrophoneOpen];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.view.backgroundColor = UIColor.blackColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.operationView.hidden =  !self.operationView.hidden;
}


- (void)ne_addSubViews {
    [self addComingUserView];
    [self setUpDefaultVideoView];
    [self setupOperationView];
    [self addOritationObserver];
    [self _authCamera];
    [self.view makeToast:@"本应用为测试产品、请勿商用。单次直播最长10分钟，每个频道最多4人" duration:3 position:CSToastPositionCenter];
}


/// 初始化Rtc并加入直播间
- (void)_setupRtcAndJoinRoom {
    
    [self initRTCSDK];
    //数据
    NEGroupUserModel *user = [[NEGroupUserModel alloc] initWithUserId:self.task.avRoomUid];
    user.nickName = self.nickname;
    [self.users addObject:user];
    [self updateCanvasWithUsers:self.users];
    [self joinCurrentRoom];
}

/// 请求相机权限
- (void)_authCamera {
    
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

- (void)setupOperationView {
    [self.view addSubview:self.operationView];
    [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(296, 124));
        make.bottom.mas_equalTo(-50);
    }];
}

- (void)initRTCSDK {
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    
    NSDictionary *params = @{
        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户 用于美颜
    };
    [coreEngine setParameters:params];
    [coreEngine addEngineMediaStatsObserver:self];

    NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
    config.maxProfile = kNERtcVideoProfileHD720P;
    config.frameRate = [self getFrameRateValue];
    config.maxProfile = [self getResolutionRatioValue];
    [coreEngine setAudioProfile:[self getSoundQuality] scenario:[NEChannelSetupService sharedService].scenarioType];

    [coreEngine setLocalVideoConfig:config];
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.engineDelegate = self;
    context.appKey = self.task.nrtcAppKey;
    int res = [coreEngine setupEngineWithContext:context];
    YXAlogInfo(@"初始化音视频引擎结果, res: %d", res);
    
    [coreEngine enableLocalAudio:self.isMicrophoneOpen];
    [coreEngine enableLocalVideo:self.isCameraOpen];
}

- (void)addOritationObserver {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)removeOritationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)statusBarOrientationChange:(NSNotification *)notification {
    [self addComingUserView];
}

- (void)updateCanvasWithUsers:(NSArray *)users {
    
    if (users.count <= 0) {
        return;
    }
    
    if (self.isSpeakerMode) {
        [self updateSpeakerVideoPosition];
    }else {
        [self updateVideoPosition];//更新视图位置

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
            videoView.userId = user.userId;
            user.videoView = videoView;
        }else {
            videoView.userName = nil;
        }
    }
}

- (void)setUpDefaultVideoView{
    NEGroupVideoView * videoView = self.views.firstObject;
    [videoView updateMicroEnable:self.isMicrophoneOpen];
}

//添加进入房间用户视图
- (void)addComingUserView {
    NEGroupVideoView * videoView = [[NEGroupVideoView alloc] init];
    videoView.delegate = self;
    [self.view addSubview:videoView];
    [self.views addObject:videoView];
}

//移除离开房间用户视图
- (void)removeLeaveUserView {
    NEGroupVideoView *lastView = self.views.lastObject;
    [lastView removeFromSuperview];
    [self.views removeObject:lastView];
}

//默认视图位置更新
- (void)updateVideoPosition {
    
    for (int i = 0; i < self.views.count; i ++ ) {
        NEGroupVideoView *videoView = self.views[i];
        videoView.isEnterSpeakerMode = self.isSpeakerMode;
        if (self.users.count == 1) {
            videoView.isHiddenZoomTag = YES;
        }else {
            videoView.isHiddenZoomTag = NO;
        }
    }

    if (self.users.count == 1) {
        NEGroupVideoView *videoView = self.views[0];
        videoView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);

    }else if (self.users.count == 2){
        NEGroupVideoView *videoView = self.views[0];
        videoView.frame = CGRectMake(0, (kScreenHeight-kScreenHeight/2)/2, kScreenWidth/2, kScreenHeight/2);
        NEGroupVideoView *videoView1 = self.views[1];
        videoView1.frame = CGRectMake(videoView.right + 1, videoView.top, videoView.width, kScreenHeight/2);
        [self.view sendSubviewToBack:videoView1];
    }else if (self.users.count == 3){
        NEGroupVideoView *videoView = self.views[0];
        videoView.frame = CGRectMake(0, 0, kScreenWidth/2, kScreenHeight/2);
        NEGroupVideoView *videoView1 = self.views[1];
        videoView1.frame = CGRectMake(videoView.right + 1, videoView.top, videoView.width, kScreenHeight/2);
        NEGroupVideoView *videoView2 = self.views[2];
        [self.view sendSubviewToBack:videoView2];
        videoView2.frame = CGRectMake(kScreenWidth/4, videoView.bottom + 1, videoView.width, kScreenHeight/2);
    }else if (self.users.count == 4){
        NEGroupVideoView *videoView = self.views[0];
        videoView.frame = CGRectMake(0, 0, kScreenWidth/2, kScreenHeight/2);
        NEGroupVideoView *videoView1 = self.views[1];
        videoView1.frame = CGRectMake(videoView.right + 1, videoView.top, videoView.width, kScreenHeight/2);
        NEGroupVideoView *videoView2 = self.views[2];
        videoView2.frame = CGRectMake(0, videoView.bottom + 1, videoView.width, kScreenHeight/2);
        [self.view sendSubviewToBack:videoView2];
        NEGroupVideoView *videoView3 = self.views[3];
        videoView3.frame = CGRectMake(videoView2.right + 1, videoView.bottom+1, videoView.width, kScreenHeight/2);
        [self.view sendSubviewToBack:videoView3];
    }
}

//进入演讲者模式视图位置更新
- (void)updateSpeakerVideoPosition {
    NSUInteger index = 0 ;
    for (int i = 0; i <self.views.count; i ++) {
        NEGroupVideoView *videoItemView = self.views[i];
        if (self.selectUserId == videoItemView.userId) {//选择进入演讲者模式的视图
            videoItemView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            videoItemView.isEnterSpeakerMode = NO;
            videoItemView.isZoomSelected = YES;
            [self.view sendSubviewToBack:videoItemView];
        }else {
            videoItemView.isEnterSpeakerMode = self.isSpeakerMode;
            videoItemView.isZoomSelected = NO;
            if (self.users.count == 2) {
                videoItemView.frame = CGRectMake((kScreenWidth-100)/2, CGRectGetMinY(self.operationView.frame) -50 , 100, 100);
            }else {//users为3 4的情况
                CGFloat margin = 10.f;
                CGFloat x = (kScreenWidth - (self.users.count -1)*100 - (self.users.count - 2)*margin)/2 + (100 + margin)*index;
                videoItemView.frame = CGRectMake(x, CGRectGetMinY(self.operationView.frame) -50 , 100, 100);
                index ++;
            }
        }
    }
}

- (void)joinCurrentRoom {
    [NERtcEngine.sharedEngine joinChannelWithToken:self.task.avRoomCheckSum channelName:self.task.avRoomCName myUid:self.task.avRoomUid completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
        YXAlogError(@"joinChannel error:%@",error)
    }];
}


- (void)destory {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    //1.RTC
    [[NERtcEngine sharedEngine] leaveChannel];
    //2.移除观察者
    [self removeOritationObserver];
    [[NERtcEngine sharedEngine]removeEngineMediaStatsObserver:self];
    
    // 销毁音视频引擎
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int res = [NERtcEngine destroyEngine];
        YXAlogInfo(@"销毁音视频引擎, res: %d", res);
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
        if (error) {
            YXAlogError(@"获取昵称失败:%@",error);
        }

    }];
}

//获取分辨率
- (NERtcVideoProfileType)getResolutionRatioValue{
    
    NSString *ratioValue = [NEChannelSetupService sharedService].resolutionRatio;
    YXAlogInfo(@"设置分辨率为:%@",ratioValue.length>0?ratioValue:@"1280*720");
    if ([ratioValue isEqualToString:@"160*90"]) {
        return kNERtcVideoProfileLowest;
    }else if ([ratioValue isEqualToString:@"320*180"]) {
        return kNERtcVideoProfileLow;
    }else if ([ratioValue isEqualToString:@"640*360"]) {
        return kNERtcVideoProfileStandard;
    }else if ([ratioValue isEqualToString:@"1280*720"]) {
        return kNERtcVideoProfileHD720P;
    }else if ([ratioValue isEqualToString:@"1920*1080"]) {
        return kNERtcVideoProfileHD1080P;
    }
    return kNERtcVideoProfileHD720P;
}

//获取帧率
- (NERtcVideoFrameRate)getFrameRateValue {
    NSString *frameRate = [NEChannelSetupService sharedService].frameRate;
    YXAlogInfo(@"设置帧率为:%@",frameRate.length>0?frameRate:@"30");
    if ([frameRate isEqualToString:@"7"]) {
        return  kNERtcVideoFrameRateFps7;
    }else if ([frameRate isEqualToString:@"10"]) {
        return  kNERtcVideoFrameRateFps10;
    }else if ([frameRate isEqualToString:@"15"]) {
        return  kNERtcVideoFrameRateFps15;
    }else if ([frameRate isEqualToString:@"24"]) {
        return  kNERtcVideoFrameRateFps24;
    }else if ([frameRate isEqualToString:@"30"]) {
        return  kNERtcVideoFrameRateFps30;
    }
    return  kNERtcVideoFrameRateFps30;
}

//获取音质质量
- (NERtcAudioProfileType)getSoundQuality {
    NSInteger scenarioType = [NEChannelSetupService sharedService].scenarioType;
    NSString *quality = [NEChannelSetupService sharedService].soundQuality;
    NSString *soundQualityStr = scenarioType == kNERtcAudioScenarioSpeech ? @"清晰" : @"极致";
    YXAlogInfo(@"设置场景为:%d,音质为:%@",scenarioType,quality.length>0?quality:soundQualityStr);
    if ([quality isEqualToString:@"一般"]) {
        return kNERtcAudioProfileStandard;
    }else if ([quality isEqualToString:@"清晰"]) {
        if (scenarioType == kNERtcAudioScenarioSpeech) {
            return kNERtcAudioProfileStandardExtend;
        }else {
            return  kNERtcAudioProfileMiddleQualityStereo;
        }
    }else if ([quality isEqualToString:@"高清"]) {
        if (scenarioType == kNERtcAudioScenarioSpeech) {
            return kNERtcAudioProfileMiddleQuality;
        }else {
            return  kNERtcAudioProfileHighQuality;
        }
    }else if ([quality isEqualToString:@"极致"]) {
        return  kNERtcAudioProfileHighQualityStereo;
    }
    
    //默认选项
    if (scenarioType == kNERtcAudioScenarioSpeech) {
        return kNERtcAudioProfileStandardExtend;
    }else {
        return  kNERtcAudioProfileHighQuality;
    }
}

#pragma mark - NEGroupVideoViewDelegate

- (void)zoomButtonClickAction:(NSInteger )userId {
    
    self.selectUserId = userId;
    self.isSpeakerMode = !self.isSpeakerMode;
    if (self.isSpeakerMode) {//进入演讲者模式
        [self updateSpeakerVideoPosition];
    }else {//退出演讲者模式
        [self updateVideoPosition];
    }
}

- (void)exchangeSpeakerMode:(NSInteger)userId {
    self.selectUserId = userId;
    [self updateSpeakerVideoPosition];
}

#pragma mark - NERtcEngineMediaStatsObserver
- (void)onNetworkQuality:(NSArray<NERtcNetworkQualityStats *> *)stats {
    //自己取上行 其他用户取下行
    for (NERtcNetworkQualityStats *networkQuality in stats) {
        
        for (NEGroupVideoView *groupView in self.views) {
            if (groupView.userId == self.task.avRoomUid && networkQuality.userId == groupView.userId) {
                //自己
                groupView.signalQuality = networkQuality.txQuality;
            }else {
                groupView.signalQuality = networkQuality.rxQuality;
            }
        }
    }
}

#pragma mark - NERtcEngineDelegate
// 用户加入
- (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName {
    for (NEGroupUserModel *user in self.users) {
        if (user.userId == userID) {
            return;
        }
    }
    NEGroupUserModel *model = [[NEGroupUserModel alloc] init];
    model.userId = userID;
    [self.users addObject:model];
    [self addComingUserView];
    [self updateCanvasWithUsers:self.users];
    [self requestUserInfo:userID];
}

// 用户离开
- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID reason:(NERtcSessionLeaveReason)reason {
    NEGroupUserModel *userModel;
    for (NEGroupUserModel *user in self.users) {
        if (user.userId == userID) {
            userModel = user;
        }
    }
    [self.users removeObject:userModel];
    [self removeLeaveUserView];
    if (self.selectUserId == userID) {//演讲者模式用户，退出房间时，要退出演讲者模式
        self.isSpeakerMode = NO;
    }
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
    YXAlogError(@"NERtcEngineDidError errorCode is %d",errCode);
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

/// 显示实时数据
- (void)_showStatsInfo
{
    NEStatsInfoVC *statsVC = [[NEStatsInfoVC alloc] init];
    [[NERtcEngine sharedEngine] addEngineMediaStatsObserver:statsVC];
    NEActionSheetNavigationController *nav = [[NEActionSheetNavigationController alloc] initWithRootViewController:statsVC];
    nav.dismissOnTouchOutside = YES;
    [self presentViewController:nav animated:YES completion:nil];
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
            [self destory];
            break;
        case 3:
            [[NERtcEngine sharedEngine] switchCamera];
            break;
        default:
            break;
    }
}

- (void)didSwitchBeauty:(BOOL)on
{
    self.enableBeauty = on;
}

- (void)didSelectStatsBtn
{
    [self _showStatsInfo];
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
        NSArray *images = @[@"group_voice_on",@"group_camera_on",@"hangup",@"group_camera_switch",@"more"];
        NSArray *selectedImages = @[@"group_voice_off",@"group_camera_off",@"hangup",@"group_camera_switch_select",@"more_select"];
        _operationView = [[NEOperationView alloc] initWithImages:images selectedImages:selectedImages isOpenMicrophone:self.isMicrophoneOpen isOpenCamera:self.isCameraOpen];
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
