//
//  NETSKeyboardToolbar.m
//  NLiteAVDemo
//
//  Created by Think on 2021/1/20.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSKeyboardToolbar.h"
#import "UIView+NTES.h"

@interface NETSKeyboardToolbar () <UITextFieldDelegate>

@property (nonatomic, strong, readwrite)   UITextField *textField;
@property (nonatomic, strong, readwrite)   UIButton    *sendBtn;
@property (nonatomic, strong)   UIView      *slide;

@end

@implementation NETSKeyboardToolbar

- (instancetype)init
{
    CGRect rect = CGRectMake(0, 0, kScreenWidth, 46);
    self = [super initWithFrame:rect];
    if (self) {
        self.textField.frame = CGRectMake(0, 0, kScreenWidth - 15 - 70, 36);
        self.slide.frame = CGRectMake(0, 0, 5, self.height);
        self.sendBtn.frame = CGRectMake(0, 0, 70, 36);
        UIBarButtonItem *textItem = [[UIBarButtonItem alloc] initWithCustomView:self.textField];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithCustomView:self.slide];
        UIBarButtonItem *sendBtnItem = [[UIBarButtonItem alloc] initWithCustomView:self.sendBtn];
        self.items = @[textItem, spaceItem, sendBtnItem];
    }
    return self;
}

- (void)_sendBtnClick:(UIButton *)sender
{
    if (self.cusDelegate && [self.cusDelegate respondsToSelector:@selector(didToolBar:sendText:)]) {
        [self.cusDelegate didToolBar:self sendText:self.textField.text];
    }
    self.textField.text = @"";
}

- (void)resignFirstResponder
{
    self.textField.text = @"";
    [self.textField resignFirstResponder];
}

- (void)becomeFirstResponder
{
    [self.textField becomeFirstResponder];
}

#pragma mark - lazy load

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.font = [UIFont systemFontOfSize:14];
    }
    return _textField;
}

- (UIButton *)sendBtn
{
    if (!_sendBtn) {
        _sendBtn = [[UIButton alloc] init];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _sendBtn.layer.cornerRadius = 4;
        _sendBtn.layer.masksToBounds = YES;
        _sendBtn.backgroundColor = HEXCOLOR(0x337EFF);
        [_sendBtn addTarget:self action:@selector(_sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (UIView *)slide
{
    if (!_slide) {
        _slide = [[UIView alloc] init];
    }
    return _slide;
}

@end
