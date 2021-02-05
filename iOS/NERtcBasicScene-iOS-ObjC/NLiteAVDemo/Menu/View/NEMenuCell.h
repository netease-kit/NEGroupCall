//
//  NEMenuCell.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/21.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NEMenuCellBlock)(void);

@interface NEMenuCellModel : NSObject

@property (nonatomic, copy) NSString    *title;
@property (nonatomic, copy) NSString    *icon;
@property (nonatomic, copy) NEMenuCellBlock block;

- (instancetype)initWithTitle:(NSString *)title
                         icon:(NSString *)icon
                        block:(NEMenuCellBlock)block;

@end

///

@interface NEMenuCell : UITableViewCell

@property(strong,nonatomic)UILabel *titleLabel;
@property(strong,nonatomic)UIImageView *iconView;

+ (NEMenuCell *)cellWithTableView:(UITableView *)tableView
                        indexPath:(NSIndexPath *)indexPath
                             data:(NEMenuCellModel *)data;

+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
