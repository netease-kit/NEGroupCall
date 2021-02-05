//
//  NENicknameVC.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NENicknameVC : NEBaseViewController
@property(strong,nonatomic) UITextField *nickTextField;
@property(copy,nonatomic) void(^didModifyNickname)(NSString *nickName);
@end

NS_ASSUME_NONNULL_END
