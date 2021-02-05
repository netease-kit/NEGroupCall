//
//  NETSPkService.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/6.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>
#import "NETSLiveModel.h"
#import "NETSPkDelegate.h"
#import "NETSGCDTimer.h"

#define kPkServiceTimeoutMax            25

NS_ASSUME_NONNULL_BEGIN

@class NERtcLiveStreamTaskInfo;

/**
 pk直播服务类
 */

/// 创建单人直播间成功闭包
typedef void (^StartSingleLiveSuccess)(NETSCreateLiveRoomModel *_Nonnull, NERtcLiveStreamTaskInfo *_Nonnull);

@interface NETSPkService : NSObject <NIMPassThroughManagerDelegate>

/// 代理句柄
@property (nonatomic, weak,   nullable) id<NETSPkServiceDelegate, NETSPkInviterDelegate, NETSPkInviteeDelegate, NETSPassThroughHandleDelegate> delegate;
/// 推流任务
@property (nonatomic, strong, nonnull)  NERtcLiveStreamTaskInfo *streamTask;
/// 单人直播间模型
@property (nonatomic, strong, nonnull)  NETSCreateLiveRoomModel *singleRoom;
/// pk直播间模型
@property (nonatomic, strong, nullable) NETSCreateLiveRoomModel *pkRoom;
/// 当前直播状态
@property (nonatomic, assign) NETSPkServiceStatus   liveStatus;
/// 当前角色
@property (nonatomic, assign) NETSPkServiceRole     liveRole;

/// 计时器操作队列
@property (nonatomic, strong) dispatch_queue_t      timerQueue;
/// 计时器,记录超时
@property (nonatomic, strong, nullable) NETSGCDTimer            *timer;

#pragma mark - public method

/**
 初始化pk服务类
 @param delegate        - 代理句柄
 */
- (instancetype)initWithDelegate:(id<NETSPkServiceDelegate, NETSPkInviterDelegate, NETSPkInviteeDelegate, NETSPassThroughHandleDelegate>)delegate;

/**
 创建单主播直播间并推流
 @param topic           - 直播间主题
 @param coverUrl        - 直播间封面
 @param successBlock    - 创建直播间并推流成功闭包(返回直播间模型和推流ID)
 @param failedBlock     - 创建直播间或推流失败闭包
 */
- (void)startSingleLiveWithTopic:(NSString *)topic
                        coverUrl:(NSString *)coverUrl
                    successBlock:(StartSingleLiveSuccess)successBlock
                     failedBlock:(void(^)(NSError *))failedBlock;

/**
 结束直播
 @param completionBlock - 结束直播间完成闭包
 */
- (void)endLiveWithCompletionBlock:(void(^)(NSError * _Nullable))completionBlock;

/**
 单人直播间/pk直播间转换
 @param successBlock    - 创建直播间并推流成功闭包
 @param failedBlock     - 创建直播间或推流失败闭包
 */
- (void)transformRoomWithSuccessBlock:(void(^)(NETSPkServiceStatus, int64_t))successBlock
                          failedBlock:(void(^)(NSError *))failedBlock;

/**
 结束pk直播
 @param completionBlock - 结束直播间完成闭包
 */
- (void)endPkWithCompletionBlock:(nullable void(^)(NSError * _Nullable))completionBlock;

/**
 推流操作(接到passThrough透传PK开始的信息后执行)
 @param data            - passThrough透传消息
 @param successBlock    - 推流成功闭包
 @param failedBlock     - 推流失败闭包
 */
- (void)pushPkStreamWithData:(NETSPassThroughHandlePkStartData *)data
                successBlock:(void(^)(void))successBlock
                 failedBlock:(void(^)(NSError *, NSString * _Nullable))failedBlock;

#pragma mark - private method

/**
 尝试加入pk直播间
 @param liveCid         - 回到原单人房间,传自己的直播间cid; 邀请者进入pk房间,传自己的单人直播间cid
 @param parentLiveCid   - 单人直播间cid
 @param successBlock    - 请求结束闭包
 @param failedBlock     - 请求失败闭包
 */
- (void)_tryToJoinPkRoomWithLiveCid:(NSString *)liveCid
                      parentLiveCid:(NSString *)parentLiveCid
                       successBlock:(void(^)(int64_t, uint64_t, uint64_t))successBlock
                        failedBlock:(void(^)(NSError *))failedBlock;

@end

NS_ASSUME_NONNULL_END
