//
//  UIButton+NTES.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/10.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "UIButton+NTES.h"

@implementation UIButton (Expand)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds = self.bounds;
    //若原热区小于44x44，则放大热区，否则保持原大小不变
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

@end
