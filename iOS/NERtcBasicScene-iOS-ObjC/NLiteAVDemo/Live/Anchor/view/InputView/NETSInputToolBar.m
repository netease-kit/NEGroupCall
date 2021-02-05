//
//  NETSInputToolBar.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSInputToolBar.h"
#import "UIView+NTES.h"

@interface NETSInputToolBar ()

@property (nonatomic, strong, readwrite)   UITextField     *textField;
@property (nonatomic, strong)   UILabel         *inputLab;
@property (nonatomic, strong)   UIButton        *beautyBtn;
@property (nonatomic, strong)   UIButton        *filterBtn;
@property (nonatomic, strong)   UIButton        *musicBtn;
@property (nonatomic, strong)   UIButton        *moreBtn;

@end

@implementation NETSInputToolBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.textField];
        [self addSubview:self.inputLab];
        [self addSubview:self.beautyBtn];
        [self addSubview:self.filterBtn];
        [self addSubview:self.musicBtn];
        [self addSubview:self.moreBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat inputWidth = self.width - 16 - 4 * 36 - 4 * 10;
    self.textField.frame = CGRectMake(8, 0, inputWidth, self.height);
    self.inputLab.frame = CGRectMake(8, 0, inputWidth, self.height);
    self.beautyBtn.frame = CGRectMake(self.inputLab.right + 10, 0, 36, 36);
    self.filterBtn.frame = CGRectMake(self.beautyBtn.right + 10, 0, 36, 36);
    self.musicBtn.frame = CGRectMake(self.filterBtn.right + 10, 0, 36, 36);
    self.moreBtn.frame = CGRectMake(self.musicBtn.right + 10, 0, 36, 36);
    self.textField.frame = self.inputLab.frame;
}

- (void)setFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 36);
    [super setFrame:rect];
}

- (void)clickButton:(UIButton *)button
{
    if (!(self.delegate && [self.delegate respondsToSelector:@selector(clickInputToolBarAction:)])) {
        return;
    }
    NETSInputToolBarAction action = NETSInputToolBarUnknown;
    if (button == self.beautyBtn) {
        action = NETSInputToolBarBeauty;
    } else if (button == self.filterBtn) {
        action = NETSInputToolBarFilter;
    } else if (button == self.musicBtn) {
        action = NETSInputToolBarMusic;
    } else if (button == self.moreBtn) {
        action = NETSInputToolBarMore;
    }
    [self.delegate clickInputToolBarAction:action];
}

- (void)clickInputLabel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickInputToolBarAction:)]) {
        [self.textField becomeFirstResponder];
        [self.delegate clickInputToolBarAction:NETSInputToolBarInput];
    }
}

- (void)resignFirstResponder
{
    [self.textField resignFirstResponder];
}

/// private button
- (UIButton *)alphaCircleButton
{
    UIButton *btn = [[UIButton alloc] init];
    btn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    btn.layer.cornerRadius = 18;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

/// 输入视图默认富文本文案
- (NSAttributedString *)_inputLabPlaceholder
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"   "];
    
    NSTextAttachment *attchment = [[NSTextAttachment alloc] init];
    attchment.bounds = CGRectMake(0, -2, 16, 16);
    attchment.image = [UIImage imageNamed:@"msg_ico"];
    NSAttributedString *attachStr = [NSAttributedString attributedStringWithAttachment:attchment];
    [attributedString appendAttributedString:attachStr];
    
    NSAttributedString *tipStr = [[NSAttributedString alloc] initWithString:@" 说点什么..."];
    [attributedString appendAttributedString:tipStr];
    
    return [attributedString copy];
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

- (UILabel *)inputLab
{
    if (!_inputLab) {
        _inputLab = [[UILabel alloc] init];
        _inputLab.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _inputLab.layer.cornerRadius = 18;
        _inputLab.layer.masksToBounds = YES;
        _inputLab.attributedText = [self _inputLabPlaceholder];
        _inputLab.textColor = [UIColor whiteColor];
        _inputLab.font = [UIFont systemFontOfSize:14];
        _inputLab.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickInputLabel)];
        [_inputLab addGestureRecognizer:tap];
    }
    return _inputLab;
}

- (UIButton *)beautyBtn
{
    if (!_beautyBtn) {
        _beautyBtn = [self alphaCircleButton];
        UIImage *image = [[UIImage imageNamed:@"beauty_16_ico"] sd_tintedImageWithColor:[UIColor whiteColor]];
        [_beautyBtn setImage:image forState:UIControlStateNormal];
    }
    return _beautyBtn;
}

- (UIButton *)filterBtn
{
    if (!_filterBtn) {
        _filterBtn = [self alphaCircleButton];
        UIImage *image = [[UIImage imageNamed:@"filter_16_ico"] sd_tintedImageWithColor:[UIColor whiteColor]];
        [_filterBtn setImage:image forState:UIControlStateNormal];
    }
    return _filterBtn;
}

- (UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [self alphaCircleButton];
        [_moreBtn setImage:[UIImage imageNamed:@"more_16_ico"] forState:UIControlStateNormal];
    }
    return _moreBtn;
}

- (UIButton *)musicBtn
{
    if (!_musicBtn) {
        _musicBtn = [self alphaCircleButton];
        [_musicBtn setImage:[UIImage imageNamed:@"music_ico"] forState:UIControlStateNormal];
    }
    return _musicBtn;
}

@end
