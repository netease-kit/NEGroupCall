//
//  NEEvaluateTask.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEEvaluateTask : NETask
/// 反馈类型：0:坏 1:好
@property(strong,nonatomic)NSNumber *req_feedback_type;
/// 101 听不到声音 102 机械音、杂音 103 声音卡顿 104 看不到画面 105 画面卡顿 106 画面模糊 107 声音画面不同步 108 意外退出 99 其他
@property(strong,nonatomic)NSArray <NSNumber *>*req_conetent_type;
@property(strong,nonatomic)NSString *req_content;
/// 手机号
@property(strong,nonatomic)NSString *req_contact;

/// 反馈来源于哪个demo “一对一视频通话Demo“ ”多人视频通话Demo“ ”主播PK Demo“
@property(strong,nonatomic)NSString *req_feedback_source;
/// 1:非通话中 2:通话中
@property(assign,nonatomic)NSInteger req_type;

/// 用户ID
@property(strong,nonatomic)NSString *req_uid;
/// 房间ID
@property(strong,nonatomic)NSString *req_cid;
/// AppID
@property(strong,nonatomic)NSString *req_appid;
/// AppKey
@property(strong,nonatomic)NSString *req_appkey;

@end

NS_ASSUME_NONNULL_END
