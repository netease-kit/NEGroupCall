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
@end

@implementation NEGroupVideoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}
- (void)initUI {
    self.backgroundColor =  [UIColor colorWithRed:41/255.0 green:41/255.0 blue:51/255.0 alpha:1/1.0];
    [self addSubview:self.centerLabel];
    [self.centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0 ));
    }];
    [self addSubview:self.videoView];
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0 ));
    }];
    [self addSubview:self.nameButton];
    [self.nameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.height.mas_equalTo(31);
        make.bottom.mas_equalTo(-2);
    }];
}
- (void)setUserName:(NSString *)userName {
    self.nameButton.hidden = userName.length ? NO :YES;
    [self.nameButton setTitle:userName forState:UIControlStateNormal];
    self.centerLabel.text = userName;
}
- (void)updateMicroEnable:(BOOL)microEnable {
    if (microEnable) {
        [self.nameButton setImage:nil forState:UIControlStateNormal];
    }else {
        [self.nameButton setImage:[UIImage imageNamed:@"call_voice_off_small"] forState:UIControlStateNormal];
    }
}
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
        _nameButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _nameButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _nameButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _nameButton.layer.cornerRadius = 2;
        _nameButton.clipsToBounds = YES;
        _nameButton.hidden = YES;
    }
    return _nameButton;
}
@end
