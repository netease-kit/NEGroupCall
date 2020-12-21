//
//  NEPersonInfoVC.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEPersonInfoVC.h"
#import "NEPersonTableViewCell.h"
#import "NEPersonTextCell.h"
#import "NEAccount.h"
#import "NENicknameVC.h"

@interface NEPersonInfoVC ()
@property(strong,nonatomic)NSArray *dataArray;
@property(strong,nonatomic)NSString *nickname;

@end

@implementation NEPersonInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    if ([NEAccount shared].hasLogin) {
        self.dataArray = @[@[@"头像",@"昵称"],@[@"退出登录"]];
    }else {
        self.dataArray = @[@[@"头像",@"昵称"]];
    }
}
- (void)setupUI {
    self.title = @"个人信息";
    [self.tableView registerClass:[NEPersonTextCell class] forCellReuseIdentifier:@"NEPersonTextCell"];
    [self.tableView registerClass:[NEPersonTableViewCell class] forCellReuseIdentifier:@"NEPersonTableViewCell"];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = [self.dataArray objectAtIndex:section];
    if ([sectionArray isKindOfClass:[NSArray class]]) {
        return sectionArray.count;
    }else {
        return 0;
    }
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NEPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NEPersonTableViewCell" forIndexPath:indexPath];
        NSArray *sectionArray = self.dataArray[indexPath.section];
        NSString *content = sectionArray[indexPath.row];
        if (indexPath.row == 0) {
            [cell.personView.indicatorImageView sd_setImageWithURL:[NSURL URLWithString:NEAccount.shared.userModel.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
        }else {
            
            NSString *nickname = NEAccount.shared.userModel.nickname.length ? NEAccount.shared.userModel.nickname : @"";
            cell.personView.detailLabel.text = nickname;
            cell.personView.indicatorImageView.image = [UIImage imageNamed:@"menu_arrow"];
        }
        cell.personView.titleLabel.text = content;
        return cell;
    }else {
        NEPersonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NEPersonTextCell" forIndexPath:indexPath];
        cell.titleLabel.text = @"退出登录";
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            //修改昵称
            NENicknameVC *nickNameVC = [[NENicknameVC alloc] init];
            WEAK_SELF(weakSelf);
            nickNameVC.didModifyNickname = ^(NSString * _Nonnull nickName) {
                STRONG_SELF(strongSelf);
                strongSelf.nickname = nickName;
                [strongSelf.tableView reloadData];
            };
            [self.navigationController pushViewController:nickNameVC animated:YES];
        }
    }else {
        if (indexPath.row == 0) {
            //退出登录
            [self logout];
        }
    }
}
- (void)logout {
    UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"确认退出登录%@",[NEAccount shared].userModel.mobile] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [NEAccount logoutWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            if (error) {
                [self.view makeToast:error.localizedDescription];
            }else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
    [alerVC addAction:cancelAction];
    [alerVC addAction:okAction];
    [self presentViewController:alerVC animated:YES completion:nil];
}
@end
