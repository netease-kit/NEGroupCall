//
//  NEPersonTableViewCell.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEPersonView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEPersonTableViewCell : UITableViewCell
@property(strong,nonatomic)NEPersonView *personView;

@end

NS_ASSUME_NONNULL_END
