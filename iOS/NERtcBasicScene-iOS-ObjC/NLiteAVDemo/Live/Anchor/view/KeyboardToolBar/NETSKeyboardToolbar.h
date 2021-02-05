//
//  NETSKeyboardToolbar.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/20.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NETSKeyboardToolbar;

@protocol NETSKeyboardToolbarDelegate <NSObject>

/**
 点击工具条发送文字
 @param toolBar - 工具条对象
 @param text    - 文本
 */
- (void)didToolBar:(NETSKeyboardToolbar *)toolBar sendText:(NSString *)text;

@end

@interface NETSKeyboardToolbar : UIToolbar

@property (nonatomic, strong, readonly)   UITextField *textField;
@property (nonatomic, strong, readonly)   UIButton    *sendBtn;
@property (nonatomic, weak) id<NETSKeyboardToolbarDelegate> cusDelegate;

/// 移除第一响应
- (void)resignFirstResponder;

/// 获取第一响应
- (void)becomeFirstResponder;

@end

NS_ASSUME_NONNULL_END
