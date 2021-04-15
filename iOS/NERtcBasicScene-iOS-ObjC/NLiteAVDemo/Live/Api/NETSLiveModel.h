//
//  NETSLiveModel.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/4.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 服务端接口数据模型

/// 观众端直播间状态
typedef NS_ENUM(NSInteger, NETSAudienceRoomStatus) {
    NETSAudienceRoomInit        = 0,    // 直播间初始化
    NETSAudienceRoomPullStream  = 1,    // 直播正在拉流
    NETSAudienceRoomPlaying     = 2,    // 直播中
    NETSAudienceRoomLiveClosed  = 3,    // 直播结束
    NETSAudienceRoomLiveError   = 4     // 发生错误
};

/// 观众端视频流状态
typedef NS_ENUM(NSInteger, NETSAudienceStreamStatus) {
    NETSAudienceStreamDefault   = 0,    // 默认单人视频流
    NETSAudienceIMPkStart       = 1,    // 接到pk开始信令
    NETSAudienceStreamMerge     = 2,    // 合流成功
    NETSAudienceIMPkEnd         = 3     // 接到pk结束信令
};

/// pk角色枚举
typedef NS_ENUM(NSInteger, NETSPkRoleType) {
    NETSPkRoleUnknown  = 0,    // 未知角色
    NETSPkRoleInviter  = 1,    // pk邀请者
    NETSPkRoleInvitee  = 2     // pk被邀请者
};

/// 直播场景
typedef NS_ENUM(NSInteger, NETSLiveScenes) {
    NETSLivePreview = 0,    // 单人直播
    NETSLiveSingle  = 1,    // 单人直播
    NETSLivePK      = 2     // pk直播
};

/// 直播间列表房间类型
typedef NS_ENUM(NSInteger, NETSLiveListType) {
    NETSLiveListAll     = -1,
    NETSLiveListLive    = 1,
    NETSLiveListPK      = 2
};

/// 创建直播/打赏直播间 类型
typedef NS_ENUM(NSUInteger, NETSLiveType) {
    NETSLiveTypeNormal  = 2,
    NETSLiveTypePK      = 3
};

/**
 用户角色类型
 */
typedef NS_ENUM(NSUInteger, NETSUserMode) {
    NETSUserModeAnchor      = 0,    // 主播
    NETSUserModeAudience    = 1     // 观众
};

/**
 直播间配置模型
 */
@interface NETSLiveRoomConfigModel : NSObject

@property (nonatomic, copy)     NSString    *httpPullUrl;
@property (nonatomic, copy)     NSString    *rtmpPullUrl;
@property (nonatomic, copy)     NSString    *hlsPullUrl;
@property (nonatomic, copy)     NSString    *pushUrl;
@property (nonatomic, copy)     NSString    *cid;
@property (nonatomic, strong)   NSDictionary    *config;

@end

/**
 直播列表页/data/list数组元素 - 直播间信息
 */

typedef NS_ENUM(NSUInteger, NETSRoomLiveStatus) {
    NETSRoomNotStart    = 0,    // 未开始
    NETSRoomLiving      = 1,    // 正在直播
    NETSRoomPKing       = 2,    // PK直播
    NETSRoomPKEnd       = 3,    // PK直播结束
    NETSRoomLivingEnd   = 4,    // 直播结束
    NETSRoomPunishment  = 5     // PK惩罚
};

@interface NETSLiveRoomModel : NSObject

@property (nonatomic, copy)     NSString    *nickname;
@property (nonatomic, copy)     NSString    *avatar;
@property (nonatomic, copy)     NSString    *accountId;
@property (nonatomic, copy)     NSString    *roomUid;
@property (nonatomic, copy)     NSString    *roomCid;
@property (nonatomic, assign)   int32_t     appId;
@property (nonatomic, copy)     NSString    *imAccd;
@property (nonatomic, copy)     NSString    *roomTopic;
@property (nonatomic, copy)     NSString    *liveCid;
@property (nonatomic, copy)     NSString    *mpRoomId;
@property (nonatomic, copy)     NSString    *avRoomCName;
@property (nonatomic, copy)     NSString    *avRoomCheckSum;
@property (nonatomic, copy)     NSString    *avRoomUid;
@property (nonatomic, copy)     NSString    *avRoomCid;
@property (nonatomic, strong)   NETSLiveRoomConfigModel    *liveConfig;
@property (nonatomic, copy)     NSString    *liveCoverPic;
@property (nonatomic, copy)     NSString    *chatRoomId;
@property (nonatomic, copy)     NSString    *chatRoomCreator;
@property (nonatomic, assign)   NETSRoomLiveStatus          live;
@property (nonatomic, assign)   int32_t     audienceCount;
@property (nonatomic, copy)     NSString    *parentLiveCid;
@property (nonatomic, copy)     NSString    *imAccid;

