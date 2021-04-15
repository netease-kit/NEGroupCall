//
//  NETSPkTimeLabel.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// PK时间显示框
///

@interface NETSPkTimeLabel : UILabel

@property (nonatomic, assign, readonly)   BOOL        isCounting;

///
/// 开始倒计时
/// @param seconds  - 倒计时秒钟(<3600)
/// @return 倒计时状态 YES-成功 NO-失败
///
- (BOOL)countdownWithSeconds:(int32_t)seconds;

///
/// 停止计时
///
- (void)stopCountdown;

@end

NS_ASSUME_NONNULL_END
