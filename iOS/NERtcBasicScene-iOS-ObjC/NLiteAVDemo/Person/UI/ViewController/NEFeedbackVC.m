//
//  NEFeedbackVC.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/22.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEFeedbackVC.h"
#import "NEPersonTableViewCell.h"
#import "NEFeedbackInputCell.h"
#import "NEFeedbackListVC.h"
#import "NEEvaluateTask.h"
#import "NEAccount.h"
#import "NEFeedbackDemoVC.h"

@interface NEFeedbackVC ()
@property(strong,nonatomic)NSMutableArray *selectItemCodes;
@property(strong,nonatomic)NSString *type;
@property(strong,nonatomic)NSString *demoType;
@property(strong,nonatomic)NEFeedbackInputCell *cell;

@end

@implementation NEFeedbackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
}
- (void)setupUI {
    self.title = @"意见反馈";
    [self.tableView registerClass:[NEPersonTableViewCell class] forCellReuseIdentifier:@"NEPersonTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NEFeedbackInputCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NEFeedbackInputCell"];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(0, 0, kScreenWidth, 150);
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.layer.cornerRadius = 25;
    submitBtn.clipsToBounds = YES;
    [submitBtn addTarget:self action:@selector(submitBtn:) forControlEvents:UIControlEventTouchUpInside];
    submitBtn.backgroundColor = [UIColor colorWithRed:51/255.0 green:126/255.0 blue:255/255.0 alpha:1/1.0];
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [bgView addSubview:submitBtn];
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(56);
    }];
    self.tableView.tableFooterView = bgView;
}
#pragma mark - event
- (void)submitBtn:(UIButton *)button {
    if (self.selectItemCodes.count || self.cell.textView.text.length) {
        // 提交请求
        [self submitFeedback];
        [self.view makeToast:@"感谢您的反馈"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }else {
        [self.view makeToast:@"提交内容为空"];
    }
}
- (void)tap:(UITapGestureRecognizer *)tap {
    NSLog(@"tap:%@",tap);
    [self.view endEditing:YES];
}
#pragma mark - request
- (void)submitFeedback {
    //提交请求
    NEEvaluateTask *task = [NEEvaluateTask task];
    task.req_appkey = kAppKey;
    task.req_appid = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    task.req_cid = @"unkown";
    task.req_uid = NEAccount.shared.userModel.accountId;
    task.req_type = 2;
    task.req_contact = NEAccount.shared.userModel.mobile;
    task.req_content = self.cell.textView.text?:@"";
    task.req_conetent_type = [self.selectItemCodes copy];
    task.req_feedback_type = @(0);
    task.req_feedback_source = self.demoType;
    [task postWithCompletion:^(NSDictionary * _Nullable data, id  _Nullable task, NSError * _Nullable error) {
        NSLog(@"data:%@ error:%@",data,error);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }else if(section == 1) {
        return 1;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 56;
    }else {
        return 160;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NEPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NEPersonTableViewCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
             cell.personView.titleLabel.text = @"Demo类型";
            cell.personView.detailLabel.text = self.demoType ? self.demoType : @"请选择Demo类型";
            cell.personView.indicatorImageView.image = [UIImage imageNamed:@"menu_arrow"];
        }else {
            cell.personView.titleLabel.text = @"问题类型";
            cell.personView.detailLabel.text = self.type ? self.type : @"请选择问题类型";
            cell.personView.indicatorImageView.image = [UIImage imageNamed:@"menu_arrow"];
        }
        return cell;
    }else {
        NEFeedbackInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NEFeedbackInputCell" forIndexPath:indexPath];
        self.cell = cell;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            WEAK_SELF(weakSelf);
            NEFeedbackDemoVC *demoVC = [[NEFeedbackDemoVC alloc ] init];
            demoVC.didSelectDemo = ^(NSString * _Nonnull demo) {
                STRONG_SELF(strongSelf);
                strongSelf.demoType = demo;
                [self.tableView reloadData];
            };
            demoVC.selectedDemo = self.demoType;
            [self.navigationController pushViewController:demoVC animated:YES];

        }else {
            NEFeedbackListVC *listVC = [[NEFeedbackListVC alloc] init];
            listVC.didSelectResult = ^(NSArray<NEFeedbackInfo *> * _Nonnull result) {
                NSMutableArray *array = [NSMutableArray array];
                NSString *type;
                for (NEFeedbackInfo *info in result) {
                    if (info.isSelected) {
                        type = info.title;
                    }
                    for (NEFeedbackInfo *item in info.items) {
                        if (item.isSelected && item.code) {
                            [array addObject:@(item.code)];
                        }
                    }
                }
                self.type = type;
                self.selectItemCodes = array;
                [self.tableView reloadData];
            };
            [self.navigationController pushViewController:listVC animated:YES];
        }
        
    }
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
