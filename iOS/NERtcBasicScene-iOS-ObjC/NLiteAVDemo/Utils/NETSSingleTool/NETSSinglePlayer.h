//
//  NETSSinglePlayer.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2021/1/7.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NELivePlayerController;
@interface NETSSinglePlayer : NSObject

@property(nonatomic, strong) NSURL *playUrl;

//单例
+ (instancetype)sharePlayerManager;

//销毁播放器
- (void)destoryPlayer;

//返回当前播放器
- (NELivePlayerController *)currentPlayer;

@end

NS_ASSUME_NONNULL_END
