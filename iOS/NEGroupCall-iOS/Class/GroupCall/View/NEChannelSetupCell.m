//
//  NEChannelSetupCell.m
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/15.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEChannelSetupCell.h"
#import "NEChannelSetupModel.h"

@interface NEChannelSetupCell()
@property(nonatomic, strong) UIButton *musicButton;
@property(nonatomic, strong) UIButton *voiceButton;

@end

@implementation NEChannelSetupCell

- (void)ne_setupViews  {
    [super ne_setupViews];
    [self.contentView addSubview:self.musicButton];
    [self.contentView addSubview:self.voiceButton];

    [self.musicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(100);
    }];
    
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.equalTo(self.musicButton.mas_right).offset(24);
    }];
}

- (void)ne_bindViewModel {
    @weakify(self)
    [[self.musicButton rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.musicButton.selected = !self.musicButton.selected;
        if (self.musicButton.selected) {
            self.voiceButton.selected = NO;
        }
        [self.musicSubject sendNext:nil];
    }];
    
    [[self.voiceButton rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.voiceButton.selected = !self.voiceButton.selected;
        if (self.voiceButton.selected) {
            self.musicButton.selected = NO;
        }
        [self.voiceSubject sendNext:nil];
    }];
    
    
}

#pragma mark - Method
+ (instancetype)settingCellForTableView:(UITableView *)tableView cellStyle: (UITableViewCellStyle)style {
    static NSString *cellId = @"NEChannelSetupCell";
    NEChannelSetupCell *setupCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!setupCell) {
        setupCell = [[NEChannelSetupCell alloc] initWithStyle:style reuseIdentifier:cellId];
    }
    return setupCell;
}

- (void)setDataModel:(NEChannelSetupModel *)dataModel {
    _dataModel = dataModel;
    self.title = dataModel.title;
    self.content = dataModel.content;
    self.contentColor = HEXCOLOR(0x222222);
    self.showNextImgView = dataModel.isShowNextImg;
    if (dataModel.isScenario) {
        self.musicButton.hidden = NO;
        self.voiceButton.hidden = NO;
    }else {
        self.musicButton.hidden = YES;
        self.voiceButton.hidden = YES;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - lazyMethod
- (UIButton *)musicButton {
    if (!_musicButton) {
        _musicButton = [[UIButton alloc]init];
        [_musicButton setImage:[UIImage imageNamed:@"channel_setup_normal"] forState:UIControlStateNormal];
        [_musicButton setImage:[UIImage imageNamed:@"channel_setup_selected"] forState:UIControlStateSelected];
        [_musicButton setTitle:@"音乐" forState:UIControlStateNormal];
        [_musicButton setTitleColor:HEXCOLOR(0x222222) forState:UIControlStateNormal];
        _musicButton.titleLabel.font = TextFont_15;
        [_musicButton layoutButtonWithEdgeInsetsStyle:NEButtonEdgeInsetsStyleLeft imageTitleSpace:8];
        _musicButton.selected = YES;
        _musicButton.hidden = YES;
    }
    return _musicButton;
}

- (UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [[UIButton alloc]init];
        [_voiceButton setImage:[UIImage imageNamed:@"channel_setup_normal"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"channel_setup_selected"] forState:UIControlStateSelected];
        [_voiceButton setTitle:@"语音" forState:UIControlStateNormal];
        [_voiceButton setTitleColor:HEXCOLOR(0x222222) forState:UIControlStateNormal];
        _voiceButton.titleLabel.font = TextFont_15;
        [_voiceButton layoutButtonWithEdgeInsetsStyle:NEButtonEdgeInsetsStyleLeft imageTitleSpace:8];
        _voiceButton.hidden = YES;
    }
    return _voiceButton;
}
@end
