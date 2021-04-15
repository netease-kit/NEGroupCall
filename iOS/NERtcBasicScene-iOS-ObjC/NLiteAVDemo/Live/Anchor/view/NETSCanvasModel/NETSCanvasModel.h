//
//  NETSCanvasModel.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/15.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NERtcVideoCanvas;

@interface NETSCanvasModel : NSObject

//用户ID
@property (nonatomic, assign) uint64_t uid;

//渲染视图
@property (nonatomic, weak) UIView *renderContainer;

//已订阅了视频流
@property (nonatomic, assign) BOOL subscribedVideo;

//建立SDK Canvas
- (NERtcVideoCanvas *)setupCanvas;

//重置Canvas
- (void)resetCanvas;

@end

NS_ASSUME_NONNULL_END
