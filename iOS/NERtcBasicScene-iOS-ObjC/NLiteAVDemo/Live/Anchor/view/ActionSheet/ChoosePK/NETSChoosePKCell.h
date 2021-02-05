//
//  NETSChoosePKCell.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NETSLiveRoomModel;

@protocol NETSChoosePKCellDelegate <NSObject>

- (void)didClickPKModel:(NETSLiveRoomModel *)model;

@end

///
/// 选择主播PK cell
///
@interface NETSChoosePKCell : UITableViewCell

@property (nonatomic, weak) id<NETSChoosePKCellDelegate> delegate;

+ (NETSChoosePKCell *)cellWithTableView:(UITableView *)tableView
                              indexPath:(NSIndexPath *)indexPath
                                  datas:(NSArray <NETSLiveRoomModel *> *)datas;

+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
