//
//  NEGlobalTools.m
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/15.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEGlobalTools.h"

@implementation NEGlobalTools

+ (CGFloat)getLineForRenderingHeight {
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale == 3) {
        //3倍屏幕
        return (1.0f/(scale));
    }else {
        return (1.0f/(scale));
    }
}
@end
