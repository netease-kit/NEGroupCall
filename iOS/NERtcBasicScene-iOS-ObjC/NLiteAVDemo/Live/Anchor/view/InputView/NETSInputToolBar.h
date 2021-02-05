//
//  NETSInputToolBar.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 直播过程 底部工具条
/// 固定高度 36
///

typedef enum : NSUInteger {
    NETSInputToolBarUnknown = 0,
    NETSInputToolBarInput,
    NETSInputToolBarBeauty,
    NETSInputToolBarFilter,
    NETSInputToolBarMusic,
    NETSInputToolBarMore
} NETSInputToolBarAction;

@protocol NETSInputToolBarDelegate <NSObject>

///
/// 触发工具条动作
/// @param action   - 动作事件
///
- (void)clickInputToolBarAction:(NETSInputToolBarAction)action;

@end

@interface NETSInputToolBar : UIView

@property (nonatomic, strong, readonly)   UITextField     *textField;
@property (nonatomic, weak) id<NETSInputToolBarDelegate>    delegate;

/// 取消第一响应
- (void)resignFirstResponder;

@end

NS_ASSUME_NONNULL_END
