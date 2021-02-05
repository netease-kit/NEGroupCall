//
//  NETSInviteeInfoView.m
//  NLiteAVDemo
//
//  Created by Think on 2021/1/10.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSInviteeInfoView.h"
#import "UIView+NTES.h"

@interface NETSInviteeInfoView ()

/// 头像展示控件
@property (nonatomic, strong)   UIImageView *avatar;
/// 昵称展示控件
@property (nonatomic, strong)   UILabel     *nickname;

@end

@implementation NETSInviteeInfoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        
        [self addSubview:self.avatar];
        [self addSubview:self.nickname];
    }
    return self;
}

- (void)layoutSubviews
{
    self.avatar.frame = CGRectMake(2, 2, 20, 20);
    self.nickname.frame = CGRectMake(self.avatar.right + 2, 0, self.width - 20 - 4 - 2, self.height);
}

- (void)setFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, 82, 24);
    [super setFrame:rect];
}

- (void)reloadAvatar:(NSString *)avatar
            nickname:(NSString *)nickname
{
    if (isEmptyString(avatar) || isEmptyString(nickname)) {
        NETSLog(@"passthrough透传被邀请者头像或昵称为空");
    }
    NSURL *avatarUrl = [NSURL URLWithString:avatar];
    [self.avatar sd_setImageWithURL:avatarUrl];
    self.nickname.text = nickname;
}

#pragma mark - lazy load

- (UIImageView *)avatar
{
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
        _avatar.layer.cornerRadius = 10;
        _avatar.layer.masksToBounds = YES;
    }
    return _avatar;
}

- (UILabel *)nickname
{
    if (!_nickname) {
        _nickname = [[UILabel alloc] init];
        _nickname.font = [UIFont systemFontOfSize:12];
        _nickname.textColor = [UIColor whiteColor];
    }
    return _nickname;
}

@end
