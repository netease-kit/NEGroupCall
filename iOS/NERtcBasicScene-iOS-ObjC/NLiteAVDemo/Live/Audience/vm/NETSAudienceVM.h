//
//  NETSAudienceVM.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NETSLiveChatroomInfo.h"
#import "NETSLiveConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface NETSAudienceVM : NSObject

/// 聊天室信息
@property (nonatomic, strong) NETSLiveChatroomInfo  *chatroom;

@end

NS_ASSUME_NONNULL_END
