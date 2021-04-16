
//  UIButton+Layout.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/3/11.
//  Copyright © 2021 Netease. All rights reserved.
//
#import <UIKit/UIKit.h>

// 定义一个枚举（包含了四种类型的button）
typedef NS_ENUM(NSUInteger, NEButtonEdgeInsetsStyle) {
    NEButtonEdgeInsetsStyleDefault = 0, // 默认
    NEButtonEdgeInsetsStyleTop, // image在上，label在下
    NEButtonEdgeInsetsStyleLeft, // image在左，label在右
    NEButtonEdgeInsetsStyleBottom, // image在下，label在上
    NEButtonEdgeInsetsStyleRight // image在右，label在左
};


@interface UIButton (Layout)


/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
- (void)layoutButtonWithEdgeInsetsStyle:(NEButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space;

- (void)layoutButtonWithEdgeInsetsStyle:(NEButtonEdgeInsetsStyle)style
imageTitleSpace:(CGFloat)space widthTolerance:(CGFloat)widthTolerance;

@end
