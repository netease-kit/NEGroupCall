//
//  NETSLiveUtils.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveUtils.h"
#import "NETSLiveConfig.h"
#import <NERtcSDK/NERtcSDK.h>

@implementation NETSLiveUtils

+ (nullable NETSGiftModel *)getRewardWithGiftId:(NSInteger)giftId
{
    NETSGiftModel *gift = nil;
    for (NETSGiftModel *tmp in [NETSLiveConfig shared].gifts) {
        if (tmp.giftId == giftId) {
            gift = tmp;
            break;
        }
    }
    return gift;
}

+ (nullable NSDictionary *)gitInfo
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *gitSHA = [infoDict objectForKey:@"GitCommitSHA"];
    NSString *gitBranch = [infoDict objectForKey:@"GitCommitBranch"];
    NSString *gitCommitUser = [infoDict objectForKey:@"GitCommitUser"];
    NSString *gitCommitDate = [infoDict objectForKey:@"GitCommitDate"];
    
    NSDictionary *gitDict = @{
        @"gitSHA" : gitSHA ?: @"nil",
        @"gitBranch" : gitBranch ?: @"nil",
        @"gitCommitUser" : gitCommitUser ?: @"nil",
        @"gitCommitDate" : gitCommitDate ?: @"nil"
    };
    return gitDict;
}

@end
