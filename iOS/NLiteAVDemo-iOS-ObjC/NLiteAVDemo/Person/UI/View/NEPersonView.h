//
//  NEPersonView.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEPersonView : UIView
@property(strong,nonatomic)UILabel *titleLabel;
@property(strong,nonatomic)UILabel *detailLabel;
@property(strong,nonatomic)UIImageView  *iconImageView;
@property(strong,nonatomic)UIImageView  *indicatorImageView;


@end

NS_ASSUME_NONNULL_END
