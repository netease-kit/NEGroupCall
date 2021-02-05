//
//  NETSMoreSettingCell.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NETSMoreSettingModel;

@interface NETSMoreSettingCell : UICollectionViewCell

/// 实例化直播列表页cell
+ (NETSMoreSettingCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                      indexPath:(NSIndexPath *)indexPath
                                          datas:(NSArray <NETSMoreSettingModel *> *)datas;

/// 计算直播列表页cell size
+ (CGSize)size;

@end

NS_ASSUME_NONNULL_END
