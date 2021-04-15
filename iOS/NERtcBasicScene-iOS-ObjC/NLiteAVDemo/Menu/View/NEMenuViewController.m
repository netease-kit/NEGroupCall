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
#import <NIMSDK/NIMSDK.h>
#import "AppKey.h"

#import "NENavigator.h"
#import "NEAccount.h"
#import "NEFeedbackVC.h"
#import "NEMenuHeader.h"
#import "NETSToast.h"
#import "NETSLiveAttachment.h"

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
    NEMenuCellModel *groupVideo = [[NEMenuCellModel alloc] initWithTitle:@"多人视频通话" icon:@"menu_group_video" block:^{
        [[NENavigator shared] showGroupVC];
    }];
    NEMenuCellModel *live = [[NEMenuCellModel alloc] initWithTitle:@"PK直播" icon:@"menu_single_icon" block:^{
        [[NENavigator shared] showLiveListVC];
    }];
    
    NSArray *sectionOne = @[groupVideo];
    NSArray *sectionTwo = @[live];
    _datas = @[sectionOne, sectionTwo];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_datas count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_datas count] > section) {
        NSArray *arr = _datas[section];
        return [arr count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NEMenuCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_datas count] > indexPath.section) {
        NSArray *array = _datas[indexPath.section];
        if ([array count] > indexPath.row) {
            NEMenuCellModel *data = array[indexPath.row];
            return [NEMenuCell cellWithTableView:tableView indexPath:indexPath data:data];
        }
    }
    return [NEMenuCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![NEAccount shared].hasLogin) {
        [[NENavigator shared] loginWithOptions:nil];
        return;
    }
    
    if ([_datas count] > indexPath.section) {
        NSArray *array = _datas[indexPath.section];
        if ([array count] > indexPath.row) {
            NEMenuCellModel *data = array[indexPath.row];
            if (!data.block) { return; }
            
            if ([data.title isEqualToString:@"PK直播"]) {
                [NETSToast showLoading];
                [self setupIMWithLoginCompletion:^(NSError * _Nullable error) {
                    [NETSToast hideLoading];
                    if (error) {
                        NETSLog(@"IM登录失败, error: %@", error);
                    } else {
                        data.block();
                    }
                }];
                return;
            }
            
            data.block();
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [NEMenuHeader height];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NEMenuHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[NEMenuHeader description]];
    header.section = section;
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isMemberOfClass:[NEMenuHeader class]]) {
        ((NEMenuHeader *)view).backgroundView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - private Method
/// 初始化IM引擎
- (void)setupIMWithLoginCompletion:(void(^)(NSError * _Nullable))loginCompletion
{
    NIMSDKOption *option = [NIMSDKOption optionWithAppKey:kAppKey];
    [[NIMSDK sharedSDK] registerWithOption:option];
    [NIMCustomObject registerCustomDecoder:[[NETSLiveAttachmentDecoder alloc] init]];
    
    if (![NIMSDK sharedSDK].loginManager.isLogined) {
        NEUser *user = [NEAccount shared].userModel;
        [[[NIMSDK sharedSDK] loginManager] login:user.imAccid token:user.imToken completion:loginCompletion];
    } else {
        if (loginCompletion) {
            loginCompletion(nil);
        }
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
        [_tableView registerClass:[NEMenuHeader class] forHeaderFooterViewReuseIdentifier:[NEMenuHeader description]];
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
