//
//  NETSAudienceMask.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NETSLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSLiveRoomModel, NETSLiveRoomInfoModel;

///
/// 客户端蒙层
///

@protocol NETSAudienceMaskDelegate <NSObject>

/**
  播放器偏移
 @param status  - 直播间状态
 */
- (void)didChangeRoomStatus:(NETSAudienceStreamStatus)status;

/**
 直播间关闭
 */
- (void)didLiveRoomClosed;

@end

@interface NETSAudienceMask : UIView

@property (nonatomic, weak) id<NETSAudienceMaskDelegate>    delegate;

/// 是否展示失败弹窗
//@property (nonatomic, assign)   BOOL    showError;
/// 直播间是否可用(控制侧滑，YES可侧滑,NO不可侧滑)
@property(nonatomic, assign)    BOOL chatRoomAvailable;
/// 房间模型
@property (nonatomic, strong)   NETSLiveRoomModel       *room;
/// 房间详情
@property (nonatomic, strong)   NETSLiveRoomInfoModel   *info;
/// 直播间状态
@property (nonatomic, assign)   NETSAudienceRoomStatus  roomStatus;

/// 关闭直播间，调用关闭蒙版
- (void)closeChatRoom;

@end

NS_ASSUME_NONNULL_END
