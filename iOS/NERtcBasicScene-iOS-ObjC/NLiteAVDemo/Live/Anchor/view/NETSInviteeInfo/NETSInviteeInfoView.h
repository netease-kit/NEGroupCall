//
//  NETSInviteeInfoView.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/10.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NETSInviteeInfoView : UIView

/**
 加载被邀请者信息
 @param avatar      - 被邀请者头像
 @param nickname    - 被邀请者昵称
 */
- (void)reloadAvatar:(NSString *)avatar
            nickname:(NSString *)nickname;

@end

NS_ASSUME_NONNULL_END
