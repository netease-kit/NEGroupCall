//
//  NEModifyNicknameTask.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEModifyNicknameTask : NETask
@property(strong,nonatomic)NSString *req_nickname;
@end

NS_ASSUME_NONNULL_END
