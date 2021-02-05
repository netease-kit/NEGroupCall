//
//  NETSLiveSegmentedSettingModel.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveSegmentedSettingModel.h"

@implementation NETSLiveSegmentedSettingModel

- (instancetype)initWithDisplay:(NSString *)display value:(NSInteger)value
{
    self = [super init];
    if (self) {
        _display = display;
        _value = value;
    }
    return self;
}

@end
