//
//  NEEvaluateThankView.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEEvaluateThankView.h"

@implementation NEEvaluateThankView

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1/1.0];
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(1);
            make.top.mas_equalTo(1);
        }];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"laugh"] forState:UIControlStateNormal];
        [button setTitle:@"感谢您的评价～" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.contentMode = UIViewContentModeCenter;
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(line.mas_bottom).offset(20);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(24);
        }];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"laugh"]];
//        [self addSubview:imageView];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
