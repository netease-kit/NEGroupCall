//
//  NETSAudioMixingItem.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSAudioMixingItem.h"
#import "UIView+NTES.h"
#import "UIImage+NTES.h"

@interface NETSAudioMixingSelectedBtn : UIButton

@end

@implementation NETSAudioMixingSelectedBtn

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.selected = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.backgroundColor = HEXCOLOR(0x337EFF);
    } else {
        [self setTitleColor:HEXCOLOR(0x222222) forState:UIControlStateNormal];
        self.backgroundColor = HEXCOLOR(0xF2F3F5);
    }
}

@end

///

@interface NETSAudioMixingItem ()

/// 代理对象
@property (nonatomic, weak)     id<NETSAudioMixingItemdelegate> delegate;
/// 标题
@property (nonatomic, strong)   UILabel     *label;
/// 按钮1
@property (nonatomic, strong)   NETSAudioMixingSelectedBtn    *btn1;
/// 按钮2
@property (nonatomic, strong)   NETSAudioMixingSelectedBtn    *btn2;
/// 分割线
@property (nonatomic, strong)   UIView      *line;
/// 声音图标
@property (nonatomic, strong)   UIImageView *icon;
/// 滑动控件
@property (nonatomic, strong)   UISlider    *slider;

@end

@implementation NETSAudioMixingItem

- (instancetype)initWithTitle:(NSString *)title
                      btn1Tit:(NSString *)btn1Tit
                      btn2Tit:(NSString *)btn2Tit
                 sliderMinVal:(float)sliderMinVal
                 sliderMaxVal:(float)sliderMaxVal
                     delegate:(id<NETSAudioMixingItemdelegate>)deleagte
{
    self = [super init];
    if (self) {
        [self addSubview:self.label];
        [self addSubview:self.btn1];
        [self addSubview:self.btn2];
        [self addSubview:self.line];
        [self addSubview:self.icon];
        [self addSubview:self.slider];
        
        self.label.text = title;
        [self.btn1 setTitle:btn1Tit forState:UIControlStateNormal];
        [self.btn2 setTitle:btn2Tit forState:UIControlStateNormal];
        self.slider.minimumValue = sliderMinVal;
        self.slider.maximumValue = sliderMaxVal;
        self.delegate = deleagte;
    }
    return self;
}

- (void)layoutSubviews
{
    self.label.frame = CGRectMake(20, 0, 80, 56);
    self.btn2.frame = CGRectMake(self.width - 20 - 60, 12, 60, 32);
    self.btn1.frame = CGRectMake(self.btn2.left - 8 - 60, self.btn2.top, self.btn2.width, self.btn2.height);
    self.line.frame = CGRectMake(20, 56, self.width - 40, 0.5);
    self.icon.frame = CGRectMake(self.label.left, self.line.bottom + 15, 16, 16);
    self.slider.frame = CGRectMake(self.icon.right + 20, self.line.bottom, self.width - 40 - 16 - 20, 46);
}

- (void)clickAction:(UIButton *)sender
{
    for (UIButton *btn in @[self.btn1, self.btn2]) {
        if (sender == btn) {
            sender.selected = !sender.selected;
        } else {
            btn.selected = NO;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickItem:selected:index:)]) {
        NSInteger index = (sender == self.btn1) ? 0 : 1;
        [self.delegate didClickItem:self selected:sender.selected index:index];
    }
}

- (void)didChangedSlide:(UISlider *)slider
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangedItem:sliderValue:)]) {
        [self.delegate didChangedItem:self sliderValue:slider.value];
    }
}

- (void)setSliderValue:(float)sliderValue
{
    self.slider.value = sliderValue;
}

- (float)sliderValue
{
    return self.slider.value;
}

- (void)setSelectedIndex:(NSInteger)index
{
    if (index == 0) {
        self.btn1.selected = YES;
    }
    if (index == 1) {
        self.btn2.selected = YES;
    }
}

#pragma mark - lazy load

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:14];
        _label.textColor = HEXCOLOR(0x222222);
        _label.text = @"背景音乐";
    }
    return _label;
}

- (NETSAudioMixingSelectedBtn *)btn1
{
    if (!_btn1) {
        _btn1 = [[NETSAudioMixingSelectedBtn alloc] init];
        [_btn1 setTitle:@"音乐1" forState:UIControlStateNormal];
        [_btn1 addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn1;
}

- (NETSAudioMixingSelectedBtn *)btn2
{
    if (!_btn2) {
        _btn2 = [[NETSAudioMixingSelectedBtn alloc] init];
        [_btn2 setTitle:@"音乐2" forState:UIControlStateNormal];
        [_btn2 addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn2;
}

- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = HEXCOLOR(0xf0f0f0);
    }
    return _line;
}

- (UIImageView *)icon
{
    if (!_icon) {
        UIImage *img = [[UIImage imageNamed:@"sound_ico"] ne_imageWithTintColor:HEXCOLOR(0x1f1f1f)];
        _icon = [[UIImageView alloc] initWithImage:img];
    }
    return _icon;
}

- (UISlider *)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.minimumValue = 0;
        _slider.maximumValue = 1;
        _slider.value = 0.5;
        [_slider addTarget:self action:@selector(didChangedSlide:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

@end
