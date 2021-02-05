//
//  NETSLiveUtils.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NETSGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NERtcLiveStreamTaskInfo;

/**
 PK直播工具方法
 */

@interface NETSLiveUtils : NSObject

/**
 根据ID获取打赏
 @param giftId  - 打赏礼物ID
 */
+ (nullable NETSGiftModel *)getRewardWithGiftId:(NSInteger)giftId;

/**
 获取当前git信息
 */
+ (nullable NSDictionary *)gitInfo;

@end

NS_ASSUME_NONNULL_END
