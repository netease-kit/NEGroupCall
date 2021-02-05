//
//  NETSSettingSegmented.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSSettingSegmented.h"
#import "UIImage+NTES.h"

@implementation NETSSettingSegmented

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self config];
    }
    return self;
}

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super initWithItems:items];
    if (self) {
        [self config];
        for (UIView *segment in self.subviews) {
            if ([segment isKindOfClass:NSClassFromString(@"UISegment")]) {
                [segment addObserver:self forKeyPath:@"selected" options:(NSKeyValueObservingOptionNew & NSKeyValueObservingOptionInitial) context:nil];
            }
        }
    }
    return self;
}

- (void)config
{
    self.tintColor = [UIColor clearColor];
    self.backgroundColor = HEXCOLOR(0xf0f1f3);
    
    NSDictionary *normalAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:HEXCOLOR(0x222222)};
    NSDictionary *selectedAttr = @{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self setTitleTextAttributes:normalAttr forState:UIControlStateNormal];
    [self setTitleTextAttributes:selectedAttr forState:UIControlStateSelected];
    
    for (NSNumber *leftStateNum in @[@(UIControlStateNormal), @(UIControlStateSelected)]) {
        for (NSNumber *rightStateNum in @[@(UIControlStateNormal), @(UIControlStateSelected)]) {
            UIImage *dividerImg = [UIImage ne_imageWithColor:[UIColor whiteColor]];
            UIControlState leftState = [leftStateNum unsignedIntValue];
            UIControlState rightState = [rightStateNum unsignedIntValue];
            [self setDividerImage:dividerImg forLeftSegmentState:leftState rightSegmentState:rightState barMetrics:UIBarMetricsDefault];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (![object isKindOfClass:[UIView class]]) {
        return;
    }
    UIView *segment = (UIView *)object;
    BOOL isSelected = [[segment valueForKey:@"selected"] intValue] == 1;
    segment.backgroundColor = isSelected ? HEXCOLOR(0x2778fc) : HEXCOLOR(0xf0f1f3);
}

- (void)dealloc
{
    for (UIView *segment in self.subviews) {
        if ([segment isKindOfClass:NSClassFromString(@"UISegment")]) {
            [segment removeObserver:self forKeyPath:@"selected"];
        }
    }
}

@end
