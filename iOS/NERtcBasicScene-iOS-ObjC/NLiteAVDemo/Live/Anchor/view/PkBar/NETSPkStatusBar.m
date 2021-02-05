//
//  NETSPkStatusBar.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSPkStatusBar.h"
#import "UIView+NTES.h"
#import "NETSPkTimeLabel.h"
#import "NETSLiveModel.h"
#import "UIView+NTES.h"

/**
 打赏头像
 */
@interface NETSPkStatusBarRewardAvatar: UIView

@property (nonatomic, strong)   UIImageView *avatar;
@property (nonatomic, strong)   UILabel     *index;
@property (nonatomic, strong)   UIColor     *tintColor;

@end

@implementation NETSPkStatusBarRewardAvatar

- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, 24, 30);
    self = [super initWithFrame:rect];
    if (self) {
        [self addSubview:self.avatar];
        [self addSubview:self.index];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, 24, 30);
    [super setFrame:rect];
}

- (void)layoutSubviews
{
    self.avatar.frame = CGRectMake(0, 0, 24, 24);
    self.index.frame = CGRectMake(6, self.avatar.bottom - 6, 12, 12);
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    self.avatar.layer.borderColor = tintColor.CGColor;
    self.index.backgroundColor = tintColor;
}

#pragma mark - lazy load

- (UIImageView *)avatar
{
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
        _avatar.layer.borderColor = _tintColor.CGColor;
        _avatar.layer.borderWidth = 0.5;
        _avatar.layer.cornerRadius = 12;
        _avatar.layer.masksToBounds = YES;
    }
    return _avatar;
}

- (UILabel *)index
{
    if (!_index) {
        _index = [[UILabel alloc] init];
        _index.textAlignment = NSTextAlignmentCenter;
        _index.backgroundColor = _tintColor;
        _index.textColor = [UIColor whiteColor];
        _index.font = [UIFont systemFontOfSize:10];
        _index.layer.cornerRadius = 6;
        _index.layer.masksToBounds = YES;
    }
    return _index;
}

@end

/**
 打赏榜
 */
@interface NETSPkStatusBarReward: UIView

@property (nonatomic, strong)   UIColor     *tintColor;

@end

@implementation NETSPkStatusBarReward

- (void)setFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, 84, 30);
    [super setFrame:rect];
}

- (void)refreshAvatars:(NSArray<NSString *> *)avatars leftAlign:(BOOL)leftAlign
{
    for (UIView *sub in self.subviews) {
        [sub removeFromSuperview];
    }
    
    NSArray *topArr = avatars;
    if ([avatars count] > 3) {
        topArr = [avatars subarrayWithRange:NSMakeRange(0, 3)];
    }
    if (!leftAlign) {
        topArr = [[topArr reverseObjectEnumerator] allObjects];
    }
    for (NSInteger i = 0; i < [topArr count]; i++) {
        NSString *avatar = topArr[i];
        [self _installWithAvatar:avatar index:i leftAlign:leftAlign];
    }
}

- (void)_installWithAvatar:(NSString *)avatar index:(NSInteger)index leftAlign:(BOOL)leftAlign
{
    CGRect frame = CGRectMake((4 + 24) * index, 0, 24, 30);
    if (!leftAlign) {
        frame = CGRectMake((4 + 24) * (2 - index), 0, 24, 30);
    }
    NETSPkStatusBarRewardAvatar *rewardAvatar = [[NETSPkStatusBarRewardAvatar alloc] initWithFrame:frame];
    rewardAvatar.tintColor = _tintColor ?: HEXCOLOR(0x008efc);
    [self addSubview:rewardAvatar];
    [rewardAvatar.avatar sd_setImageWithURL:[NSURL URLWithString:avatar]];
    rewardAvatar.index.text = [NSString stringWithFormat:@"%ld", (long)(index + 1)];
}

@end

///

/**
 pk状态条
 */

@interface NETSPkStatusBar ()

/// 比分条
@property (nonatomic, strong)   UIView  *scoreBar;
/// 我方数值
@property (nonatomic, strong)   UILabel *leftValLab;
/// 对方数值
@property (nonatomic, strong)   UILabel *rightValLab;
/// 时间
@property (nonatomic, strong)   NETSPkTimeLabel *timeLab;
/// 比分渲染图层
@property (nonatomic, strong)   CAGradientLayer *renderLayer;
/// 星标
@property (nonatomic, strong)   UIImageView     *starIco;
/// 邀请者打赏榜
@property (nonatomic, strong)   NETSPkStatusBarReward   *inviterReward;
/// 被邀请者打赏榜
@property (nonatomic, strong)   NETSPkStatusBarReward   *inviteeReward;

@end

@implementation NETSPkStatusBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.scoreBar];
        [self addSubview:self.leftValLab];
        [self addSubview:self.rightValLab];
        [self addSubview:self.timeLab];
        [self addSubview:self.inviterReward];
        [self addSubview:self.inviteeReward];
        [self addSubview:self.starIco];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 58);
    [super setFrame:rect];
}

- (void)layoutSubviews
{
    self.scoreBar.frame = CGRectMake(0, 0, self.width, 18);
    self.leftValLab.frame = CGRectMake(8, self.scoreBar.top, 100, self.scoreBar.height);
    self.rightValLab.frame = CGRectMake(self.width - 8 - 100, self.scoreBar.top, 100, self.scoreBar.height);
    self.timeLab.frame = CGRectMake((self.width - 62) / 2.0, self.scoreBar.bottom + 8, 62, 24);
    self.inviterReward.frame = CGRectMake(8, self.scoreBar.bottom + 8, 84, 30);
    self.inviteeReward.frame = CGRectMake(self.width - 8 - 84, self.inviterReward.top, 84, 30);
    
    self.starIco.frame = CGRectMake(0, 0, 20, 26);
    self.starIco.center = self.scoreBar.center;
}

