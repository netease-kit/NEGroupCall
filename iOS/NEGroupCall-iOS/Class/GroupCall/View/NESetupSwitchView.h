//
//  NESetupSwitchView.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/3/11.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NESetupSwitchView : UIView

/// 构造方法
/// @param title 文本
/// @param isOpen switch状态
- (instancetype)initWithtitle:(NSString *)title switchStatus:(BOOL)isOpen;

@property(nonatomic, strong)RACSubject *switchChangeSubject;

@end

NS_ASSUME_NONNULL_END
