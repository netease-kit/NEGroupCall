//
//  NETSLiveConfig.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveConfig.h"

@implementation NETSLiveConfig

+ (NETSLiveConfig *)shared
{
    static NETSLiveConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NETSLiveConfig alloc] init];
        
        instance.videoConfig = [instance _defaultVideoConfig];
        instance.audioQuality = [instance _defaultAudioQuality];
        instance.mixingIdx = -1;
        instance.mixVolume = 30;
        instance.effectIdx = -1;
        instance.effectVolume = 30;
        instance.moreSettings = [instance _defaultMoreSettings];
        instance.gifts = [instance _defaultGifts];
    });
    return instance;
}

- (void)resetLiveConfig
{
    _videoConfig = [self _defaultVideoConfig];
    _audioQuality = [self _defaultAudioQuality];
}

- (void)resetMoreSetting
{
    _moreSettings = [self _defaultMoreSettings];
}

/// 默认更多设置
- (NSArray <NETSMoreSettingModel *> *)_defaultMoreSettings
{
    NETSMoreSettingStatusModel *camera = [[NETSMoreSettingStatusModel alloc] initWithDisplay:@"摄像头" icon:@"camera_ico" type:NETSMoreSettingCamera disableIcon:@"no_camera_ico" disable:NO];
    NETSMoreSettingStatusModel *micro = [[NETSMoreSettingStatusModel alloc] initWithDisplay:@"麦克风" icon:@"micro_ico" type:NETSMoreSettingMicro disableIcon:@"no_micro_ico" disable:NO];
    NETSMoreSettingStatusModel *earBack = [[NETSMoreSettingStatusModel alloc] initWithDisplay:@"耳返" icon:@"earback_ico" type:NETSMoreSettingEarback disableIcon:@"no_earback_ico" disable:YES];
    NETSMoreSettingModel *reverse = [[NETSMoreSettingModel alloc] initWithDisplay:@"反转" icon:@"switch_camera_ico" type:NETSMoreSettingReverse];
    NETSMoreSettingModel *end = [[NETSMoreSettingModel alloc] initWithDisplay:@"结束直播" icon:@"close_ico" type:NETSMoreSettingEndLive];
    return @[camera, micro, earBack, reverse, end];
}

/// 默认赠送礼物
- (NSArray <NETSGiftModel *> *)_defaultGifts
{
    NETSGiftModel *gift1 = [[NETSGiftModel alloc] initWithGiftId:1 icon:@"gift03_ico" display:@"荧光棒" price:9];
    NETSGiftModel *gift2 = [[NETSGiftModel alloc] initWithGiftId:2 icon:@"gift04_ico" display:@"安排" price:99];
    NETSGiftModel *gift3 = [[NETSGiftModel alloc] initWithGiftId:3 icon:@"gift02_ico" display:@"跑车" price:199];
    NETSGiftModel *gift4 = [[NETSGiftModel alloc] initWithGiftId:4 icon:@"gift01_ico" display:@"火箭" price:999];
    
    return @[gift1, gift2, gift3, gift4];
}

/// 默认直播 视频配置
- (NERtcVideoEncodeConfiguration *)_defaultVideoConfig
{
    NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
    config.maxProfile = kNERtcVideoProfileHD720P;
    config.frameRate = kNERtcVideoFrameRateFps30;
    return config;
}

/// 默认直播 音频质量
- (NSUInteger)_defaultAudioQuality
{
    return kNERtcAudioScenarioMusic;
}

- (void)resetConfig
{
    // 重置伴音
    self.mixingIdx = -1;
    self.mixVolume = 30;
    
    // 重置音效音量
    self.effectIdx = -1;
    self.effectVolume = 30;
    
    // 重置直播设置
    [self resetLiveConfig];
    
    // 重置更多设置
    [self resetMoreSetting];
}

@end
