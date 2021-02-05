//
//  NETSGiftAnimationView.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/21.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 打赏展示礼物动画视图
 */
@interface NETSGiftAnimationView : UIView

/**
 添加动画
 @param gift    - 动画资源名
 */
- (void)addGift:(NSString *)gift;

@end

NS_ASSUME_NONNULL_END
