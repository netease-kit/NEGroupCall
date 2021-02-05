//
//  NEUserInfoTask.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEUserInfoTask.h"

@implementation NEUserInfoTask
+ (instancetype)task {
    return [self taskWithSubURL:@"/mpVideoCall/room/member/info"];
}
@end
