//
//  NETSLiveSettingActionSheet.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveSettingActionSheet.h"
#import "UIView+NTES.h"
#import "TopmostView.h"
#import "UIImage+NTES.h"
#import <NERtcSDK/NERtcSDK.h>
#import "NETSLiveConfig.h"
#import "NETSLiveSegmentedSetting.h"
#import "NETSLiveSegmentedSettingModel.h"

@interface NETSLiveSettingActionSheet () <NETSLiveSegmentedSettingDelegate>

/// 分辨率设置
@property (nonatomic, strong)   NETSLiveSegmentedSetting    *resoSetting;
/// 分割线
@property (nonatomic, strong)   UIView                      *splitLineA;
/// 帧率设置
@property (nonatomic, strong)   NETSLiveSegmentedSetting    *frameSetting;
/// 分割线
@property (nonatomic, strong)   UIView                      *splitLineB;
/// 音频质量设置
@property (nonatomic, strong)   NETSLiveSegmentedSetting    *audioSetting;

@end

@implementation NETSLiveSettingActionSheet

+ (void)show
{
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    topmostView.userInteractionEnabled = YES;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    NETSLiveSettingActionSheet *sheet = [[NETSLiveSettingActionSheet alloc] initWithFrame:frame title:@"直播设置"];
    [topmostView addSubview:sheet];
}

#pragma mark - override method

- (void)setupSubViews
{
    [self.content addSubview:self.resoSetting];
    [self.content addSubview:self.splitLineA];
    [self.content addSubview:self.frameSetting];
    [self.content addSubview:self.splitLineB];
    [self.content addSubview:self.audioSetting];
    
    [self.resoSetting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topLine.mas_bottom).offset(10);
        make.right.left.equalTo(self.content);
        make.height.mas_equalTo(56);
    }];
    [self.splitLineA mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resoSetting.mas_bottom);
        make.left.equalTo(self.content).offset(20);
        make.right.equalTo(self.content).offset(-20);
        make.height.mas_equalTo(0.5);
    }];
    [self.frameSetting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splitLineA.mas_bottom);
        make.right.left.height.equalTo(self.resoSetting);
    }];
    [self.splitLineB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.frameSetting.mas_bottom);
        make.left.equalTo(self.content).offset(20);
        make.right.equalTo(self.content).offset(-20);
        make.height.mas_equalTo(0.5);
    }];
    [self.audioSetting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splitLineB.mas_bottom);
        make.right.left.height.equalTo(self.frameSetting);
        make.bottom.equalTo(self.content).offset(kIsFullScreen ? -44 : -10);
    }];
}

- (void)resetSetting:(UIButton *)sender
{
    NETSLog(@"重置直播设置...");
    [[NETSLiveConfig shared] resetLiveConfig];
    
    NERtcVideoEncodeConfiguration *config = [NETSLiveConfig shared].videoConfig;
    int videoRes = [[NERtcEngine sharedEngine] setLocalVideoConfig:config];
    NETSLog(@"重置分辨率/帧率 %@", (videoRes == 0) ? @"成功" : @"失败");
    if (videoRes == 0) {
        self.resoSetting.selectedValue = config.maxProfile;
        self.frameSetting.selectedValue = config.frameRate;
    }
    
    NSUInteger quality = [NETSLiveConfig shared].audioQuality;
    int audioRes = [[NERtcEngine sharedEngine] setAudioProfile:kNERtcAudioProfileDefault scenario:quality];
    NETSLog(@"重置音频质量 %@", (audioRes == 0) ? @"成功" : @"失败");
    if (audioRes == 0) {
        self.audioSetting.selectedValue = quality;
    }
}

/// 设置最大分辨率(返回操作结果)
- (int)setMaxProfile:(NSInteger)maxProfile
{
    NERtcVideoEncodeConfiguration *config = [NETSLiveConfig shared].videoConfig;
    NERtcVideoProfileType oldVal = config.maxProfile;
    config.maxProfile = maxProfile;
    int res = [[NERtcEngine sharedEngine] setLocalVideoConfig:config];
    if (res == 0) {
        [NETSLiveConfig shared].videoConfig = config;
    } else {
        [NETSLiveConfig shared].videoConfig.maxProfile = oldVal;
    }
    NETSLog(@"设置分辨率: newValue-%zd, oldVal-%zd, result-%d", maxProfile, oldVal, res);
    
    return res;
}

