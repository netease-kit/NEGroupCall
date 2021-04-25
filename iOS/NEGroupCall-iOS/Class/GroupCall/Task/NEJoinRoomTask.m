//
//  NEJoinRoomTask.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEJoinRoomTask.h"

@implementation NEJoinRoomTask
+ (instancetype)task {
    return [self taskWithSubURL:@"/mpVideoCall/room/join"];
}

@end
