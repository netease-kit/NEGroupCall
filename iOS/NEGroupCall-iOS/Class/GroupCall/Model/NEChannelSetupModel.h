//
//  NEChannelSetupModel.h
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/24.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface NEChannelSetupModel : NSObject

/**
 获取数据模型数组
 
 @param fileName 文件名
 @return  数据模型数组
 */
+ (NSArray *)getData:(NSString *)fileName ;

+ (NEChannelSetupModel *)getTargetDataModel:(NSString *)title dataSource:(NSMutableArray *)dataSource;

///  处理分辨率设置
/// @param ratioValue 分辨率选中数值
/// @param orginArray 原数组
+ (NSArray *)handleResolutionRatio:(NSString *)ratioValue orginArray:(NSArray*)orginArray;

/// 处理帧率设置
/// @param frameRate 帧率选中数值
/// @param orginArray 原数组
+ (NSArray *)handleFrameRate:(NSString *)frameRate orginArray:(NSArray*)orginArray;

/// 处理音质设置
/// @param soundQuality 音质选中数值
/// @param orginArray 原数组
+ (NSArray *)handleSoundQuality:(NSString *)soundQuality orginArray:(NSArray*)orginArray;


//标题
@property (nonatomic, copy) NSString *title;

//内容
@property (nonatomic, copy) NSString *content;
//是否是场景
@property (nonatomic, assign) BOOL isScenario;

//内容颜色
@property (nonatomic, copy) UIColor *contentColor;
/**
 是否显示下一步操作提示logo
 */
@property (nonatomic, assign) BOOL isShowNextImg;

//是否可进行下一步点击
@property (nonatomic, assign) BOOL isNext;

// 是否有可更新版本(默认NO)
@property (nonatomic, assign) BOOL isUpdate;

// 跳转的目标控制器
@property (nonatomic, strong) NSString *pushClass;

// 执行的方法
@property (nonatomic, strong) NSString *performSelector;

/// 跳转控制器传递参数
@property (nonatomic, strong) id pushClassParams;

/// 图片名称
@property(nonatomic, copy) NSString *logoImgName;

/// 是否显示底部线条
@property(nonatomic, assign) BOOL isShowBottomLine;

/// 是否显示红点标记
@property(nonatomic, assign) BOOL isShowRedPoint;


@end

NS_ASSUME_NONNULL_END
