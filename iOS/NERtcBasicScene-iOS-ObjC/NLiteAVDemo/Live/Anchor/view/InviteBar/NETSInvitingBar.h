//
//  NETSInvitingBar.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 正在邀请 提示框
///

@protocol NETSInvitingBarDelegate <NSObject>

/// 取消邀请
- (void)clickCancelInviting;

@end

@interface NETSInvitingBar : UIView

+ (NETSInvitingBar *)showInvitingWithTarget:(id)target title:(NSString *)title;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
