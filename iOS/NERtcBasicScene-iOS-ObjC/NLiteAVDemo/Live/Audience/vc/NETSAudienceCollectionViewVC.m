//
//  NETSAudienceCollectionView.m
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2021/1/7.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSAudienceCollectionViewVC.h"
#import "NETSAudienceChatRoomCell.h"
#import "NETSLiveModel.h"
#import "NETSChatroomService.h"
#import <NELivePlayerFramework/NELivePlayerFramework.h>
#import "UIViewController+Gesture.h"
#import "Reachability.h"
#import "NETSPullStreamErrorView.h"
#import "IQKeyboardManager.h"

@interface NETSAudienceCollectionViewVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
//数据源
@property(nonatomic, strong) NSArray                   *liveData;
//选中的index
@property(nonatomic, assign) NSInteger                 selectRoomIndex;
@property(nonatomic, strong) UICollectionView          *collectionView;
//当前cell的index
@property(nonatomic, strong) NSIndexPath               *currentIndexPath;
@property (nonatomic, copy)  NSString                  *currentPlayId;
/// 即将移出屏幕的cell indePath
@property (nonatomic, strong) NSIndexPath               *playingCellIndexPath;
/// 即将移出屏幕的cell
@property (nonatomic, strong) NETSAudienceChatRoomCell  *playingCell;

@end

@implementation NETSAudienceCollectionViewVC


- (instancetype)initWithScrollData:(NSArray *)liveData currentRoom:(NSInteger)selectRoomIndex {
    if (self = [super init]) {
       _liveData = liveData;
       _selectRoomIndex = selectRoomIndex;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIViewController popGestureClose:self];
    
    NETSLog(@"观众端 进入直播间播放页面: viewDidAppear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIViewController popGestureOpen:self];
    [IQKeyboardManager sharedManager].enable = YES;
    
    NETSLog(@"观众端 离开直播间播放页面: viewWillDisappear");
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)nets_addSubViews {
    [super nets_addSubViews];
    [self.view addSubview:self.collectionView];
    //滚动到选择位置
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectRoomIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:true];
    self.currentIndexPath = [NSIndexPath indexPathForRow:self.selectRoomIndex inSection:0];
    self.currentPlayId    = [self.liveData[self.selectRoomIndex] chatRoomId];
    self.playingCellIndexPath = [NSIndexPath indexPathForRow:self.selectRoomIndex inSection:0];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.liveData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NETSLiveRoomModel *roomModel = self.liveData[indexPath.row];
    NETSAudienceChatRoomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NETSAudienceChatRoomCell description]
                                                                               forIndexPath:indexPath];
    if (self.currentIndexPath.row == indexPath.row) {
        cell.roomModel = roomModel;
    }
    if (_playingCell == nil && indexPath.row == self.playingCellIndexPath.row) {
        _playingCell = cell;
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.playingCellIndexPath != nil ) {
        CGRect cellRect = [self.collectionView convertRect:self.playingCell.frame toView:self.collectionView];
        CGRect rectInSuperview = [self.collectionView convertRect:cellRect toView:self.view];
        if (rectInSuperview.origin.y >= kScreenHeight || rectInSuperview.origin.y + rectInSuperview.size.height <= 0) {
            [_playingCell shutdownPlayer];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint pointInView = [self.view convertPoint:self.collectionView.center toView:self.collectionView];
    NSIndexPath *indexPathNow = [self.collectionView indexPathForItemAtPoint:pointInView];
    
    // 滚动到相同的直播间 不做处理
    if ([self.currentPlayId isEqualToString:[self.liveData[indexPathNow.row] chatRoomId]]) {
        return;
    }
    
    // 退出之前的聊天室
    NETSLiveRoomModel *roomModel = self.liveData[self.selectRoomIndex];
    [NETSChatroomService exitWithRoomId:roomModel.chatRoomId];

    // 赋值给记录当前坐标的变量
    self.currentIndexPath = indexPathNow;
    self.currentPlayId    = [self.liveData[indexPathNow.row] chatRoomId];
    self.selectRoomIndex = indexPathNow.row;
    
    NETSLog(@"观众端 滚动结束后的section %ld，row: %ld",(long)indexPathNow.section,(long)indexPathNow.row);
    NETSAudienceChatRoomCell *currentCell = (NETSAudienceChatRoomCell*)[self.collectionView cellForItemAtIndexPath:indexPathNow];
    [currentCell resetPageUserinterface];
    currentCell.roomModel = self.liveData[indexPathNow.row];
    
    // 记录正在播放cell赋值
    self.playingCellIndexPath = self.currentIndexPath;
    self.playingCell = currentCell;
}

#pragma mark - lazyMethod

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = HEXCOLOR(0x262623);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _collectionView.alwaysBounceVertical = YES; //垂直方向遇到边框是否总是反弹
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[NETSAudienceChatRoomCell class] forCellWithReuseIdentifier:[NETSAudienceChatRoomCell description]];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

- (void)dealloc {
    NETSLog(@"NETSAudienceCollectionViewVC dealloc...");
}

@end
