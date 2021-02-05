//
//  NEFeedbackListVC.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/22.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEBaseTableViewController.h"
#import "NEFeedbackInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEFeedbackListVC : NEBaseTableViewController
@property(copy,nonatomic)void(^didSelectResult) (NSArray <NEFeedbackInfo *>*result);

@end

NS_ASSUME_NONNULL_END
