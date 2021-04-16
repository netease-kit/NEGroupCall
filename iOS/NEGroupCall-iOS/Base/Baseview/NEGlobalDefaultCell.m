//
//  NEGlobalDefaultCell.h
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/15.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEGlobalDefaultCell.h"

@interface NEGlobalDefaultCell ()

@property (nonatomic, strong) UILabel *titleLabel; //标题栏
@property (nonatomic, strong) UILabel *subTitleLabel; //标题栏
@property (nonatomic, strong) UIView *topDividerView; //顶部分割线
@property (nonatomic, strong) UIView *bottomDividerView; //底部分割线
@property (nonatomic, strong) UIImageView *nextImgView; //箭头图片
@property (nonatomic, strong) UILabel *rightContentLabel; //内容
@property (nonatomic, strong) UISwitch *setSwitch;
@property(nonatomic, strong) UIImageView *logoImgView;
@property(nonatomic, strong) UILabel *redPointLabel; //红点

@end

@implementation NEGlobalDefaultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)ne_setupViews {
    [self.contentView addSubview:self.logoImgView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subTitleLabel];
    [self.contentView addSubview:self.topDividerView];
    [self.contentView addSubview:self.bottomDividerView];
    [self.contentView addSubview:self.nextImgView];
    [self.contentView addSubview:self.rightContentLabel];
    [self.contentView addSubview:self.redPointLabel];
    [self.contentView addSubview:self.setSwitch];
//    [self.topDividerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.right.mas_equalTo(0);
//        make.height.mas_equalTo([NEGlobalTools getLineForRenderingHeight]);
//    }];
//
//    [self.bottomDividerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.mas_equalTo(0);
//        make.height.mas_equalTo([NEGlobalTools getLineForRenderingHeight]);
//    }];
    [self.nextImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
        make.width.mas_equalTo(16);
        make.height.mas_equalTo(16);
    }];
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.centerY.mas_equalTo(self.contentView.mas_centerY);
       make.left.mas_equalTo(20);
       make.width.height.mas_equalTo(20);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(20);
    }];
    [self.rightContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nextImgView.mas_centerY);
        make.right.mas_equalTo(self.nextImgView.mas_left).offset(-20);
        make.left.mas_equalTo(self.contentView).offset(100);
    }];
    [self.setSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-20);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(51, 31));
    }];
    [self.redPointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.nextImgView.mas_left).mas_offset(-2);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(6);
    }];
}

- (void)ne_bindViewModel {
    
}

#pragma mark ********** Setter **********
- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    self.subTitleLabel.text = subTitle;
}

- (void)setShowTopDividerView:(BOOL)showTopDividerView {
    _showTopDividerView = showTopDividerView;
    self.topDividerView.hidden = showTopDividerView ? NO : YES;
}

- (void)setShowBottomDividerView:(BOOL)showBottomDividerView {
    _showBottomDividerView = showBottomDividerView;
    self.bottomDividerView.hidden = showBottomDividerView ? NO : YES;
}

- (void)setBottomDividerViewLeftInterval:(CGFloat)BottomDividerViewLeftInterval {
    _BottomDividerViewLeftInterval = BottomDividerViewLeftInterval;
    CGFloat rightInterval = self.BottomDividerViewRightInterval != 0 ? self.BottomDividerViewRightInterval : 0;
    [self.bottomDividerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(BottomDividerViewLeftInterval);
        make.right.mas_equalTo(-rightInterval);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo([NEGlobalTools getLineForRenderingHeight]);
    }];
}

- (void)setBottomDividerViewRightInterval:(CGFloat)BottomDividerViewRightInterval {
    _BottomDividerViewRightInterval = BottomDividerViewRightInterval;
    CGFloat leftInterval = self.BottomDividerViewLeftInterval != 0 ? self.BottomDividerViewLeftInterval : 0;
    [self.bottomDividerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftInterval);
        make.right.mas_equalTo(-BottomDividerViewRightInterval);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo([NEGlobalTools getLineForRenderingHeight]);
    }];
}

- (void)setContent:(NSString *)content {
    _content = content;
    self.rightContentLabel.text = content;
}

- (void)setContentColor:(UIColor *)contentColor {
    _contentColor = contentColor;
    self.rightContentLabel.textColor = contentColor;
}

- (void)setContentFont:(UIFont *)contentFont {
    _contentFont = contentFont;
    self.rightContentLabel.font = contentFont;
}

- (void)setShowNextImgView:(BOOL)showNextImgView {
    _showNextImgView = showNextImgView;
    if (showNextImgView) {
        //显示箭头标识
        self.nextImgView.hidden = NO;
    }else {
        //不显示箭头标识
        self.nextImgView.hidden = YES;
    }
}

- (void)setContentAlignment:(NSTextAlignment)contentAlignment {
    _contentAlignment = contentAlignment;
    self.rightContentLabel.textAlignment = contentAlignment;
}

- (void)setTextWidth:(CGFloat)textWidth {
    _textWidth = textWidth;
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(textWidth);
    }];
}

- (void)setShowSwitch:(BOOL)showSwitch {
    _showSwitch = showSwitch;
    if (showSwitch) {
        self.setSwitch.hidden = NO;
        self.nextImgView.hidden = YES;
        self.rightContentLabel.hidden = YES;
    }else {
        self.setSwitch.hidden = YES;
        self.nextImgView.hidden = NO;
        self.rightContentLabel.hidden = NO;
    }
}

- (void)setOn:(BOOL)on {
    _on = on;
    self.setSwitch.on = on;
}

