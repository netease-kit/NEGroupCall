//
//  NETSGiftAnimationView.m
//  NLiteAVDemo
//
//  Created by Think on 2021/1/21.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSGiftAnimationView.h"
#import "LOTAnimationView.h"
#import "UIView+NTES.h"

@interface NETSGiftAnimationView ()

/// 保护队列
@property (nonatomic, strong)   dispatch_queue_t    queue;
/// 礼物集合
@property (nonatomic, strong)   NSMutableArray      *gifts;
/// 动画控件
@property (nonatomic, strong)   LOTAnimationView    *animationView;

@end

@implementation NETSGiftAnimationView

- (instancetype)init
{
    CGRect rect = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self = [super initWithFrame:rect];
    if (self) {
        _queue = dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL);
        _gifts = [NSMutableArray array];
        [self addSubview:self.animationView];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)addGift:(NSString *)gift
{
    dispatch_sync(_queue, ^{
        [self.gifts addObject:gift];
        [self _play];
    });
}

- (void)_removeFirstGift
{
    dispatch_sync(_queue, ^{
        if ([self.gifts count] > 0) {
            [self.gifts removeObjectAtIndex:0];
        }
    });
}

- (void)_play
{
    if (self.animationView.isAnimationPlaying || [self.gifts count] == 0) {
        return;
    }
    NSString *gift = [self.gifts firstObject];
    [self.animationView setAnimationNamed:gift];
    ntes_main_async_safe(^{
        self.animationView.hidden = NO;
        [self.animationView playWithCompletion:^(BOOL animationFinished) {
            if (!animationFinished) {
                return;
            }
            self.animationView.hidden = YES;
            [self _removeFirstGift];
            [self _play];
        }];
    });
}

#pragma mark - lazy load

- (LOTAnimationView *)animationView
{
    if (!_animationView) {
        CGRect rect = CGRectMake(0, (self.height - self.width) / 2, self.width, self.width);
        _animationView = [[LOTAnimationView alloc] initWithFrame:rect];
    }
    return _animationView;
}

@end
