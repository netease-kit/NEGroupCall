//
//  NETSGCDTimer.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/10.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///
/// GCD安全定时器类
///
@interface NETSGCDTimer : NSObject

/**
 初始化GCD安全定时器(默认block立刻执行)
 @param interval    - 定时
 @param repeats     - 是否重复执行
 @param queue       - 执行的队列
 @param block       - 定时执行闭包
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                       repeats:(BOOL)repeats
                                         queue:(dispatch_queue_t)queue
                                         block:(void (^)(void))block;

/**
 初始化GCD安全定时器
 @param interval    - 定时
 @param repeats     - 是否重复执行
 @param queue       - 执行的队列
 @param immediately - 是否立即执行
 @param block       - 定时执行闭包
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                       repeats:(BOOL)repeats
                                         queue:(dispatch_queue_t)queue
                            triggerImmediately:(BOOL)immediately
                                         block:(void (^)(void))block;

/**
 取消/暂定GCD安全定时器
 */
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
