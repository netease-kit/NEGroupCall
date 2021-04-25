//
//  NEGroupUserModel.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/12/7.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEGroupUserModel.h"

@implementation NEGroupUserModel
- (instancetype)initWithUserId:(NSInteger)userId
{
    self = [super init];
    if (self) {
        self.userId = userId;
    }
    return self;
}

@end