- (void)_refreshLeftRewardCoins:(int64_t)inviterRewardCoins rightRewardCoins:(int64_t)inviteeRewardCoins
{
    self.leftValLab.text = [NSString stringWithFormat:@"我方 %lld", inviterRewardCoins];
    self.rightValLab.text = [NSString stringWithFormat:@"%lld 对方", inviteeRewardCoins];
    
    // 修改渐变色渲染
    CGFloat scale = 0.5;
    if (inviterRewardCoins + inviteeRewardCoins > 0) {
        scale = (CGFloat)inviterRewardCoins / (inviterRewardCoins + inviteeRewardCoins);
    }
    self.renderLayer.locations = @[@(0.0f), @(scale), @(scale), @(1.0f)];
    [self.scoreBar.layer addSublayer:self.renderLayer];
    
    CGFloat pointX = self.scoreBar.width * scale;
    [UIView animateWithDuration:0.2 animations:^{
        self.starIco.left = pointX - self.starIco.width / 2.0;
    }];
}

- (void)_refreshLeftAvatars:(nullable NSArray<NSString *> *)inviterAvatars rightAvatars:(nullable NSArray<NSString *> *)inviteeAvatars
{
    if (inviterAvatars) {
        [self.inviterReward refreshAvatars:inviterAvatars leftAlign:YES];
    }
    if (inviteeAvatars) {
        [self.inviteeReward refreshAvatars:inviteeAvatars leftAlign:NO];
    }
}

- (void)refreshWithLeftRewardCoins:(int32_t)leftRewardCoins
                 leftRewardAvatars:(nullable NSArray<NSString *> *)leftRewardAvatars
                  rightRewardCoins:(int32_t)rightRewardCoins
                rightRewardAvatars:(nullable NSArray<NSString *> *)rightRewardAvatars
{
    [self _refreshLeftRewardCoins:leftRewardCoins rightRewardCoins:rightRewardCoins];
    [self _refreshLeftAvatars:leftRewardAvatars rightAvatars:rightRewardAvatars];
}

- (void)countdownWithSeconds:(int32_t)seconds
{
    [self stopCountdown];
    [self.timeLab countdownWithSeconds:seconds];
}

/// 停止计时器
- (void)stopCountdown
{
    if (self.timeLab.isCounting) {
        self.timeLab.text = @"PK 00:00";
        [self.timeLab stopCountdown];
    }
}

#pragma mark - lazy load

- (UIView *)scoreBar
{
    if (!_scoreBar) {
        _scoreBar = [[UIView alloc] init];
        _scoreBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _scoreBar;
}

- (UILabel *)leftValLab
{
    if (!_leftValLab) {
        _leftValLab = [[UILabel alloc] init];
        _leftValLab.font = [UIFont systemFontOfSize:12];
        _leftValLab.textColor = [UIColor whiteColor];
    }
    return _leftValLab;
}

- (UILabel *)rightValLab
{
    if (!_rightValLab) {
        _rightValLab = [[UILabel alloc] init];
        _rightValLab.font = [UIFont systemFontOfSize:12];
        _rightValLab.textColor = [UIColor whiteColor];
        _rightValLab.textAlignment = NSTextAlignmentRight;
    }
    return _rightValLab;
}

- (NETSPkTimeLabel *)timeLab
{
    if (!_timeLab) {
        _timeLab = [[NETSPkTimeLabel alloc] initWithFrame:CGRectZero];
    }
    return _timeLab;
}

- (CAGradientLayer *)renderLayer
{
    if (!_renderLayer) {
        _renderLayer = [CAGradientLayer layer];
        _renderLayer.frame = CGRectMake(0, 0, self.width, 18);
        _renderLayer.colors = @[(__bridge id)[HEXCOLOR(0x004cc3) colorWithAlphaComponent:1.0].CGColor,
                                 (__bridge id)[HEXCOLOR(0x0aa2fb) colorWithAlphaComponent:1.0].CGColor,
                                 (__bridge id)[HEXCOLOR(0xe800d1) colorWithAlphaComponent:1.0].CGColor,
                                 (__bridge id)[HEXCOLOR(0xda0043) colorWithAlphaComponent:1.0].CGColor];
        _renderLayer.startPoint = (CGPoint){0.0};
        _renderLayer.endPoint = (CGPoint){1.0};
        _renderLayer.locations = @[@(0.0f), @(0.5f), @(0.5f), @(1.0f)];
        
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = (CGRect){.0, .0, self.width, 18};
        maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
        
        _renderLayer.mask = maskLayer;
    }
    return _renderLayer;
}

- (UIImageView *)starIco
{
    if (!_starIco) {
        UIImage *image = [UIImage imageNamed:@"pk_star"];
        _starIco = [[UIImageView alloc] initWithImage:image];
    }
    return _starIco;
}

- (NETSPkStatusBarReward *)inviterReward
{
    if (!_inviterReward) {
        _inviterReward = [[NETSPkStatusBarReward alloc] init];
        _inviterReward.tintColor = HEXCOLOR(0x008efc);
    }
    return _inviterReward;
}

- (NETSPkStatusBarReward *)inviteeReward
{
    if (!_inviteeReward) {
        _inviteeReward = [[NETSPkStatusBarReward alloc] init];
        _inviteeReward.tintColor = HEXCOLOR(0xfa0074);
    }
    return _inviteeReward;
}

@end
