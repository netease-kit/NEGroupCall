//
//  NETSWarnToast.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NETSWarnToast : UIView

/// 文字颜色
@property (nonatomic, strong)   UIColor     *textCol;
/// 标志
@property (nonatomic, strong)   UIImage     *icon;
/// toast文字
@property (nonatomic, copy)     NSString    *toast;
/// 点击触发闭包
@property (nonatomic, copy, nullable)   void(^clickBlock)(void);

@end

NS_ASSUME_NONNULL_END
