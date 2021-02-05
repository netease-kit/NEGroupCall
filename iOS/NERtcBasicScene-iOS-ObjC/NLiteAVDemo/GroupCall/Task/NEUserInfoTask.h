//
//  NEUserInfoTask.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEUserInfoTask : NETask
/// 房间号
@property(strong,nonatomic)NSString *req_mpRoomId;
/// 音视频房间uid
@property(strong,nonatomic)NSString *req_avRoomUid;
/// 昵称
@property(strong,nonatomic)NSString *nickname;
/// 用户id
@property(strong,nonatomic)NSString *accountId;

@end

NS_ASSUME_NONNULL_END
