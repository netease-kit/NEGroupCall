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
/// 美肤参数
@property (nonatomic, strong, readonly) NSArray<NETSBeautyParam *> *skinParams;

/// 获取美颜工具实例
+ (NETSFUManger *)shared;

/// 加载道具
- (void)loadFilter;

/// 默认美颜参数
- (void)setBeautyDefaultParameters:(NETSFUBeautyModuleType)type;

///
/// 设置美颜参数
///
- (void)setParamItemAboutType:(NETSFUNamaHandleType)type
                         name:(NSString *)paramName
                        value:(float)value;

/// 将道具绘制到pixelBuffer
- (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
