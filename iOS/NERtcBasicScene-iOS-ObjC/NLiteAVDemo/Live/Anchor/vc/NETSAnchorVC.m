//
//  NETSAnchorVC.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/10.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSAnchorVC.h"
#import "NETSAnchorBottomPanel.h"
#import "NETSAnchorCoverSetting.h"
#import "UIButton+NTES.h"
#import "NETSWarnToast.h"
#import "NETSBeautySettingActionSheet.h"
#import "NETSFilterSettingActionSheet.h"
#import "NETSLiveSettingActionSheet.h"
#import <NERtcSDK/NERtcSDK.h>
#import "AppKey.h"
#import "NETSLiveConfig.h"
#import "NETSLiveSegmentedSettingModel.h"
#import "TopmostView.h"
#import "NETSFUManger.h"
#import "NETSAnchorTopInfoView.h"
#import "NETSAudienceNum.h"
#import "UIView+NTES.h"
#import "NETSInputToolBar.h"
#import "NETSMoreSettingActionSheet.h"
#import "NETSShowStatusActionSheet.h"
#import "NETSAudioMixingActionSheet.h"
#import "NETSLiveChatView.h"
#import "NETSLiveChatViewHandle.h"
#import "NETSPkStatusBar.h"
#import "NETSChoosePKSheet.h"
#import "NETSLiveModel.h"
#import "NETSInvitingBar.h"
#import "NETSToast.h"
#import "NETSChatroomService.h"
#import "NETSLiveAttachment.h"
#import "NETSLiveUtils.h"
#import "NENavigator.h"
#import "NETSCanvasModel.h"
#import "NETSPushStreamService.h"
#import "NETSInviteeInfoView.h"
#import "NETSPkService.h"
#import "NETSPkService+Inviter.h"
#import "NETSPkService+Invitee.h"
#import "NETSPkService+im.h"
#import "IQKeyboardManager.h"
#import "NETSGCDTimer.h"
#import <AVFoundation/AVCaptureDevice.h>
#import "NEMenuViewController.h"

#import "NETSKeyboardToolbar.h"

@interface NETSAnchorVC ()
<
    NETSAnchorBottomPanelDelegate,
    NERtcEngineDelegateEx,
    NETSInputToolBarDelegate,
    NETSMoreSettingActionSheetDelegate,
    NETSLiveChatViewHandleDelegate,
    NETSChoosePKSheetDelegate,
    NETSInvitingBarDelegate,
    NETSKeyboardToolbarDelegate,
    NETSPkServiceDelegate, NETSPkInviterDelegate, NETSPkInviteeDelegate, NETSPassThroughHandleDelegate
>

/// 绘制单人直播摄像头采集
@property (nonatomic, strong)   UIView                  *singleRender;
/// 单人直播canvas模型
@property (nonatomic, strong)   NETSCanvasModel         *singleCanvas;
/// 绘制摄像头采集
@property (nonatomic, strong)   UIView                  *localRender;
/// 本地canvas模型
@property (nonatomic, strong)   NETSCanvasModel         *localCanvas;
/// 远端视频面板
@property (nonatomic, strong)   UIView                  *remoteRender;
/// 远端canvas模型
@property (nonatomic, strong)   NETSCanvasModel         *remoteCanvas;
/// 底部面板
@property (nonatomic, strong)   NETSAnchorBottomPanel   *bottomPanel;
/// 键盘工具条
@property (nonatomic, strong)   NETSKeyboardToolbar     *toolBar;
/// 封面设置面板
@property (nonatomic, strong)   NETSAnchorCoverSetting  *settingPanel;
/// 返回按钮
@property (nonatomic, strong)   UIButton                *backBtn;
/// 切换摄像头按钮
@property (nonatomic, strong)   UIButton                *switchCameraBtn;
/// 试用提示
@property (nonatomic, strong)   NETSWarnToast           *warnToast;
/// 主播信息视图
@property (nonatomic, strong)   NETSAnchorTopInfoView   *anchorInfo;
/// 直播中 观众数量视图
@property (nonatomic, strong)   NETSAudienceNum         *audienceInfo;
/// 直播中 底部工具条
@property (nonatomic, strong)   NETSInputToolBar        *livingInputTool;
/// 邀请别人PK按钮
@property (nonatomic, strong)   UIButton                *pkBtn;
/// 聊天视图
@property (nonatomic, strong)   NETSLiveChatView        *chatView;
/// 聊天室代理
@property (nonatomic, strong)   NETSLiveChatViewHandle  *chatHandle;
/// pk状态条
@property (nonatomic, strong)   NETSPkStatusBar         *pkStatusBar;

/// pk邀请状态条
@property (nonatomic, strong)   NETSInvitingBar         *pkInvitingBar;
/// 被邀请者信息视图
@property (nonatomic, strong)   NETSInviteeInfoView     *inviteeInfo;

/// 己方加入视音频房间信号
@property (nonatomic, strong)   RACSubject      *joinedPkChannelSubject;
/// 服务端透传pk开始信号
@property (nonatomic, strong)   RACSubject      *serverStartPkSubject;

/// pk胜利图标
@property (nonatomic, strong)   UIImageView     *pkSuccessIco;
/// pk失败图标
@property (nonatomic, strong)   UIImageView     *pkFailedIco;

/// pk直播服务类
@property (nonatomic, strong)   NETSPkService   *pkService;
/// 是否接受pk邀请对话框
@property (nonatomic, strong)   UIAlertController   *pkAlert;

@end

