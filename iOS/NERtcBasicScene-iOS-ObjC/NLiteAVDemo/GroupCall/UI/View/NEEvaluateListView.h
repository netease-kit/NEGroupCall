//
//  NEEvaluateListView.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEEvaluateListView : UIView
@property(copy,nonatomic)void(^didSelectedIndex) (NSInteger index,BOOL selected);
- (instancetype)initWithTitleArray:(NSArray *)titleArray;
@end

NS_ASSUME_NONNULL_END
