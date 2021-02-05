//
//  NELPGslbDetailUrlItem.h
//  NELPGslb
//
//  Created by Netease on 2019/1/3.
//  Copyright © 2019年 Netease. All rights reserved.
//  调度完成的url

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NELPGslbDetailUrlItem : NSObject

/**
 调度的url地址
 */
@property (nonatomic, copy) NSString *url;
/**
 cdn类型
 */
@property (nonatomic, copy) NSString *cdnType;
/**
 优先级（用于计算调度权重）
 */
@property (nonatomic, copy) NSString *priority;
/**
 保留字段
 */
@property (nonatomic, assign) NSInteger resolved;
/**
 开始测速的时间
 */
@property (nonatomic, assign) NSTimeInterval startConnectTime;
/**
 结束测速的时间
 */
@property (nonatomic, assign) NSTimeInterval endConnectTime;
/**
 计算的权重值（用于返回的urls排序）
 */
@property (nonatomic, assign) float weightFactor;

- (instancetype)initWithDictionary:(NSDictionary *)dicionary;

@end

NS_ASSUME_NONNULL_END
