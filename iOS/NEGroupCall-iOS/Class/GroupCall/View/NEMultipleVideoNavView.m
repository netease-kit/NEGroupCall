//
//  NEMultipleVideoNavView.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/3/10.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEMultipleVideoNavView.h"


@interface NEMultipleVideoNavView()
@property (nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) UIButton *setupButton;

@end

@implementation NEMultipleVideoNavView

- (void)ne_setupViews {
    self.backgroundColor = KThemColor;
    [self addSubview:self.backButton];
    [self addSubview:self.titleLabel];
    [self addSubview:self.setupButton];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.backButton);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.bottom.mas_equalTo(-12);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    
    [self.setupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12);
        make.bottom.mas_equalTo(-12);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
}

- (void)ne_bindViewModel {
    @weakify(self)

    [[self.backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self.backSubject sendNext:nil];
    }];
    
    [[self.setupButton rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self.setupSubject sendNext:nil];

    }];
    
}

#pragma mark - Lazy
-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.text = @"加入频道";
    }
    return _titleLabel;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc]init];
        [_backButton setImage:[UIImage imageNamed:@"back_ico"] forState:UIControlStateNormal];
        [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 40)];
    }
    return _backButton;
}

- (UIButton *)setupButton {
    if (!_setupButton) {
        _setupButton = [[UIButton alloc]init];
        [_setupButton setImage:[UIImage imageNamed:@"setup_icon"] forState:UIControlStateNormal];
        [_setupButton setImageEdgeInsets:UIEdgeInsetsMake(0, 40, 0, 0)];
    }
    return _setupButton;
}

@end
