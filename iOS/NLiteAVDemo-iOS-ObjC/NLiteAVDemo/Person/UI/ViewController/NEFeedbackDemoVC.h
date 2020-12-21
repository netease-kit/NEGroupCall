//
//  NEFeedbackDemoVC.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/23.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEFeedbackDemoVC : NEBaseTableViewController
@property(strong,nonatomic)NSString *selectedDemo;
@property(copy,nonatomic)void(^didSelectDemo) (NSString *demo);

@end

NS_ASSUME_NONNULL_END
