//
//  NETSPushStreamService.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/15.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NERtcLiveStreamTaskInfo;
@class SKVObject;
@class NIMSignalingNotifyInfo;

@interface NETSPushStreamService : NSObject

/**
 添加推流任务
 @param task            - 推流任务
 @param successBlock    - 推流成功闭包
 @param failedBlock     - 推流失败闭包
*/
+ (void)addStreamTask:(NERtcLiveStreamTaskInfo *)task
         successBlock:(void(^)(void))successBlock
          failedBlock:(void(^)(NSError *, NSString *))failedBlock;

/**
 移除推流任务
 @param taskId          - 推流任务id
 @param successBlock    - 移除推流成功闭包
 @param failedBlock     - 移除推流失败闭包
*/
+ (void)removeStreamTask:(NSString *)taskId
            successBlock:(void(^)(void))successBlock
             failedBlock:(void(^)(NSError *))failedBlock;

/**
 构造推流任务
 @param url     - 推流地址
 @param uids    - 用户ID
 @return 推流任务
 */
+ (nullable NERtcLiveStreamTaskInfo *)streamTaskWithUrl:(NSString *)url
                                                   uids:(NSArray<NSNumber *> *)uids;

/**
 解析信令返回自定义字段
 @param response    - 信令消息
 */
+ (nullable SKVObject *)parseCutomInfoForResponse:(NIMSignalingNotifyInfo *)response;

/**
 加入直播间并推流
 @param token           - 授权信息
 @param channelName     - 信道名称
 @param uid             - 用户ID
 @param streamUrl       - 推流地址
 @param successBlcok    - 操作成功闭包
 @param failedBlock     - 操作失败闭包
 */
+ (void)joinChannelWithToken:(NSString *)token
                 channelName:(nullable NSString *)channelName
                         uid:(uint64_t)uid
                   streamUrl:(NSString *)streamUrl
                successBlcok:(void(^)(NERtcLiveStreamTaskInfo *))successBlcok
                 failedBlock:(void(^)(NSError *, NSString * _Nullable))failedBlock;

@end

NS_ASSUME_NONNULL_END
