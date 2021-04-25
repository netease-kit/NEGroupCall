//
//  NEGroupVideoView.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEGroupVideoView.h"

@interface NEGroupVideoView ()
@property(strong,nonatomic)UILabel *centerLabel;
//@property(strong,nonatomic)UIView *videoView;
@property(strong,nonatomic)UIButton *nameButton;
//缩放按钮
@property(nonatomic,strong) UIButton *zoomButton;
@property(nonatomic,strong) UIImageView *signalImageView;


@end

@implementation NEGroupVideoView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initUI];
        [self addGestureRecognizer];
    }
    return self;
}

- (void)initUI {
    
    self.backgroundColor =  [UIColor colorWithRed:41/255.0 green:41/255.0 blue:51/255.0 alpha:1/1.0];
    [self addSubview:self.centerLabel];
    [self addSubview:self.videoView];
    [self addSubview:self.nameButton];
    [self addSubview:self.signalImageView];
    [self addSubview:self.zoomButton];
    
    [self.centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0 ));
    }];

    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0 ));
    }];
    
    [self.nameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(2);
        make.width.mas_lessThanOrEqualTo(self);
        make.height.mas_equalTo(21);
        make.bottom.mas_equalTo(-2);
    }];
    
    [self.signalImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(32);
        make.right.equalTo(self).offset(-8);
    }];
    
    [self.zoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(8);
        make.top.equalTo(self).offset(32);
    }];
    
}

- (void)addGestureRecognizer {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)tapAction:(UITapGestureRecognizer *)recognizer {
    if (self.isEnterSpeakerMode) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(exchangeSpeakerMode:)]) {
            [self.delegate exchangeSpeakerMode:self.userId];
        }
    }
}

- (void)setUserName:(NSString *)userName {
    _userName = userName;
    self.nameButton.hidden = userName.length ? NO :YES;
    [self.nameButton setTitle:userName forState:UIControlStateNormal];
    self.centerLabel.text = userName;
}

- (void)setIsHiddenZoomTag:(BOOL)isHiddenZoomTag {
    _isHiddenZoomTag = isHiddenZoomTag;
    self.zoomButton.hidden = isHiddenZoomTag;
}

- (void)setIsEnterSpeakerMode:(BOOL)isEnterSpeakerMode {
    _isEnterSpeakerMode = isEnterSpeakerMode;
    self.zoomButton.hidden = isEnterSpeakerMode;
    self.signalImageView.hidden = isEnterSpeakerMode;
}

- (void)setIsZoomSelected:(BOOL)isSelected {
    self.zoomButton.selected = isSelected;
}

- (void)setSignalQuality:(NSInteger)signalQuality {
    _signalQuality = signalQuality;
    switch (signalQuality) {
        case 1:
        case 2:
            self.signalImageView.image = [UIImage imageNamed:@"signal_green_icon"];
            break;
        case 3:
            self.signalImageView.image = [UIImage imageNamed:@"signal_yellow_icon"];
            break;
        case 0:
        case 6:
            self.signalImageView.image = [UIImage imageNamed:@"signal_gray_icon"];
            break;
        case 4:
        case 5:
            self.signalImageView.image = [UIImage imageNamed:@"signal_red_icon"];
            break;
        default:
            break;
    }
}

- (void)updateMicroEnable:(BOOL)microEnable {
    if (microEnable) {
        [self.nameButton setImage:nil forState:UIControlStateNormal];
    }else {
        [self.nameButton setImage:[UIImage imageNamed:@"call_voice_off_small"] forState:UIControlStateNormal];
    }
}

- (void)zoomButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(zoomButtonClickAction:)]) {
        [self.delegate zoomButtonClickAction:self.userId];
    }
}

#pragma mark - lazy
- (UILabel *)centerLabel {
    if (!_centerLabel) {
        _centerLabel = [[UILabel alloc] init];
        _centerLabel.font = [UIFont systemFontOfSize:24];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.textColor = [UIColor whiteColor];
    }
    return _centerLabel;
}
- (UIView *)videoView {
    if (!_videoView) {
        _videoView = [[UIView alloc] init];
    }
    return _videoView;
}
- (UIButton *)nameButton {
    if (!_nameButton) {
        _nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nameButton setImage:[UIImage imageNamed:@"call_voice_off_small"] forState:UIControlStateNormal];
        _nameButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _nameButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _nameButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _nameButton.titleLabel.font = Font_Default(12);
        _nameButton.layer.cornerRadius = 2;
        _nameButton.clipsToBounds = YES;
        _nameButton.hidden = YES;
    }
    return _nameButton;
}

- (UIButton *)zoomButton {
    if (!_zoomButton) {
        _zoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zoomButton setBackgroundImage:[UIImage imageNamed:@"channel_enlarge_icon"] forState:UIControlStateNormal];
        [_zoomButton setBackgroundImage:[UIImage imageNamed:@"channel_narrow_icon"] forState:UIControlStateSelected];
        [_zoomButton addTarget:self action:@selector(zoomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _zoomButton;
}

- (UIImageView *)signalImageView {
    if (!_signalImageView) {
        _signalImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"signal_green_icon"]];
    }
    return _signalImageView;
}

@end
