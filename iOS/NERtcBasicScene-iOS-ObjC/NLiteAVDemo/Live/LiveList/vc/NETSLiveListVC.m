//
//  NETSLiveListVC.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveListVC.h"
#import "NETSLiveListVM.h"
#import "NETSLiveListCell.h"
#import <MJRefresh/MJRefresh.h>
#import "NENavigator.h"
#import "NETSLiveModel.h"
#import "NETSToast.h"
#import "UIView+NTES.h"
#import "NETSEmptyListView.h"
#import <NIMSDK/NIMSDK.h>

@interface NETSLiveListVC () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong)   NETSLiveListVM      *viewModel;
@property (nonatomic, strong)   UICollectionView    *collectionView;
@property (nonatomic, strong)   UIButton            *startPkBtn;
@property (nonatomic, strong)   NETSEmptyListView   *emptyView;

@end

@implementation NETSLiveListVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [[NETSLiveListVM alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
    [self bindAction];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.viewModel load];
}

- (void)setupViews
{
    self.title = @"PK直播";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = HEXCOLOR(0x1A1A24);
    self.navigationController.navigationBar.topItem.title = @"";

    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.startPkBtn];
    
    self.emptyView.centerX = self.collectionView.centerX;
    self.emptyView.centerY = self.collectionView.centerY - 20;
    [self.collectionView addSubview:self.emptyView];
}

- (void)bindAction
{
    @weakify(self);
    MJRefreshGifHeader *mjHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self.viewModel load];
    }];
    [mjHeader setTitle:@"下拉更新" forState:MJRefreshStateIdle];
    [mjHeader setTitle:@"下拉更新" forState:MJRefreshStatePulling];
    [mjHeader setTitle:@"更新中..." forState:MJRefreshStateRefreshing];
    mjHeader.lastUpdatedTimeLabel.hidden = YES;
    [mjHeader setTintColor:[UIColor whiteColor]];
    self.collectionView.mj_header = mjHeader;
    
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        if (self.viewModel.isEnd) {
            [NETSToast showToast:@"无更多内容"];
            [self.collectionView.mj_footer endRefreshing];
        } else {
            [self.viewModel loadMore];
        }
    }];
    
    [RACObserve(self.viewModel, datas) subscribeNext:^(NSArray *array) {
        @strongify(self);
        [self.collectionView reloadData];
        self.emptyView.hidden = [array count] > 0;
    }];
    [RACObserve(self.viewModel, isLoading) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.viewModel.isLoading == NO) {
            [self.collectionView.mj_header endRefreshing];
            [self.collectionView.mj_footer endRefreshing];
        }
    }];
    [RACObserve(self.viewModel, error) subscribeNext:^(NSError * _Nullable err) {
        if (!err) { return; }
        if (err.code == 1003) {
            [NETSToast showToast:@"直播列表为空"];
        } else {
            NSString *msg = err.userInfo[NSLocalizedDescriptionKey] ?: @"请求直播列表错误";
            [NETSToast showToast:msg];
        }
    }];
}

/// 开始直播
- (void)startLive
{
    [[NENavigator shared] showAnchorVC];
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel.datas count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [NETSLiveListCell cellWithCollectionView:collectionView
                                          indexPath:indexPath
                                              datas:self.viewModel.datas];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.viewModel.datas count] > indexPath.row) {
         [[NENavigator shared] showLivingRoom:self.viewModel.datas selectindex:indexPath.row];
    }
}

#pragma mark - lazy load

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = [NETSLiveListCell size];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 8;
        layout.minimumLineSpacing = 8;
        layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:[NETSLiveListCell class] forCellWithReuseIdentifier:[NETSLiveListCell description]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}

- (UIButton *)startPkBtn
{
    if (!_startPkBtn) {
        CGFloat topOffset = self.view.height - 100 - (kIsFullScreen ? 34 : 0);
        _startPkBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 100, topOffset, 100, 100)];
        UIImage *img = [UIImage imageNamed:@"start_pk_ico"];
        [_startPkBtn setImage:img forState:UIControlStateNormal];
        [_startPkBtn addTarget:self action:@selector(startLive) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startPkBtn;
}

- (NETSEmptyListView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[NETSEmptyListView alloc] initWithFrame:CGRectZero];
    }
    return _emptyView;
}

- (void)dealloc {
    [[NIMSDK sharedSDK].loginManager logout:^(NSError * _Nullable error) {
        NETSLog(@"pk直播主播端销毁,IM登出, error: %@...", error);
    }];
}
@end
