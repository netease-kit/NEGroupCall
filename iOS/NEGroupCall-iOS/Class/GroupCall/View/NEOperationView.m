//
//  NEOperationView.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEOperationView.h"
#import "UIView+NTES.h"

@interface NEOperationView ()
@property(nonatomic,assign) BOOL isOpenMicrophone;
@property(nonatomic,assign) BOOL isOpenCamera;
@property (nonatomic, strong)   UIButton    *beautyBtn;
@property (nonatomic, strong)   UIButton    *statsBtn;
@property (nonatomic, strong)   UIView      *roundBg;

@end

@implementation NEOperationView

- (instancetype)initWithImages:(NSArray <NSString *>*)images
               selectedImages:(NSArray <NSString *>*)selectedImages
             isOpenMicrophone:(BOOL)isOpenMicrophone
                  isOpenCamera:(BOOL)isOpenCamera {
    self = [super init];
    if (self) {
        self.isOpenMicrophone = isOpenMicrophone;
        self.isOpenCamera = isOpenCamera;
        [self initUIWithImages:images selectedImages:selectedImages];
    }
    return self;
}


- (void)initUIWithImages:(NSArray <NSString *>*)images selectedImages:(NSArray <NSString *>*)selectedImages {
    [self addSubview:self.roundBg];
    [self addSubview:self.beautyBtn];
    [self addSubview:self.statsBtn];
    
    [self.roundBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(60);
    }];
    [self.beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self.statsBtn.mas_left);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    [self.statsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < images.count; i ++) {
        NSString *imageName = images[i];
        NSString *selectedImageName = selectedImages[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0 && !self.isOpenMicrophone) {
            button.selected = YES;
        }
        if (i == 1 && !self.isOpenCamera) {
            button.selected = YES;
        }
        button.tag = i + 10;
        [array addObject:button];
    }
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:array];
    stackView.distribution = UIStackViewDistributionFillEqually;
    [self.roundBg addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 30, 0, 30));
    }];
}
- (void)buttonEvent:(UIButton *)button {
    button.selected = !button.selected;
    NSInteger idx = button.tag - 10;
    if (idx == 4) {
        _beautyBtn.hidden = _statsBtn.hidden = !_beautyBtn.hidden;
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectIndex:button:)]) {
        [self.delegate didSelectIndex:idx button:button];
    }
}
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        _beautyBtn.hidden = hidden;
        _statsBtn.hidden = hidden;
    }
}

- (void)clickEvent:(UIButton *)sender
{
    if (sender == self.beautyBtn && _delegate && [_delegate respondsToSelector:@selector(didSwitchBeauty:)]) {
        sender.selected = !sender.selected;
        [_delegate didSwitchBeauty:sender.selected];
    }
    
    if (sender == self.statsBtn && _delegate && [_delegate respondsToSelector:@selector(didSelectStatsBtn)]) {
        [_delegate didSelectStatsBtn];
    }
}

#pragma mark - lazy load

- (UIView *)roundBg
{
    if (!_roundBg) {
        _roundBg = [[UIView alloc] init];
        _roundBg.layer.cornerRadius = 30;
        _roundBg.backgroundColor = HEXCOLOR(0x1A1A23);
    }
    return _roundBg;
}

- (UIButton *)beautyBtn
{
    if (!_beautyBtn) {
        _beautyBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _beautyBtn.backgroundColor = HEXCOLOR(0x1A1A23);
        [_beautyBtn setImage:[UIImage imageNamed:@"group_beauty"] forState:UIControlStateNormal];
        [_beautyBtn setImage:[UIImage imageNamed:@"group_beauty_select"] forState:UIControlStateSelected];
        [_beautyBtn cornerByRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadius:4];
        [_beautyBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
        _beautyBtn.hidden = YES;
    }
    return _beautyBtn;
}

- (UIButton *)statsBtn
{
    if (!_statsBtn) {
        _statsBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _statsBtn.backgroundColor = HEXCOLOR(0x1A1A23);
        [_statsBtn setImage:[UIImage imageNamed:@"stats_ico"] forState:UIControlStateNormal];
        [_statsBtn cornerByRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight) cornerRadius:4];
        [_statsBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
        _statsBtn.hidden = YES;
    }
    return _statsBtn;
}

@end
