//
//  NETSAnchorBottomPanel.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/10.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 圆形按钮
///

@interface NETSCircleBtn : UIControl

///
/// 实例化圆形图文按钮(默认尺寸64*64)
/// @param title    - 标题
/// @param icon     - 图标名称
/// @return 圆形图文按钮
///
- (instancetype)initWithTitle:(NSString *)title
                         icon:(NSString *)icon;

@end

///
/// 主播直播视图 底部面板
///

@protocol NETSAnchorBottomPanelDelegate <NSObject>

@optional

/// 触发 美颜 按钮 代理方法
- (void)clickBeautyBtn;

/// 触发 滤镜 按钮 代理方法
- (void)clickFilterBtn;

/// 触发 设置 按钮 代理方法
- (void)clickSettingBtn;

/// 触发 开启直播间 按钮 代理方法
- (void)clickStartLiveBtn;

@end

@interface NETSAnchorBottomPanel : UIView

@property (nonatomic, weak) id<NETSAnchorBottomPanelDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
