//
//  NENavigator.h
//  NLiteAVDemo
//
//  Created by Think on 2020/8/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NELoginOptions.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSLiveRoomModel;

@interface NENavigator: NSObject

@property (nonatomic, weak) UINavigationController  *navigationController;
@property (nonatomic, weak) UINavigationController  *loginNavigationController;

+ (NENavigator *)shared;

/**
 展示登录控制器
 @param options - 登录配置项
 */
- (void)loginWithOptions:(NELoginOptions * _Nullable)options;

/**
 关闭登录视图
 @param completion - 关闭登录视图执行闭包
 */
- (void)closeLoginWithCompletion:(_Nullable NELoginBlock)completion;

/**
进入多人视频通话
*/
- (void)showGroupVC;

/**
展示直播列表页
*/
- (void)showLiveListVC;

/**
 进入主播直播间
 */
- (void)showAnchorVC;

/**
 进入直播间
 @param roomData 点击时候的数据源
 @param index 选中的房间
 */
- (void)showLivingRoom:(NSArray<NETSLiveRoomModel*> *)roomData selectindex:(NSInteger)index;

/**
 回到根tabBar控制器
 @param index   - 根导航控制器索引
 */
- (void)showRootNavWitnIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
