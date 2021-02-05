//
//  NETSLiveEndView.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/18.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveEndView.h"
#import "NENavigator.h"
#import "UIView+NTES.h"
@interface NETSLiveEndView ()

@property (nonatomic, strong)   UIImageView *upArraw;
@property (nonatomic, strong)   UIImageView *pointView;
@property (nonatomic, strong)   UILabel     *tipLab;
@property (nonatomic, strong)   UIImageView *downArraw;
@property(nonatomic, strong)    UIButton    *backButton;
@end

@implementation NETSLiveEndView

- (void)setupSubviews
{
    [super setupSubviews];
    self.userInteractionEnabled = YES;
    [self addSubview:self.upArraw];
    [self addSubview:self.pointView];
    [self addSubview:self.tipLab];
    [self addSubview:self.downArraw];
    [self addSubview:self.backButton];
    
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
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.botDivide.mas_bottom).offset(24);
        make.size.mas_equalTo(CGSizeMake(120, 50));
        make.centerX.equalTo(self);
    }];
    
    
}

- (void)installWithAvatar:(NSString *)avatar nickname:(NSString *)nickname
{
    NSURL *url = [NSURL URLWithString:avatar];
    [self sd_setImageWithURL:url];
    [self.avatarView sd_setImageWithURL:url];
    self.nameLab.text = nickname;
}

- (void)backButtonClickAction:(UIButton *)sender {
    [[NENavigator shared].navigationController popViewControllerAnimated:YES];
}

#pragma mark - lazy load

- (UIImageView *)upArraw
{
    if (!_upArraw) {
        UIImage *image = [UIImage imageNamed:@"up_arrow_ico"];
        _upArraw = [[UIImageView alloc] initWithImage:image];
    }
    return _upArraw;
}

- (UIImageView *)pointView
{
    if (!_pointView) {
        UIImage *image = [UIImage imageNamed:@"up_point_ico"];
        _pointView = [[UIImageView alloc] initWithImage:image];
    }
    return _pointView;
}

- (UILabel *)tipLab
{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.font = [UIFont systemFontOfSize:14];
        _tipLab.textColor = [UIColor whiteColor];
        _tipLab.textAlignment = NSTextAlignmentCenter;
        _tipLab.text = @"上下滑动,即可观看其他直播";
    }
    return _tipLab;
}

- (UIImageView *)downArraw
{
    if (!_downArraw) {
        UIImage *image = [UIImage imageNamed:@"down_arrow_ico"];
        _downArraw = [[UIImageView alloc] initWithImage:image];
    }
    return _downArraw;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [NETSViewFactory createSystemBtnFrame:CGRectZero title:@"返回" titleColor:UIColor.whiteColor backgroundColor:UIColor.clearColor target:self action:@selector(backButtonClickAction:)];
        _backButton.titleLabel.font = TextFont_16;
        _backButton.layer.cornerRadius = 25;
        _backButton.layer.borderColor = UIColor.whiteColor.CGColor;
        _backButton.layer.borderWidth = 1.0f;
    }
    return _backButton;;
}
@end
