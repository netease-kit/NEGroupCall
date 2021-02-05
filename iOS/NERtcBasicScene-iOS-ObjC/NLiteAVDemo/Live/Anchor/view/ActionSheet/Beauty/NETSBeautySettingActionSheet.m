//
//  NETSBeautySettingActionSheet.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSBeautySettingActionSheet.h"
#import "TopmostView.h"
#import "UIView+NTES.h"
#import "NETSBeautyParam.h"
#import "NETSFUManger.h"

@class NETSBeautySettingLine;

@protocol NETSBeautySettingLineDelegate <NSObject>

///
/// 滑块值改变事件
/// @param param    - 改变后的值
///
- (void)didChangedParam:(NETSBeautyParam *)param;

@end

@interface NETSBeautySettingLine : UIView

/// 是否启用
@property (nonatomic, assign)   BOOL        enable;
/// 标题
@property (nonatomic, strong)   UILabel     *titleLab;
/// 滑块
@property (nonatomic, strong)   UISlider    *slider;
/// 值展示
@property (nonatomic, strong)   UILabel     *valLab;
/// 代理对象
@property (nonatomic, weak)     id<NETSBeautySettingLineDelegate> delegate;
/// 数据模型
@property (nonatomic, strong)   NETSBeautyParam *param;

@end

@implementation NETSBeautySettingLine

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.titleLab];
        [self addSubview:self.slider];
        [self addSubview:self.valLab];
    }
    return self;
}

- (void)setParam:(NETSBeautyParam *)param
{
    _param = param;
    
    NSAssert(_param.maxVal > _param.minVal, @"slide设置最大值小于最小值");
    self.titleLab.text = _param.mTitle;
    self.slider.minimumValue = _param.minVal;
    self.slider.maximumValue = _param.maxVal;
    [self.slider setValue:_param.mValue];
    self.valLab.text = [NSString stringWithFormat:@"%.2f", _param.mValue];
}

- (void)layoutSubviews
{
    self.titleLab.frame = CGRectMake(20, 0, 50, self.height);
    self.slider.frame = CGRectMake(self.titleLab.right, 0, self.width - 100 - 40, self.height);
    self.valLab.frame = CGRectMake(self.width - 50 - 20, 0, 50, self.height);
}

/// Slider值改变事件
- (void)changeValue:(UISlider *)slider
{
    float val = slider.value;
    _valLab.text = [NSString stringWithFormat:@"%.2f", val];
    _param.mValue = val;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangedParam:)]) {
        [self.delegate didChangedParam:_param];
    }
}

- (void)setEnable:(BOOL)enable
{
    self.slider.enabled = enable ? YES : NO;
    self.valLab.textColor = enable ? HEXCOLOR(0x222222) : HEXCOLOR(0xcccccc);
}

#pragma mark - lazy load

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:14];
        _titleLab.textColor = HEXCOLOR(0x222222);
        _titleLab.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLab;
}

- (UISlider *)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        [_slider addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (UILabel *)valLab
{
    if (!_valLab) {
        _valLab = [[UILabel alloc] init];
        _valLab.font = [UIFont systemFontOfSize:14];
        _valLab.textColor = HEXCOLOR(0x222222);
        _valLab.textAlignment = NSTextAlignmentRight;
    }
    return _valLab;
}

@end

///

@interface NETSBeautySettingActionSheet () <NETSBeautySettingLineDelegate>

/// 美白设置
@property (nonatomic, strong) NETSBeautySettingLine *setWhite;
/// 磨皮设置
@property (nonatomic, strong) NETSBeautySettingLine *setFilter;
/// 瘦脸设置
@property (nonatomic, strong) NETSBeautySettingLine *setFaceLift;
/// 大眼设置
@property (nonatomic, strong) NETSBeautySettingLine *setEye;

@end

@implementation NETSBeautySettingActionSheet

+ (void)show
{
    CGRect frame = [UIScreen mainScreen].bounds;
    NETSBeautySettingActionSheet *sheet = [[NETSBeautySettingActionSheet alloc] initWithFrame:frame title:@"美颜"];
    NSArray<NETSBeautyParam *> *params = [NETSFUManger shared].skinParams;
    [sheet configWithItems:params];
    
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    
    /// 暂存顶层视图交互设置
    sheet.topUserInteractionEnabled = topmostView.userInteractionEnabled;
    
    topmostView.userInteractionEnabled = YES;
    [topmostView addSubview:sheet];
}

#pragma mark - override method

- (void)setupSubViews
{
    [self.content addSubview:self.setWhite];
    [self.content addSubview:self.setFilter];
    [self.content addSubview:self.setFaceLift];
    [self.content addSubview:self.setEye];
    
    [self.setWhite mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topLine.mas_bottom).offset(10);
        make.left.right.equalTo(self.content);
        make.height.mas_equalTo(46);
    }];
    [self.setFilter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.setWhite.mas_bottom);
        make.left.right.height.equalTo(self.setWhite);
    }];
    [self.setFaceLift mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.setFilter.mas_bottom);
        make.left.right.height.equalTo(self.setWhite);
    }];
    [self.setEye mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.setFaceLift.mas_bottom);
        make.left.right.height.equalTo(self.setWhite);
        make.bottom.equalTo(self.content).offset(kIsFullScreen ? -44 : -10);
    }];
}

- (void)configWithItems:(NSArray<NETSBeautyParam *> *)items
{
    NSArray *setViews = @[self.setWhite, self.setFilter, self.setFaceLift, self.setEye];
    for (int i = 0; i < MIN([setViews count], [items count]); i++) {
        NETSBeautySettingLine *line = setViews[i];
        line.param = items[i];
    }
}

- (void)resetSetting:(UIButton *)sender
{
    NETSLog(@"重置美颜参数...");
    [[NETSFUManger shared] resetSkinParams];
    NSArray<NETSBeautyParam *> *params = [NETSFUManger shared].skinParams;
    [self configWithItems:params];
}

#pragma mark - NETSBeautySettingLineDelegate

- (void)didChangedParam:(NETSBeautyParam *)param
{
    [[NETSFUManger shared] setBeautyParam:param];
}

#pragma mark - lazy load

- (NETSBeautySettingLine *)setWhite
{
    if (!_setWhite) {
        _setWhite = [[NETSBeautySettingLine alloc] init];
        _setWhite.delegate = self;
    }
    return _setWhite;
}

- (NETSBeautySettingLine *)setFilter
{
    if (!_setFilter) {
        _setFilter = [[NETSBeautySettingLine alloc] init];
        _setFilter.delegate = self;
    }
    return _setFilter;
}

- (NETSBeautySettingLine *)setFaceLift
{
    if (!_setFaceLift) {
        _setFaceLift = [[NETSBeautySettingLine alloc] init];
        _setFaceLift.delegate = self;
    }
    return _setFaceLift;
}

- (NETSBeautySettingLine *)setEye
{
    if (!_setEye) {
        _setEye = [[NETSBeautySettingLine alloc] init];
        _setEye.delegate = self;
    }
    return _setEye;
}

@end
