//
//  NETSBeautyParam.h
//  NLiteAVDemo
//
//  Created by Think on 2020/11/17.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NETSBeautyParam : NSObject

/// 展示标题
@property (nonatomic,copy)NSString *mTitle;
/// 标志字串
@property (nonatomic,copy)NSString *mParam;

/// 设定值
@property (nonatomic, assign)   float   mValue;
/// 可用最小值
@property (nonatomic, assign)   float   minVal;
/// 可用最大值
@property (nonatomic, assign)   float   maxVal;

@property (nonatomic,copy)NSString *mImageStr;

/// 默认值用于，设置默认和恢复
@property (nonatomic,assign)float defaultValue;

@end

NS_ASSUME_NONNULL_END
