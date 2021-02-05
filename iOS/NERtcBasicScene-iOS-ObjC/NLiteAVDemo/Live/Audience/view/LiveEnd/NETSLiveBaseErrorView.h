//
//  NETSLiveBaseErrorView.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/18.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 直播结束视图
 */

@interface NETSLiveBaseErrorView : UIImageView

@property (nonatomic, strong)   UIImageView *avatarView;
@property (nonatomic, strong)   UILabel     *nameLab;
@property (nonatomic, strong)   UIView      *topDivide;
@property (nonatomic, strong)   UILabel     *statusLab;
@property (nonatomic, strong)   UIView      *botDivide;

/**
 安装视图
 @param avatar      - 头像链接
 @param nickname    - 昵称
 */
- (void)installWithAvatar:(NSString *)avatar
                 nickname:(NSString *)nickname;

- (void)setupSubviews;

@end

NS_ASSUME_NONNULL_END
