//
//  NETSMoreSettingModel.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 直播中 更多设置 按钮模型
///

typedef enum : NSUInteger {
    NETSMoreSettingUnknown = 0, // 默认
    NETSMoreSettingCamera,      // 切换摄像头
    NETSMoreSettingMicro,       // 麦克风
    NETSMoreSettingEarback,     // 耳返
    NETSMoreSettingReverse,     // 反转
    NETSMoreSettingStats,       // 实时数据
    NETSMoreSettingEndLive      // 结束直播
} NETSMoreSettingType;

@interface NETSMoreSettingModel : NSObject

/// 展示标题
@property (nonatomic, copy)     NSString    *display;
/// 生效图标
@property (nonatomic, copy)     NSString    *icon;
/// 操作类型
@property (nonatomic, assign)   NETSMoreSettingType type;

/// 实例化方法
- (instancetype)initWithDisplay:(NSString *)display
                           icon:(NSString *)icon
                           type:(NETSMoreSettingType)type;

/// 展示图标名称
- (NSString *)displayIcon;

@end

///
/// 直播中 更多设置 状态按钮模型
///

@interface NETSMoreSettingStatusModel : NETSMoreSettingModel

/// 失效图标
@property (nonatomic, copy)     NSString    *disableIcon;
/// 启用状态
@property (nonatomic, assign)   BOOL        disable;

/// 实例化方法
- (instancetype)initWithDisplay:(NSString *)display
                           icon:(NSString *)icon
                           type:(NETSMoreSettingType)type
                    disableIcon:(NSString *)disableIcon
                        disable:(BOOL)disable;

@end

NS_ASSUME_NONNULL_END
