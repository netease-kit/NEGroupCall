//
//  NETSApiOptions.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSApiOptions.h"
#import "AppKey.h"

@implementation NETSApiOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        _host = kApiHost;
        _timeoutInterval = 10;
    }
    return self;
}

@end