@implementation NETSAnchorVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        _chatHandle = [[NETSLiveChatViewHandle alloc] initWithDelegate:self];
        [[NIMSDK sharedSDK].chatManager addDelegate:_chatHandle];
        [[NIMSDK sharedSDK].chatroomManager addDelegate:_chatHandle];
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:_chatHandle];
        
        _pkService = [[NETSPkService alloc] initWithDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        _joinedPkChannelSubject = [RACSubject subject];
        _serverStartPkSubject = [RACSubject subject];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = HEXCOLOR(0x1b1919);
    
    // 重置更多设置
    [[NETSLiveConfig shared] resetConfig];
    // 重置美颜配置
    [[NETSFUManger shared] resetSkinParams];
    // 重置滤镜配置
    [[NETSFUManger shared] resetFilters];
    
    [self layoutPreview];
    [self layoutRenders];
    [self bindAction];
    [self setupRTCEngine];
    
    [self _authCameraAndPrevew];
}

- (void)_authCameraAndPrevew
{
    void(^quitBlock)(void) = ^(void) {
        [NETSToast showToast:@"直播需要开启相机权限"];
        [[NENavigator shared].navigationController popViewControllerAnimated:YES];
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
                            [self startPrevew];
                        });
                    });
                }
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized:
        {
            ntes_main_async_safe(^{
                [self startPrevew];
            });
        }
            break;
            
        default:
            break;
    }
}

- (void)dealloc
{
    // 关闭屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NETSLog(@"dealloc NETSAnchorVC: %p...", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)bindAction
{
    @weakify(self);
    [RACObserve(self.pkService, liveStatus) subscribeNext:^(id  _Nullable x) {
        ntes_main_async_safe(^{
            @strongify(self);
            NSString *pkBtnIco = (self.pkService.liveStatus != NETSPkServicePkLive) ? @"pk_ico" : @"end_pk_ico";
            [self.pkBtn setImage:[UIImage imageNamed:pkBtnIco] forState:UIControlStateNormal];
        });
    }];
    
    [RACObserve(self.pkService, singleRoom) subscribeNext:^(NETSCreateLiveRoomModel*  _Nullable room) {
        @strongify(self);
        if (!room) { return; }
        [self.anchorInfo installWithAvatar:room.avatar nickname:room.nickname wealth:0];
    }];
    
    RACSignal *signal = [self.joinedPkChannelSubject zipWith:self.serverStartPkSubject];
    [signal subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        if (![tuple.first isKindOfClass:[NETSPassThroughHandlePkStartData class]]) {
            return;
        }
        NETSPassThroughHandlePkStartData *data = (NETSPassThroughHandlePkStartData *)tuple.first;
        [self _pushPkLiveStreamWithData:data];
    }];
}

- (void)startPrevew
{
    NERtcVideoCanvas *canvas = [self setupSingleCanvas];
    int setLocalCanvasRes = [[NERtcEngine sharedEngine] setupLocalVideoCanvas:canvas];
    NETSLog(@"设置本地视频画布, res: %d", setLocalCanvasRes);
    
    int previewRes = [[NERtcEngine sharedEngine] startPreview];
    NETSLog(@"开启预览, res: %d", previewRes);
    if (previewRes == 0) {
        self.pkService.liveStatus = NETSPkServicePrevew;
    }
}

/// 布局视频渲染视图
- (void)layoutRenders
{
    [self.view addSubview:self.localRender];
    [self.view addSubview:self.remoteRender];
    [self.view addSubview:self.singleRender];
    
    CGFloat anchorInfoBottom = (kIsFullScreen ? 44 : 20) + 36 + 4;
    self.localRender.frame = CGRectMake(0, anchorInfoBottom + 24, kScreenWidth / 2.0, kScreenWidth / 2.0 * 1280 / 720.0);
    self.remoteRender.frame = CGRectMake(self.localRender.right, self.localRender.top, self.localRender.width, self.localRender.height);
    self.singleRender.frame = self.view.bounds;
    
    [self.view sendSubviewToBack:self.singleRender];
    [self.view sendSubviewToBack:self.remoteRender];
    [self.view sendSubviewToBack:self.localRender];
}

/// 预览布局
- (void)layoutPreview
{
    [self.anchorInfo removeFromSuperview];
    [self.audienceInfo removeFromSuperview];
    [self.chatView removeFromSuperview];
    [self.pkBtn removeFromSuperview];
    [self.livingInputTool removeFromSuperview];
    [self.pkSuccessIco removeFromSuperview];
    [self.pkFailedIco removeFromSuperview];
    [self.inviteeInfo removeFromSuperview];
    
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.switchCameraBtn];
    [self.view addSubview:self.settingPanel];
    [self.view addSubview:self.bottomPanel];
    [self.view addSubview:self.warnToast];

    self.backBtn.frame = CGRectMake(20, (kIsFullScreen ? 44 : 20) + 8, 24, 24);
    self.switchCameraBtn.frame = CGRectMake(kScreenWidth - 20 - 24, (kIsFullScreen ? 44 : 20) + 8, 24, 24);
    self.settingPanel.frame = CGRectMake(20, (kIsFullScreen ? 88 : 64) + 20, kScreenWidth - 40, 88);
    self.bottomPanel.frame = CGRectMake(0, kScreenHeight - 128 - (kIsFullScreen ? 54 : 20), kScreenWidth, 128);
    self.warnToast.frame = CGRectMake(20, self.bottomPanel.top - 20 - 60, kScreenWidth - 40, 60);

    @weakify(self);
    self.warnToast.clickBlock = ^{
        @strongify(self);
        [self.warnToast removeFromSuperview];
    };
}

