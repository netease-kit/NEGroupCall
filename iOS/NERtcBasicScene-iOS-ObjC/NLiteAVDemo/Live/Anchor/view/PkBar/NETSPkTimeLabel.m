//
//  NETSPkTimeLabel.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSPkTimeLabel.h"
#import "UIView+NTES.h"

@interface NETSPkTimeLabel ()

/// 边框宽度
@property (nonatomic, assign)   CGFloat     borderWidth;
/// 计时状态
@property (nonatomic, assign, readwrite)   BOOL        isCounting;
/// 计时器
@property (nonatomic, strong)   dispatch_source_t   timer;

@end

@implementation NETSPkTimeLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, 62, 24);
    self = [super initWithFrame:rect];
    if (self) {
        _borderWidth = 0.5;
        
        self.font = [UIFont systemFontOfSize:12];
        self.textColor = [UIColor whiteColor];
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        self.textAlignment = NSTextAlignmentCenter;
        
        [self.layer addSublayer:[self renderLayer]];
        
        self.text = @"PK 00:00";
        self.backgroundColor = HEXCOLOR(0x1b1919);
    }
    return self;
}

- (void)dealloc
{
    NETSLog(@"释放倒计时控件: %p...", self);
}

- (void)setFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, 62, 24);
    [super setFrame:rect];
}

- (CAGradientLayer *)renderLayer
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = @[(__bridge id)[HEXCOLOR(0x004cc3) colorWithAlphaComponent:1.0].CGColor,
                             (__bridge id)[HEXCOLOR(0x7243b4) colorWithAlphaComponent:1.0].CGColor,
                             (__bridge id)[HEXCOLOR(0xda0043) colorWithAlphaComponent:1.0].CGColor];
    gradientLayer.startPoint = CGPointMake(.0, .0);
    gradientLayer.endPoint = CGPointMake(1.0, .0);

    CGRect rect = CGRectMake(_borderWidth, _borderWidth, self.width - _borderWidth * 2, self.height - _borderWidth *2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:12];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.lineWidth = _borderWidth;
    gradientLayer.mask = shapeLayer;
    
    return gradientLayer;
}

- (BOOL)countdownWithSeconds:(int32_t)seconds
{
    if (seconds > 3600) { return NO; }
    if (_isCounting) { return NO; }
    
    _isCounting = YES;
    
    __block int timeout = seconds;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if (timeout <= 0) {
            dispatch_source_cancel(self->_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.text = @"PK 00:00";
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *secondStr = [NSString stringWithFormat:@"%d", timeout % 60];
                if ([secondStr length] < 2) {
                    secondStr = [NSString stringWithFormat:@"0%@", secondStr];
                }
                int minutes = timeout / 60 % 60;
                self.text = [NSString stringWithFormat:@"PK %d:%@", minutes, secondStr];
                timeout--;
            });
        }
    });
    dispatch_resume(_timer);
    
    return YES;
}

- (void)stopCountdown
{
    _isCounting = NO;
    @try {
        dispatch_source_cancel(_timer);
    } @catch (NSException *exception) {
        NETSLog(@"释放定时器错误: %@", exception);
    }
}

@end
