//
//  NEGroupVideoView.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol NEGroupVideoViewDelegate <NSObject>

/// 视屏窗口点击缩放
/// @param userId 所在视图userid
- (void)zoomButtonClickAction:(NSInteger)userId;

/// 切换演讲者视图
/// @param userId 所在视图userid
- (void)exchangeSpeakerMode:(NSInteger)userId;

@end

@interface NEGroupVideoView : UIView

@property(strong,nonatomic)UIView *videoView;

@property(strong,nonatomic,nullable)NSString *userName;

@property(assign,nonatomic)NSInteger userId;

@property(nonatomic, weak) id<NEGroupVideoViewDelegate> delegate;
//是否隐藏 放大缩小标记
@property(nonatomic, assign) BOOL isHiddenZoomTag;
//缩放标记的状态
@property(nonatomic, assign) BOOL isZoomSelected;
//是否进入演讲者模式
@property(nonatomic, assign) BOOL isEnterSpeakerMode;
//信号质量
@property(nonatomic, assign) NSInteger signalQuality;

- (void)updateMicroEnable:(BOOL)microEnable;

@end

NS_ASSUME_NONNULL_END
