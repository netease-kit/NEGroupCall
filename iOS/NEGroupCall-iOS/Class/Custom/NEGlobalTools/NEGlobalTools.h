//
//  NEGlobalTools.h
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/15.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEGlobalTools : NSObject

/**
 获取适配屏幕的渲染线条高度

 @return 线条高度
 */
+ (CGFloat)getLineForRenderingHeight;
@end

NS_ASSUME_NONNULL_END
