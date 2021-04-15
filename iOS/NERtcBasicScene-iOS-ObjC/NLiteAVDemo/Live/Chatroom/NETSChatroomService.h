//
//  NETSChatroomService.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/7.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>
#import "NETSLiveModel.h"
#import "NETSGiftModel.h"
#import "NETSLiveAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface NETSChatroomService : NSObject

/**
 进入聊天室
 @param roomId      - 聊天室ID
 @param userMode    - 用户角色
 @param success     - 进入聊天室成功闭包
 @param failed      - 进入聊天室失败闭包
 */
+ (void)enterWithRoomId:(NSString *)roomId
               userMode:(NETSUserMode)userMode
                success:(void(^ _Nullable )(NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me))success
                 failed:(void(^ _Nullable )(NSError * _Nullable error))failed;

/**
 退出聊天室
 @param roomId      - 聊天室ID
 */
+ (void)exitWithRoomId:(NSString *)roomId;

/**
 查实聊天室主播是否在线,以此判断直播间主播是否在线
 @param roomId  - 聊天室ID
 */
+ (void)isOnlineWithRoomId:(NSString *)roomId completion:(void(^)(BOOL isOnline))completion;

/**
 聊天室发送消息
 @param message     - 发送消息
 @param inRoomId    - 聊天室ID
 @param userMode    - 用户角色
 @param nickname    - 用户昵称
 @param errorPtr    - 错误句柄
 */
+ (void)sendMessage:(NSString *)message
           inRoomId:(NSString *)inRoomId
           userMode:(NETSUserMode)userMode
           nickname:(NSString *)nickname
           errorPtr:(NSError * __nullable *)errorPtr;

/**
 获取聊天室成员信息
 @param roomId          - 聊天室ID
 @param limit           - 查询人数
 @param successBlock    - 查询人数
 @param failedBlock     - 成功闭包
 */
+ (void)fetchMembersRoomId:(NSString *)roomId
                     limit:(int32_t)limit
              successBlock:(void(^)(NSArray<NIMChatroomMember *> * _Nullable))successBlock
               failedBlock:(void(^)(NSError *))failedBlock;

///
///
///

/**
发送pk开始/结束消息
@param state       - pk状态
*/
+ (NIMMessage *)pkMessageWithState:(NETSLivePkState)state
                  startedTimestamp:(int64_t)startedTimestamp
                  currentTimestamp:(int64_t)currentTimestamp
               otherAnchorNickname:(NSString *)otherAnchorNickname
                 otherAnchorAvatar:(NSString *)otherAnchorAvatar
                  currentAnchorWin:(BOOL)currentAnchorWin;

/**
 发送pk惩罚信息
 */
+ (NIMMessage *)punishMessageWithState:(NETSLivePkState)state
                      startedTimestamp:(int64_t)startedTimestamp
                      currentTimestamp:(int64_t)currentTimestamp
                   otherAnchorNickname:(NSString *)otherAnchorNickname
                     otherAnchorAvatar:(NSString *)otherAnchorAvatar;

/**
 主播云币变化消息
 @param nickname            - 打赏者昵称
 @param giftId              - 打赏礼物ID
 @param fromUserAvRoomUid   - 用户打赏坐在房间主播ID
 @param totalCoinCount      - 当前主播云币总数
 @param pkCoinCount         - 所在房间主播pk值
 @param otherPKCoinCount    - pk主播pk值
 @param originRewardList    - 所在房间主播贡献列表
 @param originOtherRewardList   - 对方主播房间贡献列表
 */
+ (NIMMessage *)rewardeMessageWithNickname:(NSString *)nickname
                                    giftId:(int32_t)giftId
                         fromUserAvRoomUid:(NSString *)fromUserAvRoomUid
                            totalCoinCount:(int32_t)totalCoinCount
                               pkCoinCount:(int32_t)pkCoinCount
                          otherPKCoinCount:(int32_t)otherPKCoinCount
                          originRewardList:(NSArray<NETSPassThroughHandleRewardUser *> * _Nullable)originRewardList
                     originOtherRewardList:(NSArray<NETSPassThroughHandleRewardUser *> * _Nullable)originOtherRewardList;

/**
 向聊天室发送消息
 @param message         - 聊天室ID
 @param roomId          - 聊天室ID
 @param errorPtr        - 错误句柄
 */
+ (void)sendMessage:(NIMMessage *)message
             roomId:(NSString *)roomId
           errorPtr:(NSError * __nullable *)errorPtr;

@end

NS_ASSUME_NONNULL_END
