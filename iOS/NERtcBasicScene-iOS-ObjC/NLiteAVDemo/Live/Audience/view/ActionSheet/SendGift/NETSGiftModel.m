//
//  NETSGiftModel.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/26.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSGiftModel.h"

@implementation NETSGiftModel

- (instancetype)initWithGiftId:(int32_t)giftId icon:(NSString *)icon display:(NSString *)display price:(int32_t)price
{
    self = [super init];
    if (self) {
        _giftId = giftId;
        _icon = icon;
        _display = display;
        _price = price;
    }
    return self;
}

@end
