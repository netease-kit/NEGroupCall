//
//  NETSEmptyListView.m
//  NLiteAVDemo
//
//  Created by Think on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSEmptyListView.h"
#import "UIImage+NTES.h"

@interface NETSEmptyListView ()

@property (nonatomic, strong)   UIImageView *imgView;
@property (nonatomic, strong)   UILabel     *tipLabel;

@end

@implementation NETSEmptyListView

- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, 100, 138);
    self = [super initWithFrame:rect];
    if (self) {
        [self addSubview:self.imgView];
        [self addSubview:self.tipLabel];
        
        self.imgView.frame = CGRectMake(0, 0, 100, 100);
        self.tipLabel.frame = CGRectMake(0, 100 + 16, 100, 22);
    }
    return self;
}

- (void)setTintColor:(UIColor *)tintColor
{
    if (_tintColor == tintColor) {
        return;
    }
    self.imgView.image = [[UIImage imageNamed:@"empty_ico"] ne_imageWithTintColor:tintColor];
    self.tipLabel.textColor = tintColor;
}

#pragma mark - lazy load

- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.image = [UIImage imageNamed:@"empty_ico"];
    }
    return _imgView;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = HEXCOLOR(0x2b2c39);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = @"暂无直播哦";
    }
    return _tipLabel;
}

@end
