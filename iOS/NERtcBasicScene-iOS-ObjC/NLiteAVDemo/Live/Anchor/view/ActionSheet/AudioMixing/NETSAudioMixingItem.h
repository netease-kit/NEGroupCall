//
//  NETSAudioMixingItem.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 直播过程中 混音设置项
///

@class NETSAudioMixingItem;

@protocol NETSAudioMixingItemdelegate <NSObject>

///
/// 点击按钮控件代理事件
/// @param item     - 控件
/// @param selected - 选中状态
/// @param index    - 按钮索引
///
- (void)didClickItem:(NETSAudioMixingItem *)item selected:(BOOL)selected index:(NSInteger)index;

///
/// 滑动滑块值改变事件
/// @param item         - 控件
/// @param sliderValue  - 改变值
///
- (void)didChangedItem:(NETSAudioMixingItem *)item sliderValue:(float)sliderValue;

@end

@interface NETSAudioMixingItem : UIView

/// 滑动条当前值
@property (nonatomic, assign)   float       sliderValue;

- (instancetype)initWithTitle:(NSString *)title
                      btn1Tit:(NSString *)btn1Tit
                      btn2Tit:(NSString *)btn2Tit
                 sliderMinVal:(float)sliderMinVal
                 sliderMaxVal:(float)sliderMaxVal
                     delegate:(id<NETSAudioMixingItemdelegate>)deleagte;

///
/// 设置选中按钮
/// @param index    - 按钮索引
///
- (void)setSelectedIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
