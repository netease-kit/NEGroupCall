//
//  NEGroupUserModel.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/12/7.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEGroupVideoView.h"
NS_ASSUME_NONNULL_BEGIN

@interface NEGroupUserModel : NSObject
@property(assign,nonatomic)NSInteger userId;
@property(strong,nonatomic)NSString *nickName;
@property(strong,nonatomic)NEGroupVideoView *videoView;
- (instancetype)initWithUserId:(NSInteger)userId;
@end

NS_ASSUME_NONNULL_END
