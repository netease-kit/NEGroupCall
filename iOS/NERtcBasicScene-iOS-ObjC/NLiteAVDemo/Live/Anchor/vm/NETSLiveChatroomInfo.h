//
//  NETSLiveChatroomInfo.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 聊天室成员角色
///
typedef NS_ENUM(NSUInteger, NETSLiveUserMode) {
    NETSLiveAnchor = 0,     // 主播
    NETSLiveAudience = 1    // 观众
};

///
/// 聊天室信息
///
@interface NETSLiveChatroomInfo : NSObject

@property (nonatomic, copy)     NSString    *roomId;
@property (nonatomic, copy)     NSString    *name;
@property (nonatomic, copy)     NSString    *creator;
@property (nonatomic, copy)     NSString    *thumbnail;
@property (nonatomic, assign)   NSInteger   onlineUserCount;
@property (nonatomic, assign)   uint64_t    createTime;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (BOOL)valid;

- (void)updateByChatroom:(NIMChatroom *)chatroom;

@end

NS_ASSUME_NONNULL_END