@end

/**
 创建直播间返回data模型
 */
@interface NETSCreateLiveRoomModel : NSObject

@property (nonatomic, copy)     NSString    *nickname;
@property (nonatomic, copy)     NSString    *avatar;
@property (nonatomic, copy)     NSString    *accountId;
@property (nonatomic, copy)     NSString    *roomUid;
@property (nonatomic, copy)     NSString    *roomCid;
@property (nonatomic, assign)   int64_t     appId;
@property (nonatomic, copy)     NSString    *imAccd;
@property (nonatomic, copy)     NSString    *roomTopic;
@property (nonatomic, copy)     NSString    *liveCid;
@property (nonatomic, copy)     NSString    *avRoomCName;
@property (nonatomic, copy)     NSString    *avRoomCheckSum;
@property (nonatomic, copy)     NSString    *avRoomUid;
@property (nonatomic, copy)     NSString    *avRoomCid;
@property (nonatomic, strong)   NETSLiveRoomConfigModel *liveConfig;
@property (nonatomic, copy)     NSString    *liveCoverPic;
@property (nonatomic, copy)     NSString    *chatRoomId;
@property (nonatomic, assign)   int32_t     live;
@property (nonatomic, copy)     NSString    *chatRoomCreator;
@property (nonatomic, assign)   int32_t     audienceCount;
@property (nonatomic, copy)     NSString    *imAccid;

@end

///

/**
 直播间主播信息模型-pk字段模型
 */
@interface NETSLivePkRecord : NSObject

@property (nonatomic, copy)     NSString    *invitee;
@property (nonatomic, copy)     NSString    *inviteeLiveCid;
@property (nonatomic, assign)   int64_t     inviteeRewards;
@property (nonatomic, copy)     NSString    *inviter;
@property (nonatomic, copy)     NSString    *inviterLiveCid;
@property (nonatomic, assign)   int64_t     inviterRewards;
@property (nonatomic, copy)     NSString    *liveCid;
@property (nonatomic, assign)   int64_t     pkEndTime;
@property (nonatomic, assign)   int64_t     pkStartTime;
@property (nonatomic, assign)   int64_t     punishmentStartTime;
@property (nonatomic, assign)   NETSRoomLiveStatus  status;
@property (nonatomic, copy)     NSString    *roomCid;
@property (nonatomic, assign)   int32_t     type;
@property (nonatomic, assign)   int64_t     currentTime;

@end

/**
 直播间主播信息模型
 */
@interface NETSLiveRoomInfoModel : NSObject

@property (nonatomic, copy)     NSString            *avRoomCName;
@property (nonatomic, copy)     NSString            *avRoomCid;
@property (nonatomic, copy)     NSString            *liveCid;
@property (nonatomic, strong)   NSArray<NETSLiveRoomModel *>    *members;
@property (nonatomic, strong)   NETSLivePkRecord    *pkRecord;
@property (nonatomic, copy)     NSString            *pkStartTime;
@property (nonatomic, assign)   NETSRoomLiveStatus  status;
@property (nonatomic, assign)   NETSLiveType        type;
@property (nonatomic, assign)   int32_t             coinTotal;

@end

#pragma mark - PassThought消息体模型

/// 服务端透传消息类型
typedef NS_ENUM(NSInteger, NETSLivePassThroughType) {
    NETSLivePassThroughTypeMin      = 1999, // 默认值
    NETSLivePassThroughStartPK      = 2000, // PK开始消息
    NETSLivePassThroughStartPunish  = 2001, // PK惩罚开始消息：告诉主播PK结果
    NETSLivePassThroughReward       = 2002, // 观众打赏消息
    NETSLivePassThroughEndPK        = 2003, // PK结束消息
    NETSLivePassThroughStartLive    = 2004  // 直播开始
};

