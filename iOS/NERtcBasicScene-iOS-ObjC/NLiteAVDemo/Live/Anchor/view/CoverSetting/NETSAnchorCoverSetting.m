//
//  NETSAnchorCoverSetting.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/10.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSAnchorCoverSetting.h"
#import "UIButton+NTES.h"
#import "NETSLiveApi.h"

@interface NETSSingleImagePicker : UIView

/// 展示图片/提示标志
@property (nonatomic, strong)   UIImageView *imageView;
/// 删除选中图片按钮
@property (nonatomic, strong)   UIButton    *delImgBtn;
/// 提示图标
@property (nonatomic, strong)   UIImageView *tipIcon;
/// 提示文案
@property (nonatomic, strong)   UILabel     *tipLab;
/// 选中图片
@property (nonatomic, strong, nullable)   UIImage     *chosenImg;
/// 封面URL
@property (nonatomic, copy)     NSString    *coverUrl;

@end

@implementation NETSSingleImagePicker

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupViews];
//        [self bindAction];
        
        [NETSLiveApi randomCoverWithCompletionHandle:^(NSDictionary * _Nonnull response) {
            NSString *cover = response[@"/data"];
            self.coverUrl = cover;
        } errorHandle:nil];
    }
    return self;
}

//- (void)choseImage:(UITapGestureRecognizer *)gesture
//{
//    [NETSLiveApi randomCoverWithCompletionHandle:^(NSDictionary * _Nonnull response) {
//        NSString *cover = response[@"/data"];
//        self.coverUrl = cover;
//    } errorHandle:nil];
//}

- (void)setCoverUrl:(NSString *)coverUrl
{
    _coverUrl = coverUrl;
    self.tipIcon.hidden = self.tipLab.hidden = YES;
    self.imageView.hidden = self.delImgBtn.hidden = NO;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:_coverUrl]];
}

/// 初始化视图
- (void)setupViews
{
    [self addSubview:self.tipIcon];
    [self addSubview:self.tipLab];
    [self addSubview:self.imageView];
    [self addSubview:self.delImgBtn];
    
    NSArray *views = @[self.tipIcon, self.tipLab];
    [views mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedItemLength:20 leadSpacing:12 tailSpacing:12];
    [self.tipIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(20);
        make.centerX.equalTo(self);
    }];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.equalTo(self);
    }];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.delImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.right.equalTo(self).offset(5);
        make.top.equalTo(self).offset(-5);
    }];
}

/// 绑定事件
//- (void)bindAction
//{
//    self.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choseImage:)];
//    [self addGestureRecognizer:tap];
//}

- (void)setChosenImg:(UIImage *)chosenImg
{
    _chosenImg = chosenImg;
    if (_chosenImg) {
        self.imageView.image = _chosenImg;
        self.imageView.hidden = self.delImgBtn.hidden = NO;
    } else {
        self.imageView.image = nil;
        self.imageView.hidden = self.delImgBtn.hidden = NO;
    }
}

/// 点击按钮刷新封面
- (void)refreshChosenImage:(UIButton *)sender
{
    [NETSLiveApi randomCoverWithCompletionHandle:^(NSDictionary * _Nonnull response) {
        NSString *cover = response[@"/data"];
        self.coverUrl = cover;
    } errorHandle:nil];
}

/// 检测: 确保超出的删除按钮响应事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        CGPoint newPoint = [self.delImgBtn convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.delImgBtn.bounds, newPoint)) {
            view = self.delImgBtn;
        }
    }
    return view;
}

#pragma mark - lazy load

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIButton *)delImgBtn
{
    if (!_delImgBtn) {
        _delImgBtn = [[UIButton alloc] init];
        [_delImgBtn setImage:[UIImage imageNamed:@"refresh_solid_ico"] forState:UIControlStateNormal];
        [_delImgBtn addTarget:self action:@selector(refreshChosenImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _delImgBtn;
}

- (UIImageView *)tipIcon
{
    if (!_tipIcon) {
        _tipIcon = [[UIImageView alloc] init];
        _tipIcon.contentMode = UIViewContentModeScaleAspectFill;
        _tipIcon.image = [UIImage imageNamed:@"add_cover_ico"];
    }
    return _tipIcon;
}

- (UILabel *)tipLab
{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.font = [UIFont systemFontOfSize:10];
        _tipLab.text = @"设置封面";
        _tipLab.textAlignment = NSTextAlignmentCenter;
        _tipLab.textColor = [UIColor whiteColor];
    }
    return _tipLab;
}

@end

///

@interface NETSAnchorCoverSetting ()

/// 图片选择控件
@property (nonatomic, strong)   NETSSingleImagePicker   *imagePicker;
/// 签名输入框
@property (nonatomic, strong)   UITextView  *textView;
/// 随机签名按钮
@property (nonatomic, strong)   UIButton    *randomSign;

@end

@implementation NETSAnchorCoverSetting

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        
        [self setupViews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeText:) name:UITextViewTextDidChangeNotification object:self.textView];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews
{
    [self addSubview:self.imagePicker];
    [self addSubview:self.textView];
    [self addSubview:self.randomSign];
    
    [self.imagePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self).offset(12);
        make.size.mas_equalTo(CGSizeMake(64, 64));
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(12);
        make.left.equalTo(self.imagePicker.mas_right).offset(12);
        make.right.equalTo(self).offset(-12);
        make.height.mas_equalTo(40);
    }];
    [self.randomSign mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).offset(4);
        make.right.equalTo(self.textView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}

/// 随机签名按钮点击事件
- (void)randomSignClick:(UIButton *)sender
{
    [NETSLiveApi randowToipcWithCompletionHandle:^(NSDictionary * _Nonnull response) {
        NSString *topic = response[@"/data"];
        if (topic && [topic isKindOfClass:[NSString class]]) {
            self.textView.text = topic;
        }
    } errorHandle:nil];
    
}

- (NSString *)getTopic
{
    return self.textView.text;
}

- (NSString *)getCover
{
    return self.imagePicker.coverUrl;
}

/// 监听字符长度
- (void)textViewDidChangeText:(NSNotification *)notification
{
    static int kMaxLength = 20;
    UITextView *textView = (UITextView *)notification.object;
    NSString *toBeString = textView.text;

    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textView.text = [toBeString substringToIndex:kMaxLength];
            }
        } else {
            NETSLog(@"11111111111111========      %@",position);
        }
    } else {
        if (toBeString.length > kMaxLength) {
            textView.text = [toBeString substringToIndex:kMaxLength];
        }
    }
}

#pragma mark - lazy load

- (NETSSingleImagePicker *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[NETSSingleImagePicker alloc] init];
        _imagePicker.backgroundColor = HEXCOLOR(0x222222);
        _imagePicker.layer.cornerRadius = 2;
    }
    return _imagePicker;
}

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.textColor = [UIColor whiteColor];
        _textView.text = @"曲中传情，唱给你听";
        _textView.backgroundColor = [UIColor clearColor];
    }
    return _textView;
}

- (UIButton *)randomSign
{
    if (!_randomSign) {
        _randomSign = [[UIButton alloc] init];
        [_randomSign setImage:[UIImage imageNamed:@"random_topic_ico"] forState:UIControlStateNormal];
        [_randomSign addTarget:self action:@selector(randomSignClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _randomSign;
}

@end
