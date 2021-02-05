//
//  NETSBaseActionSheet.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSBaseActionSheet.h"
#import "UIButton+NTES.h"
#import "TopmostView.h"
#import "UIImage+NTES.h"

@interface NETSBaseActionSheet () <UIGestureRecognizerDelegate>

@end

@implementation NETSBaseActionSheet

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    
        self.titleLab.text = title;
        [self setupTitLabel];
        [self setupSubViews];
    }
    return self;
}

/// 创建标题相关视图
- (void)setupTitLabel
{
    [self addSubview:self.content];
    [self.content addSubview:self.titleLab];
    [self.content addSubview:self.resetBtn];
    [self.content addSubview:self.topLine];
    
    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.content);
        make.size.mas_equalTo(CGSizeMake(150, 48));
        make.centerX.equalTo(self.content);
    }];
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLab);
        make.right.equalTo(self.content).offset(-20);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.content).offset(48);
        make.height.mas_equalTo(0.5);
        make.left.right.equalTo(self.content);
    }];
}

- (void)resetSetting:(UIButton *)sender
{
    // need override
}

- (void)setupSubViews
{
     // need override
}

- (void)dismiss
{
    [self removeFromSuperview];
    
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    topmostView.userInteractionEnabled = _topUserInteractionEnabled;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 点击内容区不响应 背景点击 事件
    if ([touch.view isDescendantOfView:self.content]) {
        return NO;
    }
    return YES;
}

#pragma mark - lazy load

- (UIView *)content
{
    if (!_content) {
        _content = [[UIView alloc] init];
        _content.backgroundColor = [UIColor whiteColor];
    }
    return _content;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = HEXCOLOR(0x0F0C0A);
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UIButton *)resetBtn
{
    if (!_resetBtn) {
        _resetBtn = [[UIButton alloc] init];
        UIImage *image = [[UIImage imageNamed:@"refresh_ico"] ne_imageWithTintColor:HEXCOLOR(0xABAEB3)];
        [_resetBtn setImage:image forState:UIControlStateNormal];
        [_resetBtn addTarget:self action:@selector(resetSetting:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}

- (UIView *)topLine
{
    if (!_topLine) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = HEXCOLOR(0xd2d2d2);
    }
    return _topLine;;
}

@end
