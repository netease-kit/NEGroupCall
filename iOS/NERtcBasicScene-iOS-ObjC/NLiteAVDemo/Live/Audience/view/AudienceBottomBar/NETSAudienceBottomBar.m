//
//  NETSAudienceBottomBar.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSAudienceBottomBar.h"
#import "UIView+NTES.h"
#import "NETSToast.h"

@interface NETSAudienceBottomBar ()

@property (nonatomic, strong, readwrite) UITextField *textField;
@property (nonatomic, strong)   UILabel         *textLabel;
@property (nonatomic, strong)   UIButton        *giftBtn;
@property (nonatomic, strong)   UIButton        *closeBtn;
@end

@implementation NETSAudienceBottomBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.textField];
        [self addSubview:self.textLabel];
        [self addSubview:self.giftBtn];
        [self addSubview:self.closeBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    self.textField.frame = CGRectMake(8, 0, self.width - 16 - 36 * 2 - 10 * 2, 36);
    self.textLabel.frame = CGRectMake(8, 0, self.width - 16 - 36 * 2 - 10 * 2, 36);
    self.giftBtn.frame = CGRectMake(self.textLabel.right + 10, 0, 36, 36);
    self.closeBtn.frame = CGRectMake(self.giftBtn.right + 10, 0, 36, 36);
}

- (void)clickButton:(UIButton *)button
{
    if (button == self.giftBtn && self.delegate && [self.delegate respondsToSelector:@selector(clickGiftBtn)]) {
        [self.delegate clickGiftBtn];
    }
    if (button == self.closeBtn && self.delegate && [self.delegate respondsToSelector:@selector(clickCloseBtn)]) {
        [self.delegate clickCloseBtn];
    }
}

- (void)tapInputLabel:(UITapGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickTextLabel:)]) {
        [self.textField becomeFirstResponder];
        [self.delegate clickTextLabel:self.textLabel];
    }
}

- (void)resignFirstResponder
{
    [self.textField resignFirstResponder];
}

#pragma mark - lazy load

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = [UIColor clearColor];
    }
    return _textField;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = HEXCOLOR(0x0C0C0D);
        _textLabel.layer.cornerRadius = 18;
        _textLabel.layer.masksToBounds = YES;
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.textColor = HEXCOLOR(0x666666);
        _textLabel.text = @"    说点什么...";
        
        _textLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInputLabel:)];
        [_textLabel addGestureRecognizer:tap];
    }
    return _textLabel;
}

- (UIButton *)giftBtn
{
    if (!_giftBtn) {
        _giftBtn = [[UIButton alloc] init];
        [_giftBtn setImage:[UIImage imageNamed:@"send_gift_ico"] forState:UIControlStateNormal];
        [_giftBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _giftBtn;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:[UIImage imageNamed:@"cha_ico"] forState:UIControlStateNormal];
        _closeBtn.layer.cornerRadius = 18;
        _closeBtn.layer.masksToBounds = YES;
        _closeBtn.backgroundColor = HEXCOLORA(0x0C0C0D, 0.6);
        [_closeBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

@end
