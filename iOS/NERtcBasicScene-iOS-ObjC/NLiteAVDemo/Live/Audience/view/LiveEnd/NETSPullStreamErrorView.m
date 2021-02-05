//
//  NETSPullStreamErrorView.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/18.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSPullStreamErrorView.h"

@interface NETSPullStreamErrorView ()

@property (nonatomic, strong)   UIButton    *backBtn;
@property (nonatomic, strong)   UIButton    *retryBtn;

@end

@implementation NETSPullStreamErrorView

- (void)setupSubviews
{
    [super setupSubviews];
    
    [self addSubview:self.backBtn];
    [self addSubview:self.retryBtn];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.botDivide.mas_bottom).offset(181);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self.retryBtn.mas_left).offset(-9);
        make.height.mas_equalTo(50);
        make.width.equalTo(self.retryBtn);
    }];
    [self.retryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.width.equalTo(self.backBtn);
        make.left.equalTo(self.backBtn.mas_right).offset(9);
        make.right.equalTo(self).offset(-20);
    }];
    
    self.statusLab.text = @"跟主播走丢了";
}

- (void)clickAction:(UIButton *)sender
{
    if (sender == self.backBtn) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickBackAction)]) {
            [self.delegate clickBackAction];
        }
    }
    if (sender == self.retryBtn) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickRetryAction)]) {
            [self.delegate clickRetryAction];
        }
    }
}

#pragma mark - lazy load

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _backBtn.layer.cornerRadius = 25;
        _backBtn.layer.masksToBounds = YES;
        _backBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _backBtn.layer.borderWidth = 1;
        [_backBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)retryBtn
{
    if (!_retryBtn) {
        _retryBtn = [[UIButton alloc] init];
        [_retryBtn setTitle:@"重新连接" forState:UIControlStateNormal];
        [_retryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _retryBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _retryBtn.layer.cornerRadius = 25;
        _retryBtn.layer.masksToBounds = YES;
        _retryBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _retryBtn.layer.borderWidth = 1;
        [_retryBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryBtn;
}

@end
