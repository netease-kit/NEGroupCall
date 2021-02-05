//
//  NETSPkStatusBar.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NETSLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSPassThroughHandleRewardData;

///
/// PK状态条(固定高度58, 左侧为pk邀请者, 右侧为pk被邀请者)
///

@interface NETSPkStatusBar : UIView

/**
 刷新视图
 @param leftRewardCoins     - 左总打赏数量
 @param leftRewardAvatars   - 左打赏用户头像集合
 @param rightRewardCoins    - 右总打赏数量
 @param rightRewardAvatars  - 右打赏用户头像集合
 */
- (void)refreshWithLeftRewardCoins:(int32_t)leftRewardCoins
                 leftRewardAvatars:(nullable NSArray<NSString *> *)leftRewardAvatars
                  rightRewardCoins:(int32_t)rightRewardCoins
                rightRewardAvatars:(nullable NSArray<NSString *> *)rightRewardAvatars;

/**
 开始倒计时
 @param seconds         - 倒计时秒数
 */
- (void)countdownWithSeconds:(int)seconds;

/// 停止计时器
- (void)stopCountdown;

@end

NS_ASSUME_NONNULL_END
