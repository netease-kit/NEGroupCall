//
//  NEMenuCell.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/21.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEMenuCellModel : NSObject

@property (nonatomic, copy) NSString    *title;
@property (nonatomic, copy) NSString    *icon;

- (instancetype)initWithTitle:(NSString *)title
                         icon:(NSString *)icon;

@end

///

@interface NEMenuCell : UITableViewCell

@property(strong,nonatomic)UILabel *titleLabel;
@property(strong,nonatomic)UIImageView *iconView;

+ (NEMenuCell *)cellWithTableView:(UITableView *)tableView
                        indexPath:(NSIndexPath *)indexPath
                            datas:(NSArray <NEMenuCellModel *> *)datas;

+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
