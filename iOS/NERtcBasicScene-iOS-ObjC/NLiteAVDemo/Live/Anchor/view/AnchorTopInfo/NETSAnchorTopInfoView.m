//
//  NETSAnchorTopInfoView.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSAnchorTopInfoView.h"
#import "UIView+NTES.h"
#import "NETSLiveUtils.h"

@interface NETSAnchorTopInfoView ()

/// 头像视图
@property (nonatomic, strong)   UIImageView *avatar;
/// 昵称视图
@property (nonatomic, strong)   UILabel     *nick;
/// 财富视图
@property (nonatomic, strong)   UILabel     *money;

@end

@implementation NETSAnchorTopInfoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        self.layer.cornerRadius = 18;
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.avatar];
        [self addSubview:self.nick];
        [self addSubview:self.money];
    }
    return self;
}

- (void)installWithAvatar:(NSString *)avatar nickname:(NSString *)nickname wealth:(int32_t)wealth;
{
    self.wealth = wealth;
    self.avatarUrl = avatar;
    self.nickname = nickname;
}

- (void)setNickname:(NSString *)nickname
{
    if ([_nickname isEqualToString:nickname]) {
        return;
    }
    _nickname = nickname;
    _nick.text = nickname;
}

- (void)setAvatarUrl:(NSString *)avatarUrl
{
    if ([_avatarUrl isEqualToString:avatarUrl]) {
        return;
    }
    _avatarUrl = avatarUrl;
    [_avatar sd_setImageWithURL:[NSURL URLWithString:avatarUrl]];
}

- (void)setFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, 124, 36);
    [super setFrame:rect];
}

- (void)setWealth:(int32_t)wealth
{
    _wealth = wealth;
    _money.text = [NSString stringWithFormat:@"%d云币", wealth];
}

- (void)layoutSubviews
{
    self.avatar.frame = CGRectMake(0, 0, 36, 36);
    self.nick.frame = CGRectMake(self.avatar.right + 4, 4, 72, 14);
    self.money.frame = CGRectMake(self.nick.left, self.nick.bottom, self.nick.width, self.nick.height);
}

- (void)updateCoins:(int32_t)coins
{
    self.wealth = coins;
}

#pragma mark - lazy load

- (UIImageView *)avatar
{
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
        _avatar.layer.cornerRadius = 18;
        _avatar.layer.masksToBounds = YES;
    }
    return _avatar;
}

- (UILabel *)nick
{
    if (!_nick) {
        _nick = [[UILabel alloc] init];
        _nick.font = [UIFont systemFontOfSize:12];
        _nick.textColor = [UIColor whiteColor];
    }
    return _nick;
}

- (UILabel *)money
{
    if (!_money) {
        _money = [[UILabel alloc] init];
        _money.font = [UIFont systemFontOfSize:10];
        _money.textColor = [UIColor whiteColor];
    }
    return _money;
}

@end
