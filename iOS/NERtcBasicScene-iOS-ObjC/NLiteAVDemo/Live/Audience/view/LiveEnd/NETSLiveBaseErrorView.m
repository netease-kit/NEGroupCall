//
//  NETSLiveBaseErrorView.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/18.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveBaseErrorView.h"
#import <Masonry/Masonry.h>

@interface NETSLiveBaseErrorView ()

@property (nonatomic, strong)   UIVisualEffectView  *effectView;
@property (nonatomic, strong)   UIImageView *upArraw;
@property (nonatomic, strong)   UIImageView *pointView;
@property (nonatomic, strong)   UILabel     *tipLab;
@property (nonatomic, strong)   UIImageView *downArraw;

@end

@implementation NETSLiveBaseErrorView

- (instancetype)init
{
    CGRect frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    [self addSubview:self.effectView];
    [self addSubview:self.avatarView];
    [self addSubview:self.nameLab];
    [self addSubview:self.topDivide];
    [self addSubview:self.statusLab];
    [self addSubview:self.botDivide];
    [self addSubview:self.upArraw];
    [self addSubview:self.pointView];
    [self addSubview:self.tipLab];
    [self addSubview:self.downArraw];
    
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    CGFloat topOffset = (kIsFullScreen ? 44 : 20) + 72;
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(topOffset);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.avatarView.mas_bottom).offset(12);
        make.height.mas_equalTo(25);
    }];
    [self.topDivide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(68);
        make.right.equalTo(self).offset(-68);
        make.top.equalTo(self.nameLab.mas_bottom).offset(24);
        make.height.mas_equalTo(0.5);
    }];
    [self.statusLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.topDivide.mas_bottom).offset(20);
        make.height.mas_equalTo(33);
    }];
    [self.botDivide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.topDivide);
        make.top.equalTo(self.statusLab.mas_bottom).offset(20);
    }];
    [self.upArraw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.botDivide.mas_bottom).offset(144);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [self.pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.upArraw.mas_bottom).offset(12);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.pointView.mas_bottom).offset(4);
        make.height.mas_equalTo(20);
    }];
    [self.downArraw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.tipLab.mas_bottom).offset(16);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}

- (void)installWithAvatar:(NSString *)avatar nickname:(NSString *)nickname
{
    NSURL *url = [NSURL URLWithString:avatar];
    [self sd_setImageWithURL:url];
    [self.avatarView sd_setImageWithURL:url];
    self.nameLab.text = nickname;
}

#pragma mark - lazy load

- (UIVisualEffectView *)effectView
{
    if (!_effectView) {
        UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectView = [[UIVisualEffectView alloc]initWithEffect:beffect];
    }
    return _effectView;
}

- (UIImageView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 50;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)nameLab
{
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = [UIFont systemFontOfSize:18];
        _nameLab.textColor = [UIColor whiteColor];
        _nameLab.textAlignment =NSTextAlignmentCenter;
    }
    return _nameLab;
}

- (UIView *)topDivide
{
    if (!_topDivide) {
        _topDivide = [[UIView alloc] init];
        _topDivide.backgroundColor = [UIColor whiteColor];
        _topDivide.alpha = 0.7;
    }
    return _topDivide;
}

- (UILabel *)statusLab
{
    if (!_statusLab) {
        _statusLab = [[UILabel alloc] init];
        _statusLab.font = [UIFont systemFontOfSize:24];
        _statusLab.textColor = [UIColor whiteColor];
        _statusLab.textAlignment =NSTextAlignmentCenter;
        _statusLab.text = @"直播已结束";
    }
    return _statusLab;
}

- (UIView *)botDivide
{
    if (!_botDivide) {
        _botDivide = [[UIView alloc] init];
        _botDivide.backgroundColor = [UIColor whiteColor];
        _botDivide.alpha = 0.7;
    }
    return _botDivide;
}

@end