/// 单人直播布局
- (void)layoutSingleLive
{
    [self.pkStatusBar removeFromSuperview];
    [self.backBtn removeFromSuperview];
    [self.switchCameraBtn removeFromSuperview];
    [self.settingPanel removeFromSuperview];
    [self.bottomPanel removeFromSuperview];
    [self.pkSuccessIco removeFromSuperview];
    [self.pkFailedIco removeFromSuperview];
    [self.inviteeInfo removeFromSuperview];
    
    [self.view addSubview:self.anchorInfo];
    [self.view addSubview:self.audienceInfo];
    [self.view addSubview:self.chatView];
    [self.view addSubview:self.pkBtn];
    [self.view addSubview:self.livingInputTool];
    
    self.singleRender.hidden = NO;

    self.anchorInfo.frame = CGRectMake(8, (kIsFullScreen ? 44 : 20) + 4, 124, 36);
    self.audienceInfo.frame = CGRectMake(kScreenWidth - 8 - 195, self.anchorInfo.top + (36 - 28) / 2.0, 195, 28);
    CGFloat chatViewHeight = [self chatViewHeight];
    self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
    self.pkBtn.frame = CGRectMake(kScreenWidth - 60 - 8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - 60, 60, 60);
    self.livingInputTool.frame = CGRectMake(0, kScreenHeight - (kIsFullScreen ? 34 : 0) - 14 - 36, kScreenWidth, 36);
}

/// pk直播布局
- (void)layoutPkLive
{
    [self.backBtn removeFromSuperview];
    [self.switchCameraBtn removeFromSuperview];
    [self.settingPanel removeFromSuperview];
    [self.bottomPanel removeFromSuperview];
    [self.pkSuccessIco removeFromSuperview];
    [self.pkFailedIco removeFromSuperview];
    
    [self.view addSubview:self.pkStatusBar];
    [self.view addSubview:self.anchorInfo];
    [self.view addSubview:self.audienceInfo];
    [self.view addSubview:self.chatView];
    [self.view addSubview:self.pkBtn];
    [self.view addSubview:self.livingInputTool];
    [self.view addSubview:self.inviteeInfo];
    
    self.singleRender.hidden = YES;
    
    self.pkStatusBar.frame = CGRectMake(0, self.localRender.bottom, kScreenWidth, 58);
    self.anchorInfo.frame = CGRectMake(8, (kIsFullScreen ? 44 : 20) + 4, 124, 36);
    self.audienceInfo.frame = CGRectMake(kScreenWidth - 8 - 195, self.anchorInfo.top + (36 - 28) / 2.0, 195, 28);
    CGFloat chatViewHeight = [self chatViewHeight];
    self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
    self.pkBtn.frame = CGRectMake(kScreenWidth - 60 - 8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - 60, 60, 60);
    self.livingInputTool.frame = CGRectMake(0, kScreenHeight - (kIsFullScreen ? 34 : 0) - 14 - 36, kScreenWidth, 36);
    self.inviteeInfo.frame = CGRectMake(self.remoteRender.right - 8 - 82, self.remoteRender.top + 8, 82, 24);
    
    [self.pkStatusBar refreshWithLeftRewardCoins:0 leftRewardAvatars:@[] rightRewardCoins:0 rightRewardAvatars:@[]];
}

/// 初始化RTC引擎
- (void)setupRTCEngine
{
    NSAssert(![kAppKey isEqualToString:@"AppKey"], @"请设置AppKey");
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    
    // 设置直播模式
    [coreEngine setChannelProfile:kNERtcChannelProfileLiveBroadcasting];
    
    // 打开推流,回调摄像头采集数据
    NSDictionary *params = @{
        kNERtcKeyPublishSelfStreamEnabled: @YES,    // 打开推流
        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户
    };
    [coreEngine setParameters:params];
    
    // 设置视频发送配置(帧率/分辨率)
    NERtcVideoEncodeConfiguration *config = [NETSLiveConfig shared].videoConfig;
    [coreEngine setLocalVideoConfig:config];
    
    // 设置音频质量
    NSUInteger quality = [NETSLiveConfig shared].audioQuality;
    [coreEngine setAudioProfile:kNERtcAudioProfileDefault scenario:quality];
    
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.engineDelegate = self;
    context.appKey = kNertcAppkey;
    int res = [coreEngine setupEngineWithContext:context];
    NETSLog(@"初始化设置 NERtcEngine, res: %d", res);
    
    // 启用本地音/视频
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
}

- (void)clickAction:(UIButton *)sender
{
    if (sender == self.backBtn) {
        [self _closeLiveRoom];
    }
    else if (sender == self.switchCameraBtn) {
        int res = [[NERtcEngine sharedEngine] switchCamera];
        NETSLog(@"切换前后摄像头, res: %d", res);
    }
    else if (sender == self.pkBtn) {
        if (self.pkService.liveStatus == NETSPkServiceSingleLive) {
            if ([self.pkStatusBar superview]) {
                [NETSToast showToast:@"您已经再邀请中,不可再邀请"];
                return;
            }
            NETSLog(@"打开pk列表面板,开始pk");
            [NETSChoosePKSheet showWithTarget:self];
        }
        else if (self.pkService.liveStatus == NETSPkServicePkLive) {
            NETSLog(@"点击结束pk");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结束PK" message:@"PK尚未结束,强制结束会返回普通直播模式" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NETSLog(@"取消强制结束pk");
            }];
            @weakify(self);
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"立即结束" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [NETSToast showLoading];
                @strongify(self);
                [self _manualEndPk];
            }];
            [alert addAction:cancel];
            [alert addAction:confirm];
            [self presenAlert:alert];
        }
        else {
            NETSLog(@"正在pk链接中,pk按钮无响应");
        }
    }
}

/// 强制关闭pk
- (void)_manualEndPk
{
    [self.pkStatusBar stopCountdown];
    @weakify(self);
    [self.pkService endPkWithCompletionBlock:^(NSError * _Nullable error) {
        NETSLog(@"强制结束pk完成, error: %@", error);
        if (!error) {
            ntes_main_async_safe(^{
                @strongify(self);
                [NETSToast hideLoading];
                [self layoutSingleLive];
            });
        }
    }];
}

