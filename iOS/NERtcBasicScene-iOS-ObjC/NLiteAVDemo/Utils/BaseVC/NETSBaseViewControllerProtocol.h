//
//  NETSBaseViewControllerProtocol.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FBBaseViewControllerProtocol <NSObject>

/**
 初始化导航栏配置
 */
- (void)nets_layoutNavigation;

/**
 初始化相关配置
 */
- (void)nets_initializeConfig;

/**
 添加子视图
 */
- (void)nets_addSubViews;

/**
 绑定视图模型以及相关事件
 */
- (void)nets_bindViewModel;

/**
 加载数据
 */
- (void)nets_getNewData;

@end
