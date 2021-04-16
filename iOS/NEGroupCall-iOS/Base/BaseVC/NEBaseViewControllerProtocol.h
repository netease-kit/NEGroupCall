//
//  NEBaseViewControllerProtocol.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NEBaseViewControllerProtocol <NSObject>

/**
 初始化导航栏配置
 */
- (void)ne_layoutNavigation;

/**
 初始化相关配置
 */
- (void)ne_initializeConfig;

/**
 添加子视图
 */
- (void)ne_addSubViews;

/**
 绑定视图模型以及相关事件
 */
- (void)ne_bindViewModel;

/**
 加载数据
 */
- (void)ne_getNewData;

@end
