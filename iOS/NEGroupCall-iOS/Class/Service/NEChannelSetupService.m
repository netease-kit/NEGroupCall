//
//  NEChannelSetupService.m
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/24.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEChannelSetupService.h"

@implementation NEChannelSetupService


+ (instancetype)sharedService {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NEChannelSetupService alloc] init];
    });
    return instance;
}


@end
