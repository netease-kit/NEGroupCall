//
//  NETSLiveModel.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/4.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveModel.h"

@implementation NETSPassThroughHandlePkStartData

@end

///

@implementation NETSPassThroughHandlePunishData

@end

///

@implementation NETSPassThroughHandlePkEndData

@end

///

@implementation NETSPassThroughHandleStartLiveData

@end

///

@implementation NETSLiveRoomConfigModel

@end

///

@implementation NETSLiveRoomModel

+ (NSDictionary *)modelContainerPropertyGenericClass
{
  return @{@"liveConfig" : [NETSLiveRoomConfigModel class]};
}

@end

///

@implementation NETSCreateLiveRoomModel

+ (NSDictionary *)modelContainerPropertyGenericClass
{
  return @{@"liveConfig" : [NETSLiveRoomConfigModel class]};
}

@end

///

@implementation NETSLivePkRecord

@end

///

@implementation NETSLiveRoomInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass
{
  return @{
      @"members"       : [NETSLiveRoomModel class]
  };
}

@end

///

@implementation NETSPassThroughHandleRewardUser

- (nullable NSDictionary *)rewardUserDictionary
{
    return @{
        @"accountId": _accountId ?: @"",
        @"imAccid"  : _imAccid ?: @"",
        @"nickname" : _nickname ?: @"",
        @"avatar"   : _avatar ?: @"",
        @"rewardCoin"   : @(_rewardCoin)
    };
}

@end

///

@implementation NETSPassThroughHandleRewardData

+ (NSDictionary *)modelContainerPropertyGenericClass
{
  return @{
      @"rewardPkList"       : [NETSPassThroughHandleRewardUser class],
      @"inviteeRewardPkList": [NETSPassThroughHandleRewardUser class]
  };
}

- (nullable NSArray<NSString *> *)rewardAvatars
{
    return [self _avatarFromArray:_rewardPkList];
}

- (nullable NSArray<NSString *> *)inviteeRewardAvatars
{
    return [self _avatarFromArray:_inviteeRewardPkList];
}

- (nullable NSArray<NSString *> *)_avatarFromArray:(nullable NSArray<NETSPassThroughHandleRewardUser *> *)array
{
    if (!array) {
        return nil;
    }
    NSMutableArray *res = [NSMutableArray arrayWithCapacity:[array count]];
    for (NETSPassThroughHandleRewardUser *user in array) {
        NSString *avatar = user.avatar;
        [res addObject:avatar];
    }
    return [res copy];
}

@end

///

@implementation NETSLiveRoomJoinPkRoomData

@end


///

@implementation NETSLivePkResultData

@end

///

@implementation NETSPkLiveContriRewarder

@end

///

@implementation NETSPkLiveContriList

+ (NSDictionary *)modelContainerPropertyGenericClass
{
  return @{
      @"rewardRankVOList" : [NETSPkLiveContriRewarder class]
  };
}

- (nullable NSArray<NSString *> *)rewardAvatars
{
    if (!_rewardRankVOList) {
        return nil;
    }
    NSMutableArray *res = [NSMutableArray arrayWithCapacity:[_rewardRankVOList count]];
    for (NETSPkLiveContriRewarder *user in _rewardRankVOList) {
        NSString *avatar = user.avatar;
        [res addObject:avatar];
    }
    return [res copy];
}

@end