/// 关闭直播间
- (void)_closeLiveRoom
{
    // 重置service状态,避免leave channel触发代理方法
    self.pkService.liveStatus = NETSPkServiceInit;
    [NETSToast showLoading];
    @weakify(self);
    [self.pkService endLiveWithCompletionBlock:^(NSError * _Nullable error) {
        @strongify(self);
        [NETSToast hideLoading];
        [self.pkStatusBar stopCountdown];
        [[NENavigator shared].navigationController popViewControllerAnimated:YES];
        NETSLog(@"关闭直播间,退出直播间结果, error: %@", error);
    }];
}

#pragma mark - 当键盘事件

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = rect.size.height;
    CGFloat chatViewHeight = [self chatViewHeight];
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - chatViewHeight - keyboardHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
    }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    CGFloat chatViewHeight = [self chatViewHeight];
    [UIView animateWithDuration:0.1 animations:^{
        self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
    }];
}

#pragma mark - NETSAnchorBottomPanelDelegate 底部操作面板代理

- (void)clickBeautyBtn
{
    [NETSBeautySettingActionSheet show];
}

- (void)clickFilterBtn
{
    [NETSFilterSettingActionSheet show];
}

- (void)clickSettingBtn
{
    [NETSLiveSettingActionSheet show];
}

- (void)clickStartLiveBtn
{
    // 开启直播条件判断
    NSString *topic = [self.settingPanel getTopic];
    NSString *cover = [self.settingPanel getCover];
    if (isEmptyString(topic)) {
        [NETSToast showToast:@"直播间主题为空"];
        return;
    }
    if (isEmptyString(cover)) {
        [NETSToast showToast:@"直播间封面为空"];
        return;
    }
    
    [NETSToast showLoading];
    @weakify(self);
    [self.pkService startSingleLiveWithTopic:topic coverUrl:cover successBlock:^(NETSCreateLiveRoomModel *_Nonnull room, NERtcLiveStreamTaskInfo *_Nonnull task) {
        @strongify(self);
        [NETSToast hideLoading];
        self.warnToast.hidden = YES;
        self.chatHandle.roomId = room.chatRoomId;
    } failedBlock:^(NSError * _Nonnull error) {
        @strongify(self);
        [NETSToast hideLoading];
        if ([error.domain isEqualToString:@"NIMLocalErrorDomain"] && error.code == 13) {
            NSString *msg = error.userInfo[NSLocalizedDescriptionKey] ?: @"IM登录失败";
            [NETSToast showToast:msg];
            
            self.pkService.liveStatus = NETSPkServiceInit;
            [NETSToast showLoading];
            [self.pkService endLiveWithCompletionBlock:^(NSError * _Nullable error) {
                [NETSToast hideLoading];
                NEMenuViewController *vc = [[NEMenuViewController alloc] init];
                [[NENavigator shared].navigationController popToViewController:vc animated:YES];
            }];
        } else {
            NSString *msg = error.userInfo[NSLocalizedDescriptionKey] ?: @"开启直播间失败";
            [NETSToast showToast:msg];
            NETSLog(@"开启直播间失败, error: %@", error);
        }
    }];
}

#pragma mark - NETSMoreSettingActionSheetDelegate 点击更多设置代理

/// 开启/关闭 摄像头
- (void)didSelectCameraEnable:(BOOL)enable
{
    if (!enable) {
        [self.localCanvas resetCanvas];
    } else {
        [self.localCanvas setupCanvas];
    }
}

/// 关闭直播间
- (void)didSelectCloseLive
{
    [self _closeLiveRoom];
}

#pragma mark - NETSLiveChatViewHandleDelegate 聊天室代理

- (void)didShowMessages:(NSArray<NIMMessage *> *)messages
{
    [self.chatView addMessages:messages];
}

/// 进入或离开房间
- (void)didChatroomMember:(NIMChatroomNotificationMember *)member enter:(BOOL)enter sessionId:(NSString *)sessionId
{
    if (enter) {
        NETSLog(@"[demo] user %@ enter room.", member.userId);
    } else {
        NETSLog(@"[demo] user %@ leaved room.", member.userId);
    }
    
    // 是否主播离开
    NSString *chatRoomCreator = self.pkService.pkRoom.chatRoomCreator;
    if ([chatRoomCreator isEqualToString:member.userId]) {
        NETSLog(@"聊天室创建者: %@ 离开房间", member.userId);
    } else {
        // 提示非聊天室创建者 加入/离开 消息
        NIMMessage *message = [[NIMMessage alloc] init];
        message.text = [NSString stringWithFormat:@"\"%@\" %@房间", member.nick, (enter ? @"加入":@"离开")];
        message.remoteExt = @{@"type":@(1)};
        [_chatView addMessages:@[message]];
    }
    
    // 聊天室信息成员变更
    NSString *roomId = self.pkService.singleRoom.chatRoomId;
    [NETSChatroomService fetchMembersRoomId:roomId limit:10 successBlock:^(NSArray<NIMChatroomMember *> * _Nullable members) {
        NETSLog(@"members: %@", members);
        [self.audienceInfo reloadWithDatas:members];
    } failedBlock:^(NSError * _Nonnull error) {
        NETSLog(@"主播端获取IM聊天室成员失败, error: %@", error);
    }];
}

/// 房间关闭
- (void)didChatroomClosedWithRoomId:(NSString *)roomId {  }

/// 收到文本消息
- (void)didReceivedTextMessage:(NIMMessage *)message
{
    NSArray *msgs = @[message];
    [self.chatView addMessages:msgs];
}

#pragma mark - NETSInputToolBarDelegate 底部工具条代理事件

