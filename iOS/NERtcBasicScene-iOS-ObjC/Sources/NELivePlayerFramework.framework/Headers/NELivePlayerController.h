/*
 * NELivePlayerController.h
 * NELivePlayer
 *
 * Create by biwei on 15-9-21
 * Copyright (c) 2015年 Netease. All rights reserved
 *
 * This file is part of LivePlayer.
 * 播放器全局方法类
 */

#import "NELivePlayer.h"

/************************************初始化方法使用*******************************************************************************
*  initWithContentURL:error: 方法 = （new/init/initWithNeedConfigAudioSession:）方法 + setPlayUrl: 方法                           
*
*  初始化->准备播放的调用流程如下:
*
*  1）使用initWithContentURL:error:初始化                         2）使用new/init/initWithNeedConfigAudioSession:初始化
*             |                                                                  |
*        set 参数 A -> set 参数 B ... -> set 参数 N                           setPlayUrl: (首先设置)
*                                    |                                           |
*                             prepareToPlay方法                              set 参数 A -> set 参数 B ... -> set 参数 N
*                                                                                                             |
*                                                                                                       prepareToPlay方法
*
*******************************************************************************************************************************/

/**
 *	@brief	播放器核心功能类
 */
@interface NELivePlayerController : NSObject <NELivePlayer>

/**
 @brief    初始化播放器，输入播放文件路径

 @param aUrl 播放文件的路径
 @param error 初始化错误原因
 @return 返回播放器实例
 */
- (instancetype)initWithContentURL:(NSURL *)aUrl
                             error:(NSError **)error;

/**
 初始化播放器

 @param aUrl 播放文件的路径
 @param config URL相关的配置信息
 @param error 初始化错误原因
 @return 返回播放器实例
 */
- (instancetype)initWithContentURL:(NSURL *)aUrl
                            config:(NELPUrlConfig *)config
                             error:(NSError **)error;
@end
