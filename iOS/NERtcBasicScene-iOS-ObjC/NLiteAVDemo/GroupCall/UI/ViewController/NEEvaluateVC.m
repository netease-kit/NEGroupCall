//
//  NEEvaluateVC.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEEvaluateVC.h"
#import "NEEvaluateThankView.h"
#import "NEEvaluateTask.h"
#import "NEAccount.h"
#import "NEEvaluateListView.h"

@interface NEEvaluateVC ()
@property(strong,nonatomic)UIView *contentView;

@property(strong,nonatomic)UILabel *titleLabel;
@property(strong,nonatomic)UIButton *okButton;
@property(strong,nonatomic)UIButton *badButton;

@property(strong,nonatomic)NSArray *itemName;

@property(strong,nonatomic)UIButton *submitButton;

@property(assign,nonatomic)BOOL hasUnfold;
@property(assign,nonatomic)NSInteger rowSpace;
@property(assign,nonatomic)BOOL unfold;
@property(strong,nonatomic)UITextView *textView;
@property(assign,nonatomic)NSInteger isGood;
@property(strong,nonatomic)NSMutableArray *selectTypes;
@property(strong,nonatomic)NEEvaluateListView *listView;

@end

@implementation NEEvaluateVC
- (instancetype)initWithUnfold:(BOOL)unfold
{
    self = [super init];
    if (self) {
        self.unfold = unfold;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.unfold) {
        [self badButtonEvent:nil];
    }else {
        [self initUI];
    }
    [self initData];
//    [self addObserve];
}
- (void)initUI {
    self.rowSpace = KIsSmallSize ? 10:20;
//    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
//    self.contentView.frame = CGRectMake(0, kScreenHeight - 172 - 30, kScreenWidth, 172 + 30);
    [self.view addSubview:self.contentView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(30);
        make.height.mas_equalTo(172 + 30);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"通话品质如何？";
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    [self.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(28);
        make.height.mas_equalTo(28);
    }];
    self.titleLabel = titleLabel;
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:closeBtn];
    
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-7);
        make.top.mas_equalTo(self.contentView.mas_top).offset(7);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    okButton.layer.cornerRadius = 2;
    [okButton setTitle:@"好" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [okButton setImage:[UIImage imageNamed:@"dianzan"] forState:UIControlStateNormal];
    [okButton setImage:[UIImage imageNamed:@"dianzanSelect"] forState:UIControlStateSelected];
    [okButton addTarget:self action:@selector(okButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    okButton.backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1/1.0];
    self.okButton = okButton;
    
    UIButton *badButton = [UIButton buttonWithType:UIButtonTypeCustom];
    badButton.layer.cornerRadius = 2;
    badButton.backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1/1.0];
    [badButton setTitle:@"差" forState:UIControlStateNormal];
    [badButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [badButton setImage:[UIImage imageNamed:@"chaping"] forState:UIControlStateNormal];
    [badButton setImage:[UIImage imageNamed:@"chapingSelect"] forState:UIControlStateSelected];
    [badButton addTarget:self action:@selector(badButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.badButton = badButton;
    [self.contentView addSubview:okButton];
    [self.contentView addSubview:badButton];
    [okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(50);
        make.right.mas_equalTo(badButton.mas_left).offset(-10);
        make.width.mas_equalTo(badButton.mas_width);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(self.rowSpace);
    }];
    [badButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(badButton.mas_width);
        make.top.mas_equalTo(okButton.mas_top);
    }];
}
- (void)initData {
    self.itemName = @[@"听不到声音",@"机械音、杂音",@"声音卡顿",@"看不到画面",@"画面卡顿",@"画面模糊",@"声音画面不同步",@"意外退出"];
}

#pragma mark - private method
- (void)showGoodResult {
    NEEvaluateThankView *evaluateView = [[NEEvaluateThankView alloc] init];
    [self.contentView addSubview:evaluateView];
    [evaluateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(148);
        make.left.right.bottom.mas_equalTo(0);
    }];
    [UIView animateWithDuration:.25 animations:^{
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(30);
            make.height.mas_equalTo(247 + 30);
        }];
    } completion:^(BOOL finished) {

    }];
    //消失
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}
- (void)showSubmitResult {
    self.submitButton.hidden = YES;
    NEEvaluateThankView *thankView = [[NEEvaluateThankView alloc] init];
    [self.contentView addSubview:thankView];
    [thankView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.submitButton);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(48);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}
