//
//  NETSLiveApi.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/3.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveApi.h"

@implementation NETSLiveApi

+ (void)fetchListWithLive:(NETSLiveListType)live
                  pageNum:(int32_t)pageNum
                 pageSize:(int32_t)pageSize
         completionHandle:(nullable NETSRequestCompletion)completionHandle
              errorHandle:(nullable NETSRequestError)errorHandle
{
    NSString *liveVal = @"-1";
    if (live == NETSLiveListLive) {
        liveVal = @"1";
    } else if (live == NETSLiveListPK) {
        liveVal = @"2";
    }
    
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/v1/pkLive/getLiveRoomList";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"live": liveVal,
        @"pageNum": @(pageNum),
        @"pageSize": @(pageSize)
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NSDictionary class] isArray:NO],
        [NETSApiModelMapping mappingWith:@"/data/list" mappingClass:[NETSLiveRoomModel class] isArray:YES],
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    [resuest asyncRequest];
}

+ (void)randowToipcWithCompletionHandle:(nullable NETSRequestCompletion)completionHandle
                            errorHandle:(nullable NETSRequestError)errorHandle
{
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/v1/pkLive/liveRoom/getRandomRoomTopic";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{@"accountId": [NEAccount shared].userModel.accountId ?: @""};
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NSString class] isArray:NO]
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    [resuest asyncRequest];
}

+ (void)randomCoverWithCompletionHandle:(nullable NETSRequestCompletion)completionHandle
                            errorHandle:(nullable NETSRequestError)errorHandle
{
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/v1/pkLive/liveRoom/getRandomLivePic";
    options.apiMethod = NETSRequestMethodPOST;
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NSString class] isArray:NO]
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    [resuest asyncRequest];
}

+ (void)createLiveRoomWithTopic:(NSString *)topic
                       coverUrl:(NSString *)coverUrl
                           type:(NETSLiveType)type
                  parentLiveCid:(nullable NSString *)parentLiveCid
               completionHandle:(NETSRequestCompletion)completionHandle
                    errorHandle:(nullable NETSRequestError)errorHandle
{
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/v1/pkLive/liveRoomCreate";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"clientType"   : @"0",         // 预留字段
        @"deviceId"     : @"",          // 预留字段
        @"liveCid"      : @"",          // 可返回之前创建的房间
        @"liveCoverPic" : coverUrl ?: @"",
        @"liveType"     : @(type),
        @"mpRoomId"     : @"",          // 预留字段
        @"parentLiveCid": parentLiveCid ?: @"",
        @"roomTopic"    : topic ?: @"",
        @"roomUniqueId" : @"0",
        @"userId"       : @""
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NETSCreateLiveRoomModel class] isArray:NO]
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    [resuest asyncRequest];
}

+ (void)startPKWithCid:(NSString *)cid
      completionHandle:(NETSRequestCompletion)completionHandle
           errorHandle:(nullable NETSRequestError)errorHandle
{
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/v1/pkLive/livePk";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"accountId": [NEAccount shared].userModel.accountId ?: @"",
        @"liveCid": cid ?: @""
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/" mappingClass:[NSDictionary class] isArray:NO]
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    
    [resuest asyncRequest];
}

+ (void)joinLiveRoomWithLiveId:(NSString *)liveCid
                 parentLiveCid:(NSString *)parentLiveCid
                      liveType:(NETSLiveType)liveType
              completionHandle:(NETSRequestCompletion)completionHandle
                   errorHandle:(nullable NETSRequestError)errorHandle
{
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/v1/pkLive/join";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"liveCid": liveCid ?: @"",
        @"parentLiveCid": parentLiveCid ?: @"",
        @"clientType": @"2",
        @"liveType": @(liveType)
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NETSCreateLiveRoomModel class] isArray:NO]
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    
    [resuest asyncRequest];
}

+ (void)endPKWithCid:(NSString *)cid
    completionHandle:(NETSRequestCompletion)completionHandle
         errorHandle:(nullable NETSRequestError)errorHandle
{
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/v1/pkLive/pkLiveRoomClose";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"accountId": [NEAccount shared].userModel.accountId ?: @"",
        @"liveCid": cid ?: @""
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/" mappingClass:[NSDictionary class] isArray:NO]
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    
    [resuest asyncRequest];
}

+ (void)closeLiveRoomWithCid:(NSString *)cid
            completionHandle:(NETSRequestCompletion)completionHandle
                 errorHandle:(nullable NETSRequestError)errorHandle
{
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/v1/pkLive/liveRoomClose";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"accountId": [NEAccount shared].userModel.accountId ?: @"",
        @"liveCid": cid ?: @""
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/" mappingClass:[NSDictionary class] isArray:NO]
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    
    [resuest asyncRequest];
}

+ (void)roomInfoWithCid:(NSString *)cid
       completionHandle:(nullable NETSRequestCompletion)completionHandle
            errorHandle:(nullable NETSRequestError)errorHandle
{
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/v1/pkLive/liveRoom/info";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{@"liveCid"  : cid ?: @""};
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NETSLiveRoomInfoModel class] isArray:NO]
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    
    [resuest asyncRequest];
}

+ (void)rewardLiveCid:(NSString *)liveCid
             liveType:(NETSLiveType)liveType
      anchorAccountId:(NSString *)anchorAccountId
               giftId:(NSInteger)giftId
     completionHandle:(nullable NETSRequestCompletion)completionHandle
          errorHandle:(nullable NETSRequestError)errorHandle
{
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/v1/pkLive/reward";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"liveCid"  : liveCid ?: @"",
        @"liveType" : @(liveType),
        @"anchorAccountId"  : anchorAccountId,
        @"giftId"   : @(giftId)
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/" mappingClass:[NSDictionary class] isArray:NO]
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    
    [resuest asyncRequest];
}

+ (void)getPKResultWithLiveCid:(NSString *)liveCid
              completionHandle:(nullable NETSRequestCompletion)completionHandle
                   errorHandle:(nullable NETSRequestError)errorHandle
{
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/v1/pkLive/getPkResult";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"liveCid"  : liveCid ?: @""
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NETSLivePkResultData class] isArray:NO]
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    
    [resuest asyncRequest];
}

+ (void)getPkLiveContriListWithLiveCid:(NSString *)liveCid
                              liveType:(NETSLiveType)liveType
                       anchorAccountId:(NSString *)anchorAccountId
                          successBlock:(nullable NETSRequestCompletion)successBlock
                           failedBlock:(nullable NETSRequestError)failedBlock
{
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/v1/pkLive/getPkLiveContriList";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"liveCid"          : liveCid ?: @"",
        @"liveType"         : @(liveType),
        @"anchorAccountId"  :  anchorAccountId
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NETSPkLiveContriList class] isArray:NO]
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = successBlock;
    resuest.errorBlock = failedBlock;
    
    [resuest asyncRequest];
}

@end
