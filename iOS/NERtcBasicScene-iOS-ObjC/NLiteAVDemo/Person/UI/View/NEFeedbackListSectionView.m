//
//  NEFeedbackListSectionView.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/22.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEFeedbackListSectionView.h"

@implementation NEFeedbackListSectionView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.contentView.backgroundColor = KThemColor;
    [self addSubview:self.titleLabel];
    [self addSubview:self.arrowButton];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.bottom.mas_equalTo(0);
    }];
    [self.arrowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(10);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(60);
        make.top.bottom.mas_equalTo(0);
    }];
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}
- (UIButton *)arrowButton {
    if (!_arrowButton) {
        _arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_arrowButton setImage:[UIImage imageNamed:@"arrowDown"] forState:UIControlStateNormal];
        [_arrowButton setImage:[UIImage imageNamed:@"arrowUp"] forState:UIControlStateSelected];
        _arrowButton.imageView.contentMode = UIViewContentModeCenter;
        [_arrowButton addTarget:self action:@selector(arrowButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _arrowButton;
}
- (void)arrowButtonClick:(UIButton *)button {
    button.selected = !button.selected;
    if (self.didSelect) {
           self.didSelect(button.selected);
       }
    
}
@end
