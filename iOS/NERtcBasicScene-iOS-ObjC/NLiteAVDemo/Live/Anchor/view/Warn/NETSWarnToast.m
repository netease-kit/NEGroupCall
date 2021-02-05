//
//  NETSWarnToast.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSWarnToast.h"
#import "UIView+NTES.h"

@interface NETSWarnToast ()

/// 标识图片
@property (nonatomic, strong)   UIImageView *iconView;
/// 提示文字
@property (nonatomic, strong)   UILabel     *tipLab;

@end

@implementation NETSWarnToast

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.iconView];
        [self addSubview:self.tipLab];
        
        [self bindAction];
    }
    return self;
}

- (void)layoutSubviews
{
    self.iconView.frame = CGRectMake(12, 12, 16, 16);
    self.tipLab.frame = CGRectMake(self.iconView.right + 8, (self.height - 44) / 2.0, self.width - 12 - 16 - 8 - 12, 44);
}

- (void)bindAction
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
}

- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    if (self.clickBlock) {
        self.clickBlock();
    }
}

- (void)setIcon:(UIImage *)icon
{
    self.iconView.image = icon;
}

- (void)setToast:(NSString *)toast
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.maximumLineHeight = 20;
    paragraphStyle.minimumLineHeight = 20;
    NSDictionary *attriDict = @{
        NSParagraphStyleAttributeName: paragraphStyle,
        NSFontAttributeName: [UIFont systemFontOfSize:14]
    };
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:toast attributes:attriDict];
    self.tipLab.attributedText = [attrStr copy];
}

#pragma mark - lazy load

- (UIImageView *)iconView
{
    if (!_iconView) {
        UIImage *image = [UIImage imageNamed:@"warn_ico"];
        _iconView = [[UIImageView alloc] initWithImage:image];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconView;
}

- (UILabel *)tipLab
{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.font = [UIFont systemFontOfSize:14];
        _tipLab.textColor = [UIColor whiteColor];
        _tipLab.backgroundColor = [UIColor clearColor];
        _tipLab.numberOfLines = 2;
    }
    return _tipLab;
}

@end
