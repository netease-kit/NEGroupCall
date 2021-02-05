//
//  NETSLiveChatCell.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NETSMessageModel;

@interface NETSLiveChatCell : UITableViewCell

///
/// 实例化cell
/// @param tableView    - 展示控件
/// @param indexPath    - 展示indexPath
/// @param datas        - 展示数据集合
/// @return IM cell
///
+ (NETSLiveChatCell *)cellWithTableView:(UITableView *)tableView
                              indexPath:(NSIndexPath *)indexPath
                                  datas:(NSArray <NETSMessageModel *> *)datas;

///
/// 获取cell高度
/// @param indexPath    - 展示indexPath
/// @param datas        - 展示数据集合
///
+ (CGFloat)heightWithIndexPath:(NSIndexPath *)indexPath
                         datas:(NSArray <NETSMessageModel *> *)datas;

@end

NS_ASSUME_NONNULL_END
