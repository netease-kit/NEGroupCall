//
//  NETSGiftModel.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/26.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 礼物模型
///

@interface NETSGiftModel : NSObject
//礼物id，1荧光棒 2安排 3跑车 4 火箭
@property (nonatomic, assign)   int32_t     giftId;
@property (nonatomic, copy)     NSString    *icon;
@property (nonatomic, copy)     NSString    *display;
@property (nonatomic, assign)   int32_t     price;

- (instancetype)initWithGiftId:(int32_t)giftId icon:(NSString *)icon display:(NSString *)display price:(int32_t)price;

@end

NS_ASSUME_NONNULL_END
