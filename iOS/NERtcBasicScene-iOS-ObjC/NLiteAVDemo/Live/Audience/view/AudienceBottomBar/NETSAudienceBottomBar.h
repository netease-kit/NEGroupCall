//
//  NETSAudienceBottomBar.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 客户端底部工具条
///

@protocol NETSAudienceBottomBarDelegate <NSObject>

- (void)clickTextLabel:(UILabel *)label;
- (void)clickGiftBtn;
- (void)clickCloseBtn;

@end

@interface NETSAudienceBottomBar : UIView

@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, weak) id<NETSAudienceBottomBarDelegate> delegate;

/// 取消第一响应
- (void)resignFirstResponder;

@end

NS_ASSUME_NONNULL_END
