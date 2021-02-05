//
//  NETSAnchorTopInfoView.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 主播端 开播后 显示主播信息视图
/// 固定尺寸 124*36
///

@interface NETSAnchorTopInfoView : UIView

/// 当前财富值
@property (nonatomic, assign)   int32_t     wealth;
/// 昵称
@property (nonatomic, copy)     NSString    *nickname;
/// 头像url
@property (nonatomic, copy)     NSString    *avatarUrl;

///
/// 安装信息视图
/// @param avatar   - 主播头像
/// @param nickname - 主播昵称
/// @param wealth   - 主播财富
///
- (void)installWithAvatar:(NSString *)avatar
                 nickname:(NSString *)nickname
                   wealth:(int32_t)wealth;

///
/// 更新云币数
/// @param coins    - 最新云币数
///
- (void)updateCoins:(int32_t)coins;

@end

NS_ASSUME_NONNULL_END
