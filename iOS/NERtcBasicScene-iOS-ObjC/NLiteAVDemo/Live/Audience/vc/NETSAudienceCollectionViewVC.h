//
//  NETSAudienceCollectionView.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2021/1/7.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSBaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface NETSAudienceCollectionViewVC : NETSBaseViewController

/// 构造函数
/// @param liveData 直播数据源
/// @param selectRoomIndex 选中的房间
- (instancetype)initWithScrollData:(NSArray *)liveData currentRoom:(NSInteger)selectRoomIndex;

@end

NS_ASSUME_NONNULL_END
