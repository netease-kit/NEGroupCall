//
//  NETSLiveAttachment.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>
#import "NETSLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

// PK直播自定义消息类型
typedef NS_ENUM(NSUInteger, NETSLiveAttachmentType) {
    NETSLiveAttachmentPkType        = 11,   // PK消息
    NETSLiveAttachmentPunishType    = 12,   // 惩罚消息
    NETSLiveAttachmentWealthType    = 14,   // 主播云币变化消息
    NETSLiveAttachmentTextType      = 15    // 文本消息
};

// PK状态枚举
typedef NS_ENUM(NSUInteger, NETSLivePkState) {
    NETSLiveAttachmentStatusStart   = 0,    // 开始状态
    NETSLiveAttachmentStatusEnd     = 1     // 结束状态
};

/**
 惩罚阶段消息序列化
 */
@interface NETSLivePunishAttachment : NSObject<NIMCustomAttachment>

@property (nonatomic, assign, readonly)   NETSLiveAttachmentType  type;
@property (nonatomic, assign)   NETSLivePkState         state;
// 开始 pk 时间戳，state为 1 时字段忽略
@property (nonatomic, assign)   int64_t                 startedTimestamp;
// 当前服务器时间戳，state 为 1 时忽略
@property (nonatomic, assign)   int64_t                 currentTimestamp;
// 对方主播昵称
@property (nonatomic, copy)     NSString                *otherAnchorNickname;
// 对方主播头像链接
@property (nonatomic, copy)     NSString                *otherAnchorAvatar;

+ (nullable NETSLivePunishAttachment *)getAttachmentWithMessage:(NIMMessage *)message;

@end

/**
 PK阶段消息序列化
 */
@interface NETSLivePKAttachment : NETSLivePunishAttachment

// 结束 pk 结果，表示当前观众所在房间主播是否胜利，state 为 0 时忽略
@property (nonatomic, assign)   BOOL                    currentAnchorWin;

+ (nullable NETSLivePKAttachment *)getAttachmentWithMessage:(NIMMessage *)message;

@end

/**
 主播云币变化消息序列化
 */
@interface NETSLiveWealthChangeAttachment : NSObject<NIMCustomAttachment>

@property (nonatomic, assign, readonly)   NETSLiveAttachmentType  type;
@property (nonatomic, assign)   int32_t     giftId;                         // 打赏礼物id
@property (nonatomic, copy)     NSString    *nickname;                      // 打赏观众昵称
@property (nonatomic, assign)   int32_t     totalCoinCount;                 // 当前主播云币总数
@property (nonatomic, assign)   int32_t     PKCoinCount;                    // 所在房间主播pk值
@property (nonatomic, assign)   int32_t     otherPKCoinCount;               // pk 主播 pk 值
@property (nonatomic, strong)   NSArray<NETSPassThroughHandleRewardUser *>  *originRewardList;        // 所在房间主播 贡献列表
@property (nonatomic, strong)   NSArray<NSDictionary *>  *rewardList;       // 所在房间主播 贡献列表
@property (nonatomic, strong)   NSArray<NETSPassThroughHandleRewardUser *>  *originOtherRewardList;   // 所在房间主播 贡献列表
@property (nonatomic, strong)   NSArray<NSDictionary *>  *otherRewardList;  // 所在房间主播 贡献列表
@property (nonatomic, copy)     NSString    *fromUserAvRoomUid;             // 打赏用户所在房间主播id

/**
 从NIMMessage中获取pk双方财富附件
 @param message - NIMMessage
 */
+ (nullable NETSLiveWealthChangeAttachment *)getAttachmentWithMessage:(NIMMessage *)message;

/// 获取打赏者头像集合
- (nullable NSArray<NSString *> *)originRewardAvatars;
- (nullable NSArray<NSString *> *)originOtherRewardAvatars;

@end

/**
 文本消息序列化
 */
@interface NETSLiveTextAttachment : NSObject<NIMCustomAttachment>

@property (nonatomic, assign, readonly)   NETSLiveAttachmentType  type;
@property (nonatomic, assign)   BOOL                    isAnchor;
@property (nonatomic, copy)     NSString                *message;

@end

///

/**
 PK直播消息反序列化
 */
@interface NETSLiveAttachmentDecoder : NSObject<NIMCustomAttachmentCoding>

@end

NS_ASSUME_NONNULL_END
