//
//  NETSToast.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/3.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Toast.h"

NS_ASSUME_NONNULL_BEGIN

@interface NETSToast : NSObject

/**
 展示toast信息
 */
+ (void)showToast:(NSString *)toast;

/**
 展示toast信息
 */
+ (void)showToast:(NSString *)toast pos:(id)pos;

/**
 展示loading图
 */
+ (void)showLoading;

/**
 销毁loading图
 */
+ (void)hideLoading;

@end

NS_ASSUME_NONNULL_END
