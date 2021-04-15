//
//  NEEvaluateTask.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEEvaluateTask.h"

@implementation NEEvaluateTask

+ (instancetype)task {
    NSString *URLString = [NSString stringWithFormat:@"%@%@",kApiDataHost,@"/statics/report/feedback/demoSuggest"];
    return [self taskWithURLString:URLString];
}

@end
