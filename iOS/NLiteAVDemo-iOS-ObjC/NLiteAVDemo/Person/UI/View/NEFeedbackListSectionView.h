//
//  NEFeedbackListSectionView.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/22.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEFeedbackListSectionView : UITableViewHeaderFooterView
@property(strong,nonatomic)UILabel *titleLabel;
@property(strong,nonatomic)UIButton *arrowButton;
@property(copy,nonatomic)void(^didSelect)(BOOL selected);

@end

NS_ASSUME_NONNULL_END