/**
 pk开始消息体
 */
@interface NETSPassThroughHandlePkStartData : NSObject

@property (nonatomic, copy)     NSString    *operUser;
@property (nonatomic, copy)     NSString    *fromUser;
@property (nonatomic, copy)     NSString    *fromUserAvRoomUid;
@property (nonatomic, assign)   int64_t     pkStartTime;
@property (nonatomic, assign)   int64_t     pkPulishmentTime;
@property (nonatomic, assign)   int64_t     currentTime;
@property (nonatomic, copy)     NSString    *inviter;
@property (nonatomic, assign)   int64_t     inviterRoomUid;
@property (nonatomic, assign)   int64_t     inviteeRoomUid;
@property (nonatomic, copy)     NSString    *invitee;
@property (nonatomic, copy)     NSString    *inviterNickname;
@property (nonatomic, copy)     NSString    *inviteeNickname;
@property (nonatomic, copy)     NSString    *inviterAvatar;
@property (nonatomic, copy)     NSString    *inviteeAvatar;

@end

/**
 pk惩罚消息体
 */
@interface NETSPassThroughHandlePunishData : NSObject

@property (nonatomic, copy)     NSString    *operUser;
@property (nonatomic, copy)     NSString    *fromUser;
@property (nonatomic, copy)     NSString    *fromUserAvRoomUid;
@property (nonatomic, copy)     NSString    *roomCid;
@property (nonatomic, assign)   int64_t     pkStartTime;
@property (nonatomic, assign)   int64_t     pkPulishmentTime;
@property (nonatomic, assign)   int64_t     currentTime;
@property (nonatomic, assign)   int64_t     inviteeRewards;
@property (nonatomic, assign)   int64_t     inviterRewards;

@end

/**
 打赏用户
 */
@interface NETSPassThroughHandleRewardUser : NSObject

@property (nonatomic, copy)     NSString    *accountId; // 用户id
@property (nonatomic, copy)     NSString    *imAccid;   // im accid
@property (nonatomic, copy)     NSString    *nickname;  // 昵称
@property (nonatomic, copy)     NSString    *avatar;    // 头像地址
@property (nonatomic, assign)   int32_t     rewardCoin; // 该直播贡献总云币数

- (nullable NSDictionary *)rewardUserDictionary;

@end

/**
 打赏消息体
 */
@interface NETSPassThroughHandleRewardData : NSObject

@property (nonatomic, assign)   int32_t     giftId;         // 礼物ID
@property (nonatomic, copy)     NSString    *nickname;      // 打赏观众昵称

@property (nonatomic, copy)     NSString    *operUser;      // 观众账号
@property (nonatomic, copy)     NSString    *fromUser;      // 打赏账号
@property (nonatomic, copy)     NSString    *fromUserAvRoomUid;             // 主播 roomUid
@property (nonatomic, copy)     NSString    *roomCid;       // 直播房间频道号
@property (nonatomic, assign)   int64_t     pkStartTime;    // PK开始时间
@property (nonatomic, assign)   int64_t     pkEndTime;      // PK结束时间
@property (nonatomic, assign)   int64_t     currentTime;    // 当前时间
@property (nonatomic, strong)   NSArray<NETSPassThroughHandleRewardUser *>     *rewardPkList;       // PK贡献榜
@property (nonatomic, strong)   NSArray<NETSPassThroughHandleRewardUser *>     *inviteeRewardPkList;// PK贡献榜
@property (nonatomic, assign)   int32_t     inviterRewardPKCoinTotal;       // PK中邀请者云币总贡献数
@property (nonatomic, assign)   int32_t     inviteeRewardPKCoinTotal;       // PK中被邀请者云币总贡献数
@property (nonatomic, assign)   int32_t     rewardCoinTotal;                // 邀请者云币总贡献数
@property (nonatomic, assign)   int32_t     inviteeRewardCoinTotal;         // 被邀请者云币总贡献数
@property (nonatomic, assign)   int32_t     memberTotal;                    // 成员总数

/// 打赏者头像
- (nullable NSArray<NSString *> *)rewardAvatars;
- (nullable NSArray<NSString *> *)inviteeRewardAvatars;

@end

/**
 pk结束消息体
 */
