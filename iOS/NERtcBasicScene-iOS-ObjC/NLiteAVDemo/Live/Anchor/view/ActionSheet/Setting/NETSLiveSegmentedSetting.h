//
//  NETSLiveSegmentedSetting.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NETSSettingSegmented;
@class NETSLiveSegmentedSettingModel;
@class NETSLiveSegmentedSetting;

///
/// 自定义直播分段设置视图代理方法
///

@protocol NETSLiveSegmentedSettingDelegate <NSObject>

@optional
///
/// 自定义直播分段设置视图值改变事件
/// @param segmented        - 触发值改变的视图
/// @param selectedIndex    - 改变后的索引值
/// @param selectedItem     - 改变后的模型
///
- (void)changedLiveSegmented:(NETSLiveSegmentedSetting *)segmented
               selectedIndex:(NSInteger)selectedIndex
                selectedItem:(nullable NETSLiveSegmentedSettingModel *)selectedItem;

@end

///
/// 自定义直播分段设置视图
///

@interface NETSLiveSegmentedSetting : UIView

/// 标题控件
@property (nonatomic, strong)   UILabel     *titleLab;
/// 分段控件
@property (nonatomic, strong)   NETSSettingSegmented    *segment;
/// 数据源
@property (nonatomic, strong)   NSArray <NETSLiveSegmentedSettingModel *>     *items;
/// 代理对象
@property (nonatomic, weak)     id<NETSLiveSegmentedSettingDelegate>        delegate;
/// 设置选中的值
@property (nonatomic, assign)   NSInteger selectedValue;

///
/// 实例化直播分段设置视图
/// @param title    - 标题
/// @param items    - 配置项
///
- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items;

@end

NS_ASSUME_NONNULL_END
