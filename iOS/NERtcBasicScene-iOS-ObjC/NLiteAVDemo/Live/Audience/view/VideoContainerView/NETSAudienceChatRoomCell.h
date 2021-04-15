//
//  NETSAudienceChatRoomCell.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2021/1/7.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NETSLiveRoomModel;

@interface NETSAudienceChatRoomCell : UICollectionViewCell

/// 直播间模型
@property(nonatomic, strong) NETSLiveRoomModel *roomModel;

/**
 重置页面UI效果
 */
- (void)resetPageUserinterface;

/**
 关闭播放器,销毁资源
 */
- (void)shutdownPlayer;

@end

NS_ASSUME_NONNULL_END