- (void)clickInputToolBarAction:(NETSInputToolBarAction)action
{
    switch (action) {
        case NETSInputToolBarInput: {
            [self.toolBar becomeFirstResponder];
        }
            break;
        case NETSInputToolBarBeauty: {
            [NETSBeautySettingActionSheet show];
        }
            break;
        case NETSInputToolBarFilter: {
            [NETSFilterSettingActionSheet show];
        }
            break;
        case NETSInputToolBarMusic: {
            [NETSAudioMixingActionSheet show];
        }
            break;
        case NETSInputToolBarMore: {
            NSArray *items = [NETSLiveConfig shared].moreSettings;
            [NETSMoreSettingActionSheet showWithTarget:self items:items];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - NETSInvitingBarDelegate 取消连麦代理

- (void)clickCancelInviting
{
    [self.pkService inviterSendCancelPkWithSuccessBlock:^{
        NETSLog(@"取消pk邀请");
    } failedBlock:^(NSError * _Nonnull error) {
        NETSLog(@"取消pk邀请失败, error: %@", error);
    }];
}

#pragma mark - NETSChoosePKSheetDelegate 选择主播PK代理

- (void)choosePkOnSheet:(NETSChoosePKSheet *)sheet withRoom:(NETSLiveRoomModel *)room
{
    [sheet dismiss];
    
    @weakify(self);
    void (^successBlock)(NETSCreateLiveRoomModel * _Nonnull, NIMSignalingChannelDetailedInfo * _Nonnull) = ^(NETSCreateLiveRoomModel *pkRoom, NIMSignalingChannelDetailedInfo * _Nonnull info) {
        @strongify(self);
        NSString *title = [NSString stringWithFormat:@"邀请\"%@\"PK连线中...", room.nickname];
        self.pkInvitingBar = [NETSInvitingBar showInvitingWithTarget:self title:title];
    };
    
    void (^failedBlock)(NSError * _Nullable) = ^(NSError * _Nullable error) {
        NSString *msg = error.userInfo[NSLocalizedDescriptionKey] ?: @"邀请PK失败";
        [NETSToast showToast:msg];
    };
    
    NSString *msg = [NSString stringWithFormat:@"确定邀请\"%@\"进行PK?", room.nickname];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"邀请PK" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NETSLog(@"邀请者取消pk邀请...");
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        NETSLog(@"邀请者确定邀请%@,进行pk...", room.nickname);
        [self.pkService inviterSendPkInviteWithInviteeRoom:room successBlock:successBlock failedBlock:failedBlock];
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self presenAlert:alert];
}

#pragma mark - NERtcEngineDelegateEx G2音视频

- (void)onNERtcEngineVideoFrameCaptured:(CVPixelBufferRef)bufferRef rotation:(NERtcVideoRotationType)rotation
{
    [[NETSFUManger shared] renderItemsToPixelBuffer:bufferRef];
}

- (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName
{
    NERtcVideoCanvas *canvas = [self setupRemoteCanvas];
    [NERtcEngine.sharedEngine setupRemoteVideoCanvas:canvas forUserID:userID];
}

- (void)onNERtcEngineUserVideoDidStartWithUserID:(uint64_t)userID videoProfile:(NERtcVideoProfileType)profile
{
    _remoteCanvas.subscribedVideo = YES;
    [NERtcEngine.sharedEngine subscribeRemoteVideo:YES forUserID:userID streamType:kNERtcRemoteVideoStreamTypeHigh];
}

- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID reason:(NERtcSessionLeaveReason)reason
{
    // 如果远端的人离开了，重置远端模型和UI
    if (userID == _remoteCanvas.uid) {
        [_remoteCanvas resetCanvas];
        _remoteCanvas = nil;
    }
}

/// 离开channel
- (void)onNERtcEngineDidLeaveChannelWithResult:(NERtcError)result
{
    if (result != kNERtcNoError) {
        NETSLog(@"离开单人channel失败, error: %d", result);
        return;
    }
    
    @weakify(self);
    [self.pkService transformRoomWithSuccessBlock:^(NETSPkServiceStatus status, int64_t uid) {
        @strongify(self);
        NETSLog(@"转换直播间模式: %zd", status);
        if (status == NETSPkServicePkLive) {
            NERtcVideoCanvas *canvas = [self setupLocalCanvas];
            [NERtcEngine.sharedEngine setupLocalVideoCanvas:canvas];

            [self.serverStartPkSubject sendNext:@""];
        } else {
            NERtcVideoCanvas *canvas = [self setupSingleCanvas];
            [NERtcEngine.sharedEngine setupLocalVideoCanvas:canvas];
        }
    } failedBlock:^(NSError * _Nonnull error) {
        NETSLog(@"单人直播间/pk直播间 转换失败, error: %@", error);
    }];
}

- (void)onNERtcEngineDidDisconnectWithReason:(NERtcError)reason
{
    [NETSToast showToast:@"网络断开"];
    [self _closeLiveRoom];
}

/// 直播推流状态回调
- (void)onNERTCEngineLiveStreamState:(NERtcLiveStreamStateCode)state taskID:(NSString *)taskID url:(NSString *)url
{
    NETSLog(@"直播推流状态回调, state: %ld, taskId: %@, url: %@", state, taskID, url);
    if (state == kNERtcLsStatePushFail) {
        [NETSPushStreamService removeStreamTask:taskID successBlock:^{
            [NETSPushStreamService addStreamTask:self.pkService.streamTask successBlock:^{
                NETSLog(@"重新推流成功");
            } failedBlock:^(NSError * _Nonnull error, NSString *taskID) {
                NETSLog(@"重新推流失败, taskID:%@, error: %@", taskID, error);
            }];
        } failedBlock:^(NSError * _Nonnull error) {
            NETSLog(@"推流失败, 移除原推流ID: %@, 失败, error: %@", taskID, error);
            if (error) {
                [self _closeLiveRoom];
            }
        }];
    }
}

/// 点击屏幕收起键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.toolBar resignFirstResponder];
    [self.livingInputTool resignFirstResponder];
}

#pragma mark - NETSKeyboardToolbarDelegate 键盘顶部工具条代理

- (void)didToolBar:(NETSKeyboardToolbar *)toolBar sendText:(NSString *)text
{
    if (isEmptyString(text)) {
        [NETSToast showToast:@"所发消息为空"];
        return;
    }
    
    [self.livingInputTool resignFirstResponder];
    NSError *err = nil;
    [self.pkService sendMessageWithText:text errorPtr:&err];
    NETSLog(@"主播端 发送文本消息, error: %@", err);
}

/// pk推流
- (void)_pushPkLiveStreamWithData:(NETSPassThroughHandlePkStartData *)data
{
    NETSLog(@"开始推流...");
    NSString *logPtr = (self.pkService.liveRole == NETSPkServiceInviter) ? @"邀请者" : @"被邀请者";
    
    @weakify(self);
    [self.pkService pushPkStreamWithData:data successBlock:^{
        NETSLog(@"%@添加推流任务成功", logPtr);
    } failedBlock:^(NSError * _Nonnull error, NSString * _Nullable taskID) {
        @strongify(self);
        NETSLog(@"%@添加推流任务失败, error: %@, taskID: %@", logPtr, error, taskID);
        if (error) {
            [self _closeLiveRoom];
        }
    }];
}

#pragma mark - private method

- (void)presenAlert:(UIAlertController *)alert
{
    // 消除顶层视图
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    for (UIView *subview in topmostView.subviews) {
        [subview removeFromSuperview];
    }
    topmostView.userInteractionEnabled = NO;
    
    // 弹出alert
    if (self.pkAlert) {
        [self.pkAlert dismissViewControllerAnimated:NO completion:nil];
        self.pkAlert = nil;
    }
    [[NENavigator shared].navigationController presentViewController:alert animated:YES completion:nil];
    self.pkAlert = alert;
}

#pragma mark - lazy load

- (UIView *)singleRender
{
    if (!_singleRender) {
        _singleRender = [[UIView alloc] init];
    }
    return _singleRender;
}

- (UIView *)localRender
{
    if (!_localRender) {
        _localRender = [[UIView alloc] init];
    }
    return _localRender;
}

- (UIView *)remoteRender
{
    if (!_remoteRender) {
        _remoteRender = [[UIView alloc] init];
    }
    return _remoteRender;
}

- (NETSAnchorBottomPanel *)bottomPanel
{
    if (!_bottomPanel) {
        _bottomPanel = [[NETSAnchorBottomPanel alloc] init];
        _bottomPanel.delegate = self;
    }
    return _bottomPanel;
}

- (NETSKeyboardToolbar *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[NETSKeyboardToolbar alloc] init];
        _toolBar.cusDelegate = self;
    }
    return _toolBar;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"back_ico"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)switchCameraBtn
{
    if (!_switchCameraBtn) {
        _switchCameraBtn = [[UIButton alloc] init];
        UIImage *img = [[UIImage imageNamed:@"switch_camera_ico"] sd_tintedImageWithColor:[UIColor whiteColor]];
        [_switchCameraBtn setImage:img forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

- (NETSAnchorCoverSetting *)settingPanel
{
    if (!_settingPanel) {
        _settingPanel = [[NETSAnchorCoverSetting alloc] init];
    }
    return _settingPanel;
}

- (NETSWarnToast *)warnToast
{
    if (!_warnToast) {
        _warnToast = [[NETSWarnToast alloc] init];
        _warnToast.toast = @"本应用为测试产品、请勿商用。单次直播最长10分钟，每个频道最多10人";
    }
    return _warnToast;
}

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

- (NETSInputToolBar *)livingInputTool
{
    if (!_livingInputTool) {
        _livingInputTool = [[NETSInputToolBar alloc] init];
        _livingInputTool.delegate = self;
        _livingInputTool.textField.inputAccessoryView = self.toolBar;
    }
    return _livingInputTool;
}

- (UIButton *)pkBtn
{
    if (!_pkBtn) {
        _pkBtn = [[UIButton alloc] init];
        [_pkBtn setImage:[UIImage imageNamed:@"pk_ico"] forState:UIControlStateNormal];
        [_pkBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pkBtn;
}

- (NETSLiveChatView *)chatView
{
    if (!_chatView) {
        CGRect frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - 204, kScreenWidth - 16 - 60 - 20, 204);
        _chatView = [[NETSLiveChatView alloc] initWithFrame:frame];
    }
    return _chatView;
}

- (CGFloat)chatViewHeight
{
    if (kScreenHeight <= 568) {
        return 100;
    } else if (kScreenHeight <= 736) {
        return 130;
    }
    return 204;
}

- (NETSPkStatusBar *)pkStatusBar
{
    if (!_pkStatusBar) {
        _pkStatusBar = [[NETSPkStatusBar alloc] init];
    }
    return _pkStatusBar;
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

- (NETSInviteeInfoView *)inviteeInfo
{
    if (!_inviteeInfo) {
        _inviteeInfo = [[NETSInviteeInfoView alloc] init];
    }
    return _inviteeInfo;
}

/// 建立单人直播canvas模型
- (NERtcVideoCanvas *)setupSingleCanvas
{
    if (!_singleCanvas) {
        _singleCanvas = [[NETSCanvasModel alloc] init];
        _singleCanvas.renderContainer = self.singleRender;
    }
    [_singleCanvas resetCanvas];
    return [_singleCanvas setupCanvas];
}

/// 建立本地canvas模型
- (NERtcVideoCanvas *)setupLocalCanvas
{
    if (!_localCanvas) {
        _localCanvas = [[NETSCanvasModel alloc] init];
        _localCanvas.renderContainer = self.localRender;
    }
    [_localCanvas resetCanvas];
    return [_localCanvas setupCanvas];
}

/// 建立远端canvas模型
- (NERtcVideoCanvas *)setupRemoteCanvas
{
    if (!_remoteCanvas) {
        _remoteCanvas = [[NETSCanvasModel alloc] init];
        _remoteCanvas.renderContainer = self.remoteRender;
    }
    [_remoteCanvas resetCanvas];
    return [_remoteCanvas setupCanvas];
}

#pragma mark - NETSPassThroughHandleDelegate 服务端透传信息代理

/// 开始pk直播
- (void)receivePassThrourhPkStartData:(NETSPassThroughHandlePkStartData *)data
{
    [self.joinedPkChannelSubject sendNext:data];
    
    // pk布局
    ntes_main_async_safe(^{
        [NETSToast hideLoading];
        [self layoutPkLive];
    });
    
    // 开始pk倒计时
    int32_t start = kPkLiveTotalTime - (int32_t)((data.currentTime - data.pkStartTime) / 1000);
    [self.pkStatusBar countdownWithSeconds:start];
    [self.pkStatusBar refreshWithLeftRewardCoins:0 leftRewardAvatars:@[] rightRewardCoins:0 rightRewardAvatars:@[]];
    
    // 加载远端pk者信息
    NETSLog(@"准备绘制远端主播信息...");
    if (self.pkService.liveRole == NETSPkServiceInviter) {
        NETSLog(@"当前主播为pk邀请方,远端主播为pk被邀请方, inviteeAvatar: %@, inviteeNickname: %@", data.inviteeAvatar, data.inviteeNickname);
        [self.inviteeInfo reloadAvatar:data.inviteeAvatar nickname:data.inviteeNickname];
    }
    else if (self.pkService.liveRole == NETSPkServiceInvitee) {
        NETSLog(@"当前主播为pk被邀请方,远端主播为pk邀请方, inviterAvatar: %@, inviterNickname: %@", data.inviterAvatar, data.inviterNickname);
        [self.inviteeInfo reloadAvatar:data.inviterAvatar nickname:data.inviterNickname];
    }
}

/// pk惩罚(惩罚阶段)
- (void)receivePassThrourhPunishStartData:(NETSPassThroughHandlePunishData *)data
{
    // 开始惩罚倒计时
    int32_t seconds = kPkLivePunishTotalTime - (int32_t)((data.currentTime - data.pkPulishmentTime) / 1000);
    [self.pkStatusBar countdownWithSeconds:seconds];
}

/// 用户打赏
- (void)receivePassThrourhRewardData:(NETSPassThroughHandleRewardData *)data
                           rewardMsg:(NIMMessage *)rewardMsg
{
    // 如果打赏的是当前主播,向聊天室发送打赏消息
    if ([data.fromUserAvRoomUid isEqualToString:self.pkService.singleRoom.avRoomUid]) {
        [self.chatView addMessages:@[rewardMsg]];
    }
    
    // pk状态,更新pk状态栏
    if (self.pkService.liveStatus == NETSPkServicePkLive) {
        BOOL isInviter = (self.pkService.liveRole == NETSPkServiceInviter);
        int32_t leftReward = isInviter ? data.inviterRewardPKCoinTotal : data.inviteeRewardPKCoinTotal;
        NSArray *leftAvatars = isInviter ? data.rewardAvatars : data.inviteeRewardAvatars;
        int32_t rightReward = isInviter ? data.inviteeRewardPKCoinTotal : data.inviterRewardPKCoinTotal;
        NSArray *rightAvatars = isInviter ? data.inviteeRewardAvatars : data.rewardAvatars;
        [self.pkStatusBar refreshWithLeftRewardCoins:leftReward leftRewardAvatars:leftAvatars rightRewardCoins:rightReward rightRewardAvatars:rightAvatars];
    }
    
    // 更新用户信息栏(云币值)
    int32_t coins = data.rewardCoinTotal;
    if (self.pkService.liveRole == NETSPkServiceInvitee) {
        coins = data.inviteeRewardCoinTotal;
    }
    [self.anchorInfo updateCoins:coins];
}

/// pk结束
- (void)receivePassThrourhPkEndData:(NETSPassThroughHandlePkEndData *)data
{
    // 停止pk计时
    [self.pkStatusBar stopCountdown];
    
    // 布局单人直播
    ntes_main_async_safe(^{
        [NETSToast hideLoading];
        [self layoutSingleLive];
    });
    
    // 若是自动结束,不提示
    if (isEmptyString(data.closedNickname)) {
        return;
    }
    
    // 若是当前用户取消,不提示
    NSString *nickname = [NEAccount shared].userModel.nickname;
    if ([data.closedNickname isEqualToString:nickname]) {
        return;
    }
    NSString *msg = [NSString stringWithFormat:@"%@结束PK", data.closedNickname];
    [NETSToast showToast:msg];
    
    if (self.pkAlert) {
        [self.pkAlert dismissViewControllerAnimated:YES completion:nil];
    }
}

/// 开始直播
- (void)receivePassThrourhLiveStartData:(NETSPassThroughHandleStartLiveData *)data
{
    // 服务端透传开始直播消息, 保持屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    // 单人直播布局
    ntes_main_async_safe(^{
        [NETSToast hideLoading];
        [self layoutSingleLive];
    });
}

#pragma mark - NETSPkServiceDelegate pk服务类代理

/// 直播状态变更
- (void)didPkServiceChangedStatus:(NETSPkServiceStatus)status
{
    NETSLog(@"主播端 直播状态变更, status: %lu", (unsigned long)status);
}

/// 获取到pk结果 代理方法
- (void)didPkServiceFetchedPkRestltWithError:(NSError * _Nullable)error
                          isCurrentAnchorWin:(BOOL)isCurrentAnchorWin
{
    if (error) {
        NETSLog(@"获取pk结果失败, error: %@", error);
        return;
    }
    
    CGRect leftIcoFrame = CGRectMake((self.localRender.width - 120) * 0.5, self.localRender.bottom - 120, 120, 120);
    CGRect rightIcoFrame = CGRectMake(self.remoteRender.left + (self.remoteRender.width - 120) * 0.5, self.remoteRender.bottom - 120, 120, 120);
    if (isCurrentAnchorWin) {
        self.pkSuccessIco.frame = leftIcoFrame;
        self.pkFailedIco.frame = rightIcoFrame;
    } else {
        self.pkSuccessIco.frame = rightIcoFrame;
        self.pkFailedIco.frame = leftIcoFrame;
    }
    [self.view addSubview:self.pkSuccessIco];
    [self.view addSubview:self.pkFailedIco];
}

/// PK链接操作超时
- (void)didPkServiceTimeoutForRole:(NETSPkServiceRole)role
{
    if (role == NETSPkServiceInviter) {
        NETSLog(@"邀请者 PK链接超时...");
    }
    else if (role == NETSPkServiceInvitee) {
        NETSLog(@"被邀请者 PK链接超时...");
    }
    ntes_main_async_safe(^{
        [NETSToast hideLoading];
        [NETSToast showToast:@"PK链接超时,已自动取消"];
        if ([self.pkInvitingBar superview]) {
            [self.pkInvitingBar dismiss];
        }
        if (self.pkAlert) {
            [self.pkAlert dismissViewControllerAnimated:NO completion:nil];
            self.pkAlert = nil;
        }
    });
}

#pragma mark - NETSPkInviterDelegate 邀请者代理

/// 邀请者 收到 被邀请者发出的 pk同步信息
- (void)inviterReceivedPkStatusSyncFromInviteeImAccId:(NSString *)inviteeImAccId
{
    
}

/// 邀请者 收到 被邀请者发出的 拒绝pk信息
- (void)inviterReceivedPkRejectFromInviteeImAccId:(NSString *)inviteeImAccId
                                       rejectType:(NETSPkRejectedType)rejectType
{
    NETSLog(@"被邀请方拒绝邀请方pk邀请");
    [self.pkInvitingBar dismiss];
    NSString *msg = @"对方已拒绝你的PK邀请";
    if (rejectType == NETSPkRejectedForBusyInvitee) {
        msg = @"对方正在PK中,请稍后...";
    }
    [NETSToast showToast:msg];
}

/// 邀请方 收到 被邀请者发出的 接受PK邀请 信令
- (void)inviterReceivedPkAcceptFromInviteeImAccId:(NSString *)inviteeImAccId
{
    [self.pkInvitingBar dismiss];
    [NETSToast showLoading];
}

#pragma mark - NETSPkInviteeDelegate 被邀请者代理

/// 被邀请者 接受 邀请者 邀请
- (void)inviteeReceivedPkInviteByInviter:(NSString *)inviterNickname
                          inviterImAccId:(NSString *)inviterImAccId
                               pkLiveCid:(NSString *)pkLiveCid
{
    @weakify(self);
    void (^cancelBlock)(NSString * _Nonnull, NSString * _Nonnull) = ^(NSString *inviterNickname, NSString *pkLiveCid) {
        @strongify(self);
        NETSLog(@"拒绝PK邀请, from: %@, pkLiveCid: %@", inviterNickname, pkLiveCid);
        [self.pkService inviteeSendRejectPkWithSuccessBlock:^{
            NETSLog(@"被邀请者发送拒绝pk邀请信令成功");
        } failedBlock:^(NSError * _Nonnull error) {
            NETSLog(@"被邀请者发送拒绝pk邀请信令失败, error: %@", error);
        }];
    };
    
    void (^confirmBlock)(NSString * _Nonnull, NSString * _Nonnull) = ^(NSString *inviterNickname, NSString *pkLiveCid) {
        @strongify(self);
        NETSLog(@"接受PK邀请, from: %@, pkLiveCid: %@", inviterNickname, pkLiveCid);
        [NETSToast showLoading];
        [self.pkService inviteeSendAcceptPkWithLiveCid:pkLiveCid successBlock:^ {
//            [NETSToast hideLoading];
            int res = [[NERtcEngine sharedEngine] leaveChannel];
            NETSLog(@"被邀请者离开单人直播间channel, res: %d", res);
        } failedBlock:^(NSError * _Nonnull error) {
            [NETSToast hideLoading];
            NETSLog(@"被邀请者请求加入pk直播间失败, error: %@", error);
        }];
    };
    
    NSString *msg = [NSString stringWithFormat:@"\"%@\"邀请你进行PK,是否接受?", inviterNickname];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"邀请PK" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelBlock) { cancelBlock(inviterNickname, pkLiveCid); }
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (confirmBlock) { confirmBlock(inviterNickname, pkLiveCid); }
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self presenAlert:alert];
}

/// 被邀请方 收到 邀请方 取消PK邀请 信令
- (void)inviteeReceivedCancelPkInviteResponse:(NIMSignalingCancelInviteNotifyInfo *)response
{
    [NETSToast showToast:@"对方已取消PK邀请"];
    if (self.pkAlert) {
        [self.pkAlert dismissViewControllerAnimated:YES completion:nil];
        self.pkAlert = nil;
    }
}

@end
