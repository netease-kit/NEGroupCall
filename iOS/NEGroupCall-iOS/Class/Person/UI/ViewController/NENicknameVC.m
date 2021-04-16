//
//  NENicknameVC.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NENicknameVC.h"
#import "NEModifyNicknameTask.h"
#import "NEUser.h"
#import "NEAccount.h"

@interface NENicknameVC ()<UITextFieldDelegate>

@end

@implementation NENicknameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改昵称";
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneEvent)];
       self.navigationItem.rightBarButtonItem = rightBar;
    [self.view addSubview:self.nickTextField];
    [self.nickTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(KNavBottom + 20);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(56);
    }];
}
- (void)doneEvent {
    [self.view endEditing:YES];
    [self modifyNickname:self.nickTextField.text];
}
- (void)modifyNickname:(NSString *)nickName {
    if (nickName.length <= 0) {
        [self.view makeToast:@"昵称不可以为空哦"];
        return;
    }else if (nickName.length > 12) {
        [self.view makeToast:@"仅支持12位及以下文本、字母及数字组合"];
        return;
    }
    NEModifyNicknameTask *task = [NEModifyNicknameTask task];
    task.req_nickname = nickName;
    [task postWithCompletion:^(NSDictionary * _Nullable data, id  _Nullable task, NSError * _Nullable error) {
        NSLog(@"error:%@ data:%@",error,data);
        if (error) {
            [self.view makeToast:error.localizedDescription];
        }else {
            NSDictionary *userDic = [data objectForKey:@"data"];
            NEUser *user = [[NEUser alloc] initWithDictionary:userDic];
            [NEAccount updateUserInfo:user];
            [self.view makeToast:@"修改成功"];
            if (self.didModifyNickname) {
                self.didModifyNickname(user.nickname);
            }
        }
    }];
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
        _nickTextField.returnKeyType = UIReturnKeyDone;
        
        UIView *leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 40)];
        _nickTextField.leftViewMode = UITextFieldViewModeAlways;
        _nickTextField.leftView = leftview;
    }
    return _nickTextField;
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
