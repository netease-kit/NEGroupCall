//
//  NEBaseModelProtocol.h
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/15.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NEBaseModelProtocol <NSObject>

@optional

/**
 初始化配置方法
 */
- (void)fb_initialize;

/**
 数据解析

 @param data 源数据
 */
- (void)dataParsing:(id)data;

@end

NS_ASSUME_NONNULL_END
