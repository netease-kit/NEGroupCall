//
//  NEModifyNicknameTask.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEModifyNicknameTask.h"

@implementation NEModifyNicknameTask
+ (instancetype)task {
    return [self taskWithSubURL:@"/auth/updateNickname"];
}
@end
