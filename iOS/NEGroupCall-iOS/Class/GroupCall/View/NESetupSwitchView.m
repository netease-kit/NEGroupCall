//
//  NESetupSwitchView.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/3/11.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NESetupSwitchView.h"

@interface NESetupSwitchView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *setUpSwitch;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, strong) UIView *bottomLineView;
@end

@implementation NESetupSwitchView


- (instancetype)initWithtitle:(NSString *)title switchStatus:(BOOL)isOpen {
    if (self = [super init]) {
        _title = title;
        _isOpen = isOpen;
        [self ne_setupViews];
        [self ne_bindModel];
    }
    return self;
}

- (void)ne_bindModel {
    @weakify(self)
    [[ self.setUpSwitch rac_signalForControlEvents:UIControlEventValueChanged]subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self.switchChangeSubject sendNext:@(self.setUpSwitch.isOn)];
    }];
}

- (void)ne_setupViews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.setUpSwitch];
    [self addSubview:self.bottomLineView];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.centerY.equalTo(self);
    }];
    
    [self.setUpSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20);
        make.centerY.equalTo(self);
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
}

#pragma mark - lazyMethod

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = self.title;
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.font = TextFont_14;
    }
    return _titleLabel;
}

- (UISwitch *)setUpSwitch {
    if (!_setUpSwitch) {
        _setUpSwitch = [[UISwitch alloc]init];
        [_setUpSwitch setTintColor:UIColor.whiteColor];
        [_setUpSwitch setOnTintColor:HEXCOLOR(0x337EFF)];
        [_setUpSwitch setThumbTintColor:[UIColor whiteColor]];
        [_setUpSwitch setOn:self.isOpen];
    }
    return _setUpSwitch;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc]init];
        _bottomLineView.backgroundColor = HEXCOLOR(0x303040);
    }
    return _bottomLineView;
}
@end
