//
//  NEChannelSetupCell.h
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/15.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEGlobalDefaultCell.h"

NS_ASSUME_NONNULL_BEGIN
@class NEChannelSetupModel;
@interface NEChannelSetupCell : NEGlobalDefaultCell

@property(nonatomic, strong) NEChannelSetupModel *dataModel;
//音乐的subject
@property(nonatomic, strong) RACSubject *musicSubject;
//语音的subjec
@property(nonatomic, strong) RACSubject *voiceSubject;

@end

NS_ASSUME_NONNULL_END