@interface NETSPassThroughHandlePkEndData : NSObject

@property (nonatomic, copy)     NSString    *operUser;
@property (nonatomic, copy)     NSString    *fromUser;
@property (nonatomic, copy)     NSString    *fromUserAvRoomUid;
@property (nonatomic, copy)     NSString    *roomCid;
@property (nonatomic, assign)   int64_t     pkStartTime;
@property (nonatomic, assign)   int64_t     pkPulishmentTime;
@property (nonatomic, assign)   int64_t     currentTime;
@property (nonatomic, copy)     NSString    *closedAccountId;
@property (nonatomic, copy)     NSString    *closedNickname;
@property (nonatomic, copy)     NSString    *countdownEnd;

@end

/**
 pk结束消息体
 */
@interface NETSPassThroughHandleStartLiveData : NSObject

@property (nonatomic, copy)     NSString    *fromUserAvRoomUid;
@property (nonatomic, copy)     NSString    *roomCid;
@property (nonatomic, assign)   int64_t     currentTime;

@end

/**
 加入PK直播间反馈数据
 */
@interface NETSLiveRoomJoinPkRoomData: NSObject

@property (nonatomic, copy)     NSString    *avRoomCName;   // 音视频房间的channelName
@property (nonatomic, copy)     NSString    *avRoomCid;     // 音视频房间id
@property (nonatomic, assign)   int64_t     avRoomUid;      // 成员在音视频房间中用户id
@property (nonatomic, copy)     NSString    *avRoomCheckSum;// token,加入音视频房间用的鉴权
@property (nonatomic, assign)   int64_t     createTime;     // 房间的创建时间
@property (nonatomic, assign)   int32_t     duration;       // 房间已经持续的时间
@property (nonatomic, copy)     NSString    *roomKey;       // appId 和 mpRoomId 加密后的key
@property (nonatomic, assign)   int64_t     roomUniqueId;   // 房间在数据库中的唯一id
@property (nonatomic, copy)     NSString    *liveCid;       // 直播号
@property (nonatomic, copy)     NSString    *nrtcAppKey;    // nrtc的appKey

@end

/**
 pk结果返回数据
 */
@interface NETSLivePkResultData : NSObject

@property (nonatomic, copy)     NSString    *invitee;           // 被要请者账号
@property (nonatomic, copy)     NSString    *inviteeLiveCid;    // 被邀请者的直播房间号
@property (nonatomic, assign)   int64_t     inviteeRewards;     // 被邀请者打赏总额
@property (nonatomic, copy)     NSString    *liveCid;           // 直播房间号
@property (nonatomic, assign)   int64_t     inviterRewards;     // 邀请者打赏总额
@property (nonatomic, assign)   int64_t     pkEndTime;          // PK结束时间
@property (nonatomic, assign)   int64_t     pkStartTime;        // PK开始时间
@property (nonatomic, assign)   int64_t     punishmentStartTime;    // 惩罚开始时间
@property (nonatomic, copy)     NSString    *roomCid;           // 直播房间CId
@property (nonatomic, assign)   int32_t     status;             // 直播状态
@property (nonatomic, copy)     NSString    *inviter;           // 邀请者账号
@property (nonatomic, copy)     NSString    *inviterLiveCid;    // 邀请者原直播号

@end

/**
 PK打赏者模型
 */
@interface NETSPkLiveContriRewarder : NSObject

@property (nonatomic, copy)     NSString    *accountId;         // 打赏者账号
@property (nonatomic, copy)     NSString    *imAccid;           // 打赏者IM账号
@property (nonatomic, copy)     NSString    *nickname;          // 打赏者昵称
@property (nonatomic, copy)     NSString    *avatar;            // 打赏者头像
@property (nonatomic, assign)   int32_t     rewardCoin;         // 打赏金额

@end

/**
 获取PK打赏集合接口数据
 */
@interface NETSPkLiveContriList : NSObject

@property (nonatomic, strong)   NSArray<NETSPkLiveContriRewarder *> *rewardRankVOList;  // 打赏者列表
@property (nonatomic, assign)   int32_t     rewardCoinTotal;    // 打赏总额

/// 获取打赏者头像集合
- (nullable NSArray<NSString *> *)rewardAvatars;

@end

NS_ASSUME_NONNULL_END