#pragma mark - request
- (void)submitFeedback {
    //提交请求
    NEEvaluateTask *task = [NEEvaluateTask task];
    task.req_appkey = kAppKey;
    task.req_appid = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    task.req_cid = self.roomID;
    task.req_uid = [NSString stringWithFormat:@"%ld",(long)self.roomUID];
    task.req_type = 2;
    task.req_contact = NEAccount.shared.userModel.mobile;
    task.req_content = self.textView.text;
    task.req_conetent_type = [self.selectTypes copy];
    task.req_feedback_type = self.isGood?@(1):@(0);
    task.req_feedback_source = @"多人视频通话Demo";
    WEAK_SELF(weakSelf);
    [task postWithCompletion:^(NSDictionary * _Nullable data, id  _Nullable task, NSError * _Nullable error) {
        NSLog(@"提交反馈error：%@ data:%@",error,data);
        STRONG_SELF(strongSelf);
        if (strongSelf.hasUnfold) {
            [strongSelf showSubmitResult];
        }else {
            [self showGoodResult];
        }
    }];
}
#pragma mark - event
- (void)okButtonEvent:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        button.backgroundColor = [UIColor colorWithRed:51/255.0 green:126/255.0 blue:255/255.0 alpha:0.1/1.0];
    }else {
        button.backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1/1.0];
    }
    self.isGood = 1;
    [self submitFeedback];
}
- (void)closeBtn:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)badButtonEvent:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        button.backgroundColor = [UIColor colorWithRed:242/255.0 green:73/255.0 blue:87/255.0 alpha:0.1/1.0];
    }else {
        button.backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1/1.0];
    }
    self.isGood = 0;
    self.hasUnfold = YES;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = @"很抱歉给您带来的不便～ 请问您具体遇到了什么问题？";
    titleLabel.numberOfLines = 0;
    [self.contentView addSubview:titleLabel];
    if (button) {
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(button.mas_bottom).offset(self.rowSpace);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(44);
        }];
    }else {
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(KNavBottom);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(44);
        }];
    }
    
    [self.contentView addSubview:self.listView];
    WEAK_SELF(weakSelf);
    self.listView.didSelectedIndex = ^(NSInteger index, BOOL selected) {
        STRONG_SELF(strongSelf);
        [strongSelf handleSelected:selected index:index];
    };
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(self.rowSpace);
        make.height.mas_equalTo(self.itemName.count * 32);
    }];

    //文本
    UITextView *textView = [[UITextView alloc] init];
    textView.layer.borderWidth = 1.0;
    textView.layer.cornerRadius = 2;
    textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    textView.delegate = self;
    [self.contentView addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.listView.mas_bottom).offset(self.rowSpace);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(80);
    }];
    self.textView = textView;
    //提交button
    [self.contentView addSubview:self.submitButton];
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(textView.mas_bottom).offset(self.rowSpace);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(50);
    }];
    
    [UIView animateWithDuration:.25 animations:^{
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.bottom.mas_equalTo(20);
            make.height.mas_equalTo(28 + 28 + self.rowSpace + 50 + self.rowSpace + 44  + self.itemName.count * 32 + 10 + 80 + self.rowSpace + 50 + self.rowSpace + 30);
        }];
    } completion:^(BOOL finished) {
        
    }];
    
}
- (void)handleSelected:(BOOL)selected index:(NSInteger)index {
    NSNumber *typeTag = @(index + 101);
    if (selected) {
        if (![self.selectTypes containsObject:typeTag]) {
            [self.selectTypes addObject:typeTag];
        }
    }else {
        if ([self.selectTypes containsObject:typeTag]) {
            [self.selectTypes removeObject:typeTag];
        }
    }
}

- (void)submitBtn:(UIButton *)button {
    //提交请求
    [self submitFeedback];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - get

- (NSMutableArray *)selectTypes {
    if (!_selectTypes) {
        _selectTypes = [NSMutableArray array];
    }
    return _selectTypes;
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 30;
    }
    return _contentView;
}

- (UIButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitButton.layer.cornerRadius = 25;
        _submitButton.clipsToBounds = YES;
        [_submitButton addTarget:self action:@selector(submitBtn:) forControlEvents:UIControlEventTouchUpInside];
        _submitButton.backgroundColor = [UIColor colorWithRed:51/255.0 green:126/255.0 blue:255/255.0 alpha:1/1.0];
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_submitButton setTitle:@"提交" forState:UIControlStateNormal];
    }
    return _submitButton;
}

- (NEEvaluateListView *)listView {
    if (!_listView) {
        _listView = [[NEEvaluateListView alloc] initWithTitleArray:self.itemName];
    }
    return _listView;
}
@end
