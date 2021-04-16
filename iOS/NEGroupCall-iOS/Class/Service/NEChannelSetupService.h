//
//  NEChannelSetupService.h
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/24.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEChannelSetupService : NSObject
//分辨率
@property (nonatomic,strong) NSString *resolutionRatio;
//帧率
@property (nonatomic,strong) NSString *frameRate;
//场景类别
@property(nonatomic, assign) NSInteger scenarioType;
//音质
@property (nonatomic,strong) NSString *soundQuality;

+ (instancetype)sharedService;

@end

NS_ASSUME_NONNULL_END
