//
//  NEMultipleVideoNavView.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/3/10.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEMultipleVideoNavView : NEBaseView

@property(nonatomic, strong) RACSubject *backSubject;
@property(nonatomic, strong) RACSubject *setupSubject;

@end

NS_ASSUME_NONNULL_END
