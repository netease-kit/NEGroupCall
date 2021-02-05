//
//  NELPGslbDetailResult.h
//  NELPGslb
//
//  Created by Netease on 2019/1/3.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NELPGslbDetailUrlItem.h"
#import "NELPGslbStatInfo.h"
#import "NELPGslbPlaybackTactics.h"

NS_ASSUME_NONNULL_BEGIN

@interface NELPGslbDetailResult : NSObject

//原始地址
@property (nonatomic, copy) NSString *url;

//结果有效性
@property (nonatomic, readonly, assign) BOOL valid;

//调度结果
@property (nonatomic, strong) NSMutableArray <NELPGslbDetailUrlItem *> *results;

//统计信息
@property (nonatomic, strong) NELPGslbStatInfo *statInfo;

//下发参数
@property (nonatomic, strong) NELPGslbPlaybackTactics *playbackTactics;

@end

NS_ASSUME_NONNULL_END
