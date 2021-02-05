//
//  NETSChoosePKSheet.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSChoosePKSheet.h"
#import "TopmostView.h"
#import "UIView+NTES.h"
#import "NETSChoosePKCell.h"
#import "NETSLiveModel.h"
#import "NETSLiveApi.h"
#import "NETSLiveModel.h"
#import <MJRefresh/MJRefresh.h>
#import "NETSToast.h"
#import "NETSEmptyListView.h"

@interface NETSChoosePKSheet () <UITableViewDelegate, UITableViewDataSource, NETSChoosePKCellDelegate>

/// 代理对象
@property (nonatomic, weak) id<NETSChoosePKSheetDelegate> delegate;
/// 展示主播列表
@property (nonatomic, strong)   UITableView     *tableView;
/// 数据集合
@property (nonatomic, strong)   NSArray<NETSLiveRoomModel *> *datas;
/// 页码
@property (nonatomic, assign)   int             page;
/// 加载状态
@property (nonatomic, assign)   BOOL            isLoading;
/// 加载结束标志
@property (nonatomic, assign)   BOOL            isEnd;
/// 请求错误
@property (nonatomic, assign)   NSError         *error;
/// 空数据视图
@property (nonatomic, strong)   NETSEmptyListView   *emptyView;

@end

@implementation NETSChoosePKSheet

+ (void)showWithTarget:(id<NETSChoosePKSheetDelegate>)target
{
    CGRect frame = [UIScreen mainScreen].bounds;
    NETSChoosePKSheet *sheet = [[NETSChoosePKSheet alloc] initWithFrame:frame title:@"选择主播进行PK"];
    sheet.delegate = target;
    sheet.resetBtn.hidden = YES;
    
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    
    /// 暂存顶层视图交互设置
    sheet.topUserInteractionEnabled = topmostView.userInteractionEnabled;
    
    topmostView.userInteractionEnabled = YES;
    [topmostView addSubview:sheet];
    
    [sheet bindAction];
    [sheet loadData];
}

- (void)setupSubViews
{
    [self.content addSubview:self.tableView];
    [self.tableView addSubview:self.emptyView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topLine.mas_bottom);
        make.left.right.equalTo(self.content);
        make.height.mas_equalTo(250);
        make.bottom.equalTo(self.content).offset(kIsFullScreen ? -42 : -8);
    }];
    self.emptyView.frame = CGRectMake((kScreenWidth - 100) / 2.0, (250 - 138) / 2.0, 100, 138);
}

- (void)bindAction
{
    @weakify(self);
    [RACObserve(self, datas) subscribeNext:^(NSArray<NETSLiveRoomModel *> *datas) {
        @strongify(self);
        self.emptyView.hidden = [datas count] > 0;
        [self.tableView reloadData];
    }];
    [RACObserve(self, isLoading) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (!self.isLoading) {
            [self.tableView.mj_footer endRefreshing];
        }
    }];
    [RACObserve(self, error) subscribeNext:^(NSError * _Nullable err) {
        if (!err) { return; }
        if (err.code == 1003) {
            [NETSToast showToast:@"PK列表为空"];
        } else {
            NSString *msg = err.userInfo[NSLocalizedDescriptionKey] ?: @"请求PK列表错误";
            [NETSToast showToast:msg];
        }
    }];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        if (self.isEnd) {
            [self.tableView.mj_footer endRefreshing];
            [NETSToast showToast:@"无更多内容"];
            return;
        }
        [self loadData];
    }];
}

#pragma mark - load data

- (void)loadData
{
    _page += 1;
    _isLoading = YES;
    
    [NETSToast showLoading];
    [NETSLiveApi fetchListWithLive:NETSLiveListLive pageNum:_page pageSize:20 completionHandle:^(NSDictionary * _Nonnull response) {
        [NETSToast hideLoading];
        NSArray *list = response[@"/data/list"];
        if ([list count] > 0) {
            NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.datas];
            [tmp addObjectsFromArray:list];
            self.datas = [tmp copy];
        }
        self.isLoading = NO;
        self.error = nil;
        self.isEnd = [list count] < 20;
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        [NETSToast hideLoading];
        self.isLoading = NO;
        self.error = error;
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NETSChoosePKCell height];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NETSChoosePKCell *cell = [NETSChoosePKCell cellWithTableView:tableView indexPath:indexPath datas:_datas];
    cell.delegate = self;
    return cell;
}

#pragma mark - NETSChoosePKCellDelegate

- (void)didClickPKModel:(NETSLiveRoomModel *)model
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(choosePkOnSheet:withRoom:)]) {
        [self.delegate choosePkOnSheet:self withRoom:model];
    }
}

#pragma mark - lazy load

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        [_tableView registerClass:[NETSChoosePKCell class] forCellReuseIdentifier:[NETSChoosePKCell description]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = [NETSChoosePKCell height];
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _tableView;
}

- (NETSEmptyListView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[NETSEmptyListView alloc] initWithFrame:CGRectZero];
        _emptyView.tintColor = [UIColor lightGrayColor];
    }
    return _emptyView;
}

@end
