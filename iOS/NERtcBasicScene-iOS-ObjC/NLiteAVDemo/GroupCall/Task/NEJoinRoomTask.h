//
//  NEJoinRoomTask.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEJoinRoomTask : NETask
@property(strong,nonatomic)NSString *req_mpRoomId;
@property(strong,nonatomic)NSString *req_accountId;
@property(strong,nonatomic)NSString *req_nickName;
@property(assign,nonatomic)NSInteger req_clientType;

/// 音视频房间的channelName
@property(strong,nonatomic)NSString *avRoomCName;
/// 音视频房间id
@property(strong,nonatomic)NSString *avRoomCid;
/// 成员在音视频房间中用户id
@property(assign,nonatomic)NSInteger avRoomUid;
/// token，加入音视频房间用的鉴权
@property(strong,nonatomic)NSString *avRoomCheckSum;
/// 房间的创建时间
@property(assign,nonatomic)NSInteger createTime;
/// 房间已经持续的时间
@property(assign,nonatomic)NSInteger duration;
/// appId 和 mpRoomId 加密后的key
@property(strong,nonatomic)NSString *roomKey;
/// 房间唯一id
@property(assign,nonatomic)NSInteger roomUniqueId;
/// 房间号，由用户输入
@property(strong,nonatomic)NSString *mpRoomId;
/// nrtc的appKey
@property(strong,nonatomic)NSString *nrtcAppKey;
/// 请求Id，用于跟踪日志
@property(strong,nonatomic)NSString *requestId;

@property (nonatomic , copy) NSString              * mpRoomKey;

@end

NS_ASSUME_NONNULL_END
