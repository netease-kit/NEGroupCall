//
//  NETSBaseActionSheet.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 自定义ActionSheet基础控件
///

@interface NETSBaseActionSheet : UIView

/// 内容区
@property (nonatomic, strong)   UIView      *content;
/// 标题控件
@property (nonatomic, strong)   UILabel     *titleLab;
/// 重制按钮
@property (nonatomic, strong)   UIButton    *resetBtn;
/// 标题分割线
@property (nonatomic, strong)   UIView      *topLine;
/// 暂存顶层视图交互
@property (nonatomic, assign)   BOOL        topUserInteractionEnabled;

///
/// 初始化视图
/// @param title - 标题
/// @param frame - 视图尺寸
/// @return ActionSheet视图
///
- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title;

///
/// 重置设置项
/// @param sender - 重置按钮
///
- (void)resetSetting:(UIButton *)sender;

///
/// 创建/布局子视图
///
- (void)setupSubViews;

///
/// 非内容区点击事件
///
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