/// 设置帧率(返回操作结果)
- (int)setFrameRate:(NSInteger)frameRate
{
    NERtcVideoEncodeConfiguration *config = [NETSLiveConfig shared].videoConfig;
    NERtcVideoFrameRate oldVal = config.frameRate;
    config.frameRate = frameRate;
    int res = [[NERtcEngine sharedEngine] setLocalVideoConfig:config];
    if (res == 0) {
        [NETSLiveConfig shared].videoConfig = config;
    } else {
        [NETSLiveConfig shared].videoConfig.frameRate = oldVal;
    }
    NETSLog(@"设置帧率: newValue-%zd, oldVal-%zd, result-%d", frameRate, oldVal, res);
    
    return res;
}

/// 设置音频质量(返回操作结果)
- (int)setAudioQuality:(NSInteger)quality
{
    NSUInteger oldVal = [NETSLiveConfig shared].audioQuality;
    int res = [[NERtcEngine sharedEngine] setAudioProfile:kNERtcAudioProfileDefault scenario:quality];
    if (res == 0) {
        [NETSLiveConfig shared].audioQuality = quality;
    } else {
        [NETSLiveConfig shared].audioQuality = oldVal;
    }
    NETSLog(@"设置音频质量: newValue-%zd, result-%d", quality, res);
    
    return res;
}

#pragma mark - NETSLiveSegmentedSettingDelegate

- (void)changedLiveSegmented:(NETSLiveSegmentedSetting *)segmented selectedIndex:(NSInteger)selectedIndex selectedItem:(nullable NETSLiveSegmentedSettingModel *)selectedItem
{
    if (segmented == self.resoSetting) {
        __unused int res = [self setMaxProfile:selectedItem.value];
    }
    else if (segmented == self.frameSetting) {
        __unused int res = [self setFrameRate:selectedItem.value];
    }
    else if (segmented == self.audioSetting) {
        __unused int res = [self setAudioQuality:selectedItem.value];
    }
}

#pragma mark - lazy load

- (NETSLiveSegmentedSetting *)resoSetting
{
    if (!_resoSetting) {
        NSArray *items = @[
            [[NETSLiveSegmentedSettingModel alloc] initWithDisplay:@"360P" value:kNERtcVideoProfileStandard],
            [[NETSLiveSegmentedSettingModel alloc] initWithDisplay:@"720P" value:kNERtcVideoProfileHD720P],
            [[NETSLiveSegmentedSettingModel alloc] initWithDisplay:@"1080P" value:kNERtcVideoProfileHD1080P]
        ];
        _resoSetting = [[NETSLiveSegmentedSetting alloc] initWithTitle:@"分辨率" items:items];
        _resoSetting.delegate = self;
        _resoSetting.selectedValue = [NETSLiveConfig shared].videoConfig.maxProfile;
    }
    return _resoSetting;
}

- (UIView *)splitLineA
{
    if (!_splitLineA) {
        _splitLineA = [[UIView alloc] init];
        _splitLineA.backgroundColor = HEXCOLOR(0xd2d2d2);
    }
    return _splitLineA;
}

- (NETSLiveSegmentedSetting *)frameSetting
{
    if (!_frameSetting) {
        NSArray *items = @[
            [[NETSLiveSegmentedSettingModel alloc] initWithDisplay:@"15" value:kNERtcVideoFrameRateFps15],
            [[NETSLiveSegmentedSettingModel alloc] initWithDisplay:@"24" value:kNERtcVideoFrameRateFps24],
            [[NETSLiveSegmentedSettingModel alloc] initWithDisplay:@"30" value:kNERtcVideoFrameRateFps30]
        ];
        _frameSetting = [[NETSLiveSegmentedSetting alloc] initWithTitle:@"帧率" items:items];
        _frameSetting.delegate = self;
        _frameSetting.selectedValue = [NETSLiveConfig shared].videoConfig.frameRate;
    }
    return _frameSetting;
}

- (UIView *)splitLineB
{
    if (!_splitLineB) {
        _splitLineB = [[UIView alloc] init];
        _splitLineB.backgroundColor = HEXCOLOR(0xd2d2d2);
    }
    return _splitLineB;
}

- (NETSLiveSegmentedSetting *)audioSetting
{
    if (!_audioSetting) {
        NSArray *items = @[
            [[NETSLiveSegmentedSettingModel alloc] initWithDisplay:@"标准" value:kNERtcAudioScenarioDefault],
            [[NETSLiveSegmentedSettingModel alloc] initWithDisplay:@"音乐" value:kNERtcAudioScenarioMusic]
        ];
        _audioSetting = [[NETSLiveSegmentedSetting alloc] initWithTitle:@"音频质量" items:items];
        _audioSetting.delegate = self;
        _audioSetting.selectedValue = [NETSLiveConfig shared].audioQuality;
    }
    return _audioSetting;
}

@end
