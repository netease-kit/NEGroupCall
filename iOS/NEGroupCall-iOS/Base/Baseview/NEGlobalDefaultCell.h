//
//  NEGlobalDefaultCell.h
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/15.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEBaseTabViewCell.h"

typedef void(^SwitchBlock)(BOOL isOpen);

@interface NEGlobalDefaultCell : NEBaseTabViewCell

/**
 获取cell
 
 @param tableView 表格视图对象
 @param style cell类型
 @return cell视图对账
 */
+ (instancetype)settingCellForTableView:(UITableView *)tableView cellStyle: (UITableViewCellStyle)style;

/// 图标
@property(nonatomic, copy) NSString *logoImgName;

/// 标题
@property(nonatomic, copy) NSString *title;

/// 标题字体大小
@property(nonatomic, strong) UIFont *titleFont;

/// 副标题
@property(nonatomic, copy) NSString *subTitle;

/**
 是否显示顶部分割线(默认隐藏)
 */
@property (nonatomic, assign, getter=isShowTopDividerView) BOOL showTopDividerView;
/**
 是否显示底部分割线(默认显示)
 */
@property (nonatomic, assign) BOOL showBottomDividerView;
/**
 底部分割线左边间隔(默认0)
 */
@property (nonatomic, assign) CGFloat BottomDividerViewLeftInterval;
/**
 底部分割线右边间隔(默认0)
 */
@property (nonatomic, assign) CGFloat BottomDividerViewRightInterval;

/**
 content
 */
@property (nonatomic, copy) NSString *content;
/**
 content字体颜色
 */
@property (nonatomic, strong) UIColor *contentColor;

/**
 content字体大小
 */
@property (nonatomic, strong) UIFont *contentFont;

/**
 内容对齐方式
 */
@property (nonatomic, assign) NSTextAlignment contentAlignment;

/**
 标题内容宽度
 */
@property (nonatomic, assign) CGFloat textWidth;

@property(nonatomic, assign) BOOL showSubtitle;

/// 是否显示开关
@property(nonatomic, assign, getter=isShowSwitch) BOOL showSwitch;

@property(nonatomic, assign, getter=isOn) BOOL on;

/**
 是否显示箭头标识(默认显示)
 */
@property (nonatomic, assign, getter=isShowNextImgView) BOOL showNextImgView;

/// 开关选择回调
@property (nonatomic, copy) SwitchBlock switchBlock;

/// 是否显示红点
@property(nonatomic, assign) BOOL isShowRedPoint;

@end