- (void)setShowSubtitle:(BOOL)showSubtitle {
    _showSubtitle = showSubtitle;
    if (showSubtitle) {
        self.subTitleLabel.hidden = NO;
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(-10);
            make.left.mas_equalTo(20);
            make.height.mas_equalTo(16);
        }];
        [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(10);
            make.left.mas_equalTo(20);
            make.height.mas_equalTo(12);
        }];
    }else {
        self.subTitleLabel.hidden = YES;
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.left.mas_equalTo(20);
        }];
    }
}

- (void)setLogoImgName:(NSString *)logoImgName {
    _logoImgName = logoImgName;
    if (logoImgName && logoImgName.length>0) {
        self.logoImgView.hidden = NO;
        self.logoImgView.image = [UIImage imageNamed:logoImgName];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.left.mas_equalTo(self.logoImgView.mas_right).mas_offset(12);
        }];
    }else {
        self.logoImgView.hidden = YES;
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.left.mas_equalTo(20);
        }];
    }
}

- (void)setIsShowRedPoint:(BOOL)isShowRedPoint {
    _isShowRedPoint = isShowRedPoint;
    if (isShowRedPoint) {
        //显示红点
        self.redPointLabel.hidden = NO;
        [self.rightContentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.nextImgView.mas_centerY);
            make.right.mas_equalTo(self.redPointLabel.mas_left).offset(-6);
        }];
        if (self.showNextImgView)  {
            [self.redPointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.nextImgView.mas_left).mas_offset(-2);
                make.centerY.mas_equalTo(self);
                make.width.height.mas_equalTo(6);
            }];
        }else {
            [self.redPointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.contentView.mas_right).offset(-18);
                make.centerY.mas_equalTo(self);
                make.width.height.mas_equalTo(6);
            }];
        }
    }else {
        self.redPointLabel.hidden = YES;
        if (self.showNextImgView) {
            [self.rightContentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.nextImgView.mas_centerY);
                make.right.mas_equalTo(self.nextImgView.mas_left).offset(-2);
            }];
        }else {
            [self.rightContentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.nextImgView.mas_centerY);
                make.right.mas_equalTo(self.contentView.mas_right).offset(-18);
            }];
        }
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
}

#pragma mark - Private Method
- (void)switchChoose:(UISwitch *)sender {
    if (self.switchBlock) {
        self.switchBlock(sender.isOn);
    }
}

#pragma mark ********** Method **********
+ (instancetype)settingCellForTableView:(UITableView *)tableView cellStyle: (UITableViewCellStyle)style {
    static NSString *globalDefaultCellId = @"NEGlobalDefaultCell";
    NEGlobalDefaultCell *globalDefaultCell = [tableView dequeueReusableCellWithIdentifier:globalDefaultCellId];
    if (!globalDefaultCell) {
        globalDefaultCell = [[NEGlobalDefaultCell alloc] initWithStyle:style reuseIdentifier:globalDefaultCellId];
    }
    return globalDefaultCell;
}


#pragma mark ********** Lazy **********
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [NETSViewFactory createLabelFrame:CGRectZero title:@"title" textColor:HEXCOLOR(0x222222) textAlignment:NSTextAlignmentLeft font:TextFont_15];

    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        
        _subTitleLabel = [NETSViewFactory createLabelFrame:CGRectZero title:@"title" textColor:HEXCOLOR(0x666666) textAlignment:NSTextAlignmentLeft font:[UIFont systemFontOfSize:12]];
        _subTitleLabel.hidden = YES;
    }
    return _subTitleLabel;
}

- (UIView *)topDividerView {
    if (!_topDividerView) {
        _topDividerView = [[UIView alloc]init];
        _topDividerView.backgroundColor = HEXCOLOR(0xE6E7EB);
        _topDividerView.hidden = YES; //默认隐藏
    }
    return _topDividerView;
}

- (UIView *)bottomDividerView {
    if (!_bottomDividerView) {
        _topDividerView = [[UIView alloc]init];
        _topDividerView.backgroundColor = HEXCOLOR(0xE6E7EB);
    }
    return _bottomDividerView;
}

- (UILabel *)rightContentLabel {
    if (!_rightContentLabel) {
        _rightContentLabel = [NETSViewFactory createLabelFrame:CGRectZero title:@"" textColor:HEXCOLOR(0x666666) textAlignment:NSTextAlignmentLeft font:TextFont_15];
    }
    return _rightContentLabel;
}

- (UIImageView *)nextImgView {
    if (!_nextImgView) {
        _nextImgView = [NETSViewFactory createImageViewFrame:CGRectZero imageName:@"mine_nextImg_icon"];
    }
    return _nextImgView;
}

- (UISwitch *)setSwitch {
    if (!_setSwitch) {
        _setSwitch = [[UISwitch alloc]init];
//        _setSwitch.onTintColor = NEDefaultRedThemeColor;
        [_setSwitch setOn:false];
        [_setSwitch addTarget:self action:@selector(switchChoose:) forControlEvents:UIControlEventTouchUpInside];
        _setSwitch.hidden = YES;
    }
    return _setSwitch;
}

- (UIImageView *)logoImgView {
    if (!_logoImgView) {
        _logoImgView = [NETSViewFactory createImageViewFrame:CGRectZero imageName:nil];
        _logoImgView.contentMode = UIViewContentModeScaleAspectFit;
        _logoImgView.hidden = YES;
    }
    return _logoImgView;
}

- (UILabel *)redPointLabel {
    if (!_redPointLabel) {
        _redPointLabel = [NETSViewFactory createLabelFrame:CGRectZero title:@"" textColor:nil textAlignment:NSTextAlignmentCenter font:[UIFont systemFontOfSize:12]];
        _redPointLabel.backgroundColor = HEXCOLOR(0xF4353F);
        _redPointLabel.hidden = YES;
        _redPointLabel.layer.cornerRadius = 3;
        _redPointLabel.layer.masksToBounds = YES;
    }
    return _redPointLabel;
}

@end
