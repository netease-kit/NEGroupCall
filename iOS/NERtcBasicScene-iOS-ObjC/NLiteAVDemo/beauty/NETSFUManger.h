//
//  NETSFUManger.h
//  NLiteAVDemo
//
//  Created by Think on 2020/11/17.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "NETSBeautyParam.h"

NS_ASSUME_NONNULL_BEGIN

///
/// items 保存加载到Nama中bundle的操作句柄集
/// 注意：道具句柄数组位置可以调整，道具渲染顺序更具数组顺序渲染
///
typedef NS_ENUM(NSUInteger, NETSFUNamaHandleType) {
    NETSFUNamaHandleTypeBeauty = 0,   /* items[0] ------ 放置 美颜道具句柄 */
    NETSFUNamaHandleTotal = 13,
};

typedef NS_OPTIONS(NSUInteger, NETSFUBeautyModuleType) {
    FUBeautyModuleTypeSkin = 1 << 0,
    FUBeautyModuleTypeShape = 1 << 1,
};

@interface NETSFUManger : NSObject

/// 滤镜参数
@property (nonatomic, strong, readonly) NSArray<NETSBeautyParam *> *filters;
/// 选中的滤镜
@property (nonatomic, strong) NETSBeautyParam   *seletedFliter;
/// 美肤参数
@property (nonatomic, strong, readonly) NSArray<NETSBeautyParam *> *skinParams;

/**
 获取美颜工具实例
 */
+ (NETSFUManger *)shared;

/**
 加载道具
 */
- (void)loadFilter;

/**
 设置美颜参数
 @param type        - 参数类型
 @param paramName   - 参数名称
 @param value       - 参数值
 */
- (void)setParamItemAboutType:(NETSFUNamaHandleType)type
                         name:(NSString *)paramName
                        value:(float)value;

/**
 设置美颜参数
 @param param   - 美颜参数
 */
- (void)setBeautyParam:(NETSBeautyParam *)param;

/**
 重置美颜
 */
- (void)resetSkinParams;

/**
 设置滤镜
 @param param   - 滤镜参数
 */
- (void)setFilterParam:(NETSBeautyParam *)param;

/**
 重置滤镜
 */
- (void)resetFilters;

/**
 设置方向
 @param mode    - 方向: 0 人脸朝上, 1 人脸朝右, 2 人脸朝下, 3,人脸朝左, 逆时针
 */
- (void)setDefaultRotationMode:(int)mode;

/**
 将道具绘制到pixelBuffer
 @param pixelBuffer - 视频数据
 */
- (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
