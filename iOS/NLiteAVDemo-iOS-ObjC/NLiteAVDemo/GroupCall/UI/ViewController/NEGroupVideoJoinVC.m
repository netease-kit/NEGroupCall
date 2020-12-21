//
//  NEGroupVideoViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/13.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEGroupVideoJoinVC.h"
#import "NEGroupVideoVC.h"
#import "NEEvaluateVC.h"
#import "NSString+NE.h"
#import "NEJoinRoomTask.h"
@interface NEGroupVideoJoinVC ()<UITextFieldDelegate,NEGroupVideoVCDelegate>
@property(strong,nonatomic)UITextField *textField;
@property(strong,nonatomic)UITextField *nickTextField;
@property(strong,nonatomic)UIButton *joinBtn;
@end

@implementation NEGroupVideoJoinVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self initUI];
}

- (void)initUI {
    self.title = @"加入频道";
    [self.view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(KNavBottom + 20);
        make.height.mas_equalTo(40);
    }];
    
    [self.view addSubview:self.nickTextField];
    [self.nickTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.textField.mas_bottom).offset(20);
        make.height.mas_equalTo(40);
    }];
    [self.view addSubview:self.joinBtn];
    [self.joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(-54);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

#pragma mark - event
- (void)joinBtn:(UIButton *)button {
    if (_textField.text.length <= 0) {
        [self.view makeToast:@"房间号不可为空"];
        return;
    }
    if (_textField.text.length > 12 || ![_textField.text ne_isNumber]) {
        [self.view makeToast:@"房间号仅支持12位及以下纯数字"];
        return;
    }
    NSString *nickname = _nickTextField.text;
    if (nickname.length == 0) {
        NSInteger number = 100000 + arc4random()%899999;
        nickname = [NSString stringWithFormat:@"用户%ld",(long)number];
    }
    [self joinRoom:_textField.text nickName:nickname];
}

- (void)gotoVideoVCWithTask:(NEJoinRoomTask *)task nickname:(NSString *)nickname{
    NEGroupVideoVC *groupVC = [[NEGroupVideoVC alloc] init];
    groupVC.delegate = self;
    groupVC.task = task;
    groupVC.nickname = nickname;
    groupVC.modalPresentationStyle = UIModalPresentationFullScreen;
    if (self.navigationController.presentingViewController) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [self.navigationController presentViewController:groupVC animated:YES completion:nil];
        }];
    }else {
        [self.navigationController presentViewController:groupVC animated:YES completion:nil];
    }
}
#pragma mark - request
- (void)joinRoom:(NSString *)roomID nickName:(NSString *)nickName {
    self.joinBtn.userInteractionEnabled = NO;
    NEJoinRoomTask *task = [NEJoinRoomTask task];
    task.req_mpRoomId = roomID;
    task.req_accountId = [NEAccount shared].userModel.accountId;
    task.req_nickName = nickName;
    task.req_clientType = 2;
    WEAK_SELF(weakSelf);
    [task postWithCompletion:^(NSDictionary * _Nullable data, id  _Nullable task, NSError * _Nullable error) {
        STRONG_SELF(strongSelf);
        strongSelf.joinBtn.userInteractionEnabled = YES;
        if (error) {
            NSString *message;
            if (error.code == 2001) {
                message = @"本应用为测试产品，每个频道最多4人";
            }else {
                message = error.localizedDescription;
            }
            [self.view makeToast:message duration:3 position:CSToastPositionCenter];
        }else {
            [strongSelf gotoVideoVCWithTask:task nickname:nickName];
        }
        NSLog(@"data:%@  error:%@",data,error);
    }];
}
#pragma mark - NEGroupVideoVCDelegate
- (void)didLeaveRoom:(NSString *)roomID roomUid:(NSInteger)uid{
    NEEvaluateVC *evaluateVC = [[NEEvaluateVC alloc] initWithUnfold:NO];
    evaluateVC.roomID = roomID;
    evaluateVC.roomUID = uid;
    evaluateVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:evaluateVC animated:YES completion:nil];
}
#pragma mark - get
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.backgroundColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:54/255.0 alpha:1/1.0];
        _textField.delegate = self;
        _textField.textColor = [UIColor whiteColor];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"输入相同房间号即可通话" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:_textField.font}];
        _textField.attributedPlaceholder = string;
        _textField.layer.cornerRadius = 8;
        
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        
        UIView *leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 40)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.leftView = leftview;
    }
    return _textField;
}

- (UITextField *)nickTextField {
    if (!_nickTextField) {
        _nickTextField = [[UITextField alloc] init];
        _nickTextField.backgroundColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:54/255.0 alpha:1/1.0];
        _nickTextField.delegate = self;
        _nickTextField.textColor = [UIColor whiteColor];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"输入昵称" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:_nickTextField.font}];
        _nickTextField.attributedPlaceholder = string;
        _nickTextField.layer.cornerRadius = 8;
        
        _nickTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nickTextField.returnKeyType = UIReturnKeySearch;
        
        UIView *leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 40)];
        _nickTextField.leftViewMode = UITextFieldViewModeAlways;
        _nickTextField.leftView = leftview;
    }
    return _nickTextField;
}
- (UIButton *)joinBtn {
    if (!_joinBtn) {
        _joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _joinBtn.layer.cornerRadius = 25;
        _joinBtn.clipsToBounds = YES;
        [_joinBtn addTarget:self action:@selector(joinBtn:) forControlEvents:UIControlEventTouchUpInside];
        _joinBtn.backgroundColor = [UIColor colorWithRed:51/255.0 green:126/255.0 blue:255/255.0 alpha:1/1.0];
        _joinBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_joinBtn setTitle:@"加入频道" forState:UIControlStateNormal];
    }
    return _joinBtn;
}

@end
