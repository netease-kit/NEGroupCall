//
//  NETSInvitingBar.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSInvitingBar.h"
#import "UIView+NTES.h"
#import "TopmostView.h"

@interface NETSInvitingBar ()

@property (nonatomic, strong)   UIView      *bgView;
@property (nonatomic, strong)   UILabel     *tip;
@property (nonatomic, strong)   UIButton    *cancel;
@property (nonatomic, assign)   BOOL        topUserInteractionEnabled;
@property (nonatomic, weak)     id<NETSInvitingBarDelegate> delegate;

@end

@implementation NETSInvitingBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bgView];
        [self.bgView addSubview:self.tip];
        [self.bgView addSubview:self.cancel];
    }
    return self;
}

- (void)layoutSubviews
{
    self.bgView.frame = CGRectMake(8, kIsFullScreen ? 118 : 94, self.width - 16, 44);
    self.tip.frame = CGRectMake(12, 11, self.bgView.width - 36 - 52, 22);
    self.cancel.frame = CGRectMake(self.bgView.width - 12 - 52, 8, 52, 28);
}

+ (NETSInvitingBar *)showInvitingWithTarget:(id)target title:(NSString *)title
{
    CGRect frame = [UIScreen mainScreen].bounds;
    NETSInvitingBar *bar = [[NETSInvitingBar alloc] initWithFrame:frame];
    bar.tip.text = title;
    bar.delegate = target;
    
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    
    /// 暂存顶层视图交互设置
    bar.topUserInteractionEnabled = topmostView.userInteractionEnabled;
    
    topmostView.userInteractionEnabled = YES;
    [topmostView addSubview:bar];
    
    return bar;
}

- (void)cancelAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCancelInviting)]) {
        [self.delegate clickCancelInviting];
    }
    [self dismiss];
}

- (void)dismiss
{
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    topmostView.userInteractionEnabled = _topUserInteractionEnabled;
    [self removeFromSuperview];
}

#pragma mark - lazy load

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _bgView.layer.cornerRadius = 4;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UILabel *)tip
{
    if (!_tip) {
        _tip = [[UILabel alloc] init];
        _tip.font = [UIFont systemFontOfSize:14];
        _tip.textColor = [UIColor whiteColor];
    }
    return _tip;
}

- (UIButton *)cancel
{
    if (!_cancel) {
        _cancel = [[UIButton alloc] init];
        _cancel.layer.cornerRadius = 4;
        _cancel.layer.masksToBounds = YES;
        _cancel.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_cancel setTitle:@"取消" forState:UIControlStateNormal];
        [_cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, 0, 52, 28);
        gradientLayer.colors = @[(__bridge id)[HEXCOLOR(0xfa555f) colorWithAlphaComponent:1.0].CGColor,
                                 (__bridge id)[HEXCOLOR(0xd846f6) colorWithAlphaComponent:1.0].CGColor];
        gradientLayer.startPoint = CGPointMake(.0, .0);
        gradientLayer.endPoint = CGPointMake(1.0, 0.0);

        [_cancel.layer insertSublayer:gradientLayer atIndex:0];
    }
    return _cancel;
}

@end
