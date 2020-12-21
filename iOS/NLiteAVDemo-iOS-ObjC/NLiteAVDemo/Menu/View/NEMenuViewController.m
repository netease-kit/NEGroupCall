//
//  NEMenuViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEMenuViewController.h"
#import "NENavCustomView.h"
#import "NEMenuCell.h"

#import "NEUser.h"

#import "NENavigator.h"
#import "NEAccount.h"
#import "NEFeedbackVC.h"

@interface NEMenuViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)UIImageView *bgImageView;

@property (nonatomic, strong)   NSArray *datas;

@end

static NSString *cellID = @"menuCellID";
@implementation NEMenuViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDatas];
    [self setupUI];
    [self.tableView reloadData];
    [self autoLogin];
}

#pragma mark - private

- (void)setupDatas
{
    NEMenuCellModel *groupVideo = [[NEMenuCellModel alloc] initWithTitle:@"多人视频通话" icon:@"menu_group_video"];
    _datas = @[groupVideo];

}

- (void)setupUI {
    [self.view addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    NENavCustomView *customView = [[NENavCustomView alloc] init];
    [self.view addSubview:customView];
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [customView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(statusHeight + 80);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(customView.mas_bottom);
        make.right.mas_equalTo(-20);
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(0);
    }];
}
- (void)autoLogin {
    if ([[NEAccount shared].accessToken length] > 0) {
        [NEAccount loginByTokenWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSString *msg = data[@"msg"] ?: @"请求错误";
                [self.view makeToast:msg];
            }
        }];
    }
}
#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_datas count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NEMenuCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NEMenuCell cellWithTableView:tableView indexPath:indexPath datas:_datas];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            // 进入多人视频通话
            if (![NEAccount shared].hasLogin) {
                [[NENavigator shared] loginWithOptions:nil];
            }else {
                [[NENavigator shared] showGroupVC];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - property
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 104;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[NEMenuCell class] forCellReuseIdentifier:cellID];
    }
    return _tableView;
}
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_bg"]];
    }
    return _bgImageView;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
