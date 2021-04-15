//
//  NETSLiveConfig.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NERtcSDK/NERtcEngineBase.h>
#import "NETSMoreSettingModel.h"
#import "NETSGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NETSLiveConfig : NSObject

#pragma mark - 美颜相关

/// 直播视频配置
@property (nonatomic, strong)   NERtcVideoEncodeConfiguration   *videoConfig;
/// 直播音频质量
@property (nonatomic, assign)   NSUInteger  audioQuality;

#pragma mark - 混音/音效相关

/// 伴音索引(-1: 未选中 0: 选中索引0 1: 选中索引1)
@property (nonatomic, assign)   NSInteger   mixingIdx;
/// 伴音音量
@property (nonatomic, assign)   uint32_t    mixVolume;
/// 音效索引(-1: 未选中 0: 选中索引0 1: 选中索引1)
@property (nonatomic, assign)   NSInteger   effectIdx;
/// 伴音音量
@property (nonatomic, assign)   uint32_t    effectVolume;

#pragma mark - 更多设置项

/// 直播过程中 更多设置 数据项
@property (nonatomic, strong)   NSArray <NETSMoreSettingModel *>    *moreSettings;

#pragma mark - 礼物相关

/// 观众默认礼物
@property (nonatomic, strong)   NSArray <NETSGiftModel *>           *gifts;

/// 获取直播配置单例
+ (NETSLiveConfig *)shared;

/// 重置直播配置
- (void)resetLiveConfig;

/// 重置更多设置
- (void)resetMoreSetting;

/// 重置配置
- (void)resetConfig;

@end

NS_ASSUME_NONNULL_END
