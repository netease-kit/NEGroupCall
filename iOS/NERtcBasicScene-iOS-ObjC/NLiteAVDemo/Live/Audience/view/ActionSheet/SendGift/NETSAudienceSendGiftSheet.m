//
//  NETSAudienceSendGiftSheet.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSAudienceSendGiftSheet.h"
#import "TopmostView.h"
#import "NETSGiftModel.h"
#import "NETSAudienceSendGiftCell.h"
#import "UIView+NTES.h"

@interface NETSAudienceSendGiftSheet () <UICollectionViewDelegate, UICollectionViewDataSource>

/// 礼物展示视图
@property (nonatomic, strong)   UICollectionView    *collectionView;
/// 发送按钮
@property (nonatomic, strong)   UIButton            *sendBtn;
/// 代理对象
@property (nonatomic, weak)     id<NETSAudienceSendGiftSheetDelegate>   delegate;
/// 礼物数组
@property (nonatomic, strong)   NSArray<NETSGiftModel *>                *gifts;
/// 选中的礼物
@property (nonatomic, strong)   NETSGiftModel       *selectedGift;

@end

@implementation NETSAudienceSendGiftSheet

+ (void)showWithTarget:(id<NETSAudienceSendGiftSheetDelegate>)target gifts:(NSArray<NETSGiftModel *> *)gifts
{
    CGRect frame = [UIScreen mainScreen].bounds;
    NETSAudienceSendGiftSheet *sheet = [[NETSAudienceSendGiftSheet alloc] initWithFrame:frame title:@"送礼物"];
    sheet.delegate = target;
    sheet.gifts = gifts;
    sheet.resetBtn.hidden = YES;
    
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    
    /// 暂存顶层视图交互设置
    sheet.topUserInteractionEnabled = topmostView.userInteractionEnabled;
    
    topmostView.userInteractionEnabled = YES;
    [topmostView addSubview:sheet];
    
    [sheet.collectionView reloadData];
}

#pragma mark - override method

- (void)setupSubViews
{
    [self.content addSubview:self.collectionView];
    [self.content addSubview:self.sendBtn];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topLine.mas_bottom);
        make.left.right.equalTo(self.content);
        make.height.mas_equalTo(136);
    }];
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom).offset(8);
        make.left.equalTo(self.content).offset(20);
        make.right.equalTo(self.content).offset(-20);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.content).offset(kIsFullScreen ? -42 : -8);
    }];
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_gifts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NETSAudienceSendGiftCell *cell = [NETSAudienceSendGiftCell cellWithCollectionView:collectionView indexPath:indexPath datas:_gifts];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_gifts count] > indexPath.row) {
        _selectedGift = _gifts[indexPath.row];
        _sendBtn.enabled = YES;
    }
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)sendAction:(UIButton *)sender
{
    if (!_selectedGift) {
        NETSLog(@"请选择要发送的礼物");
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendGift:onSheet:)]) {
        [self.delegate didSendGift:_selectedGift onSheet:self];
    }
}

#pragma mark - lzay load

- (UIButton *)sendBtn
{
    if (!_sendBtn) {
        _sendBtn = [[UIButton alloc] init];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.layer.cornerRadius = 22;
        _sendBtn.layer.masksToBounds = YES;
        _sendBtn.backgroundColor = HEXCOLOR(0x2883fc);
        [_sendBtn addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
        _sendBtn.enabled = NO;
    }
    return _sendBtn;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = [NETSAudienceSendGiftCell size];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 8;
        layout.minimumLineSpacing = 8;
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        
        CGRect frame = CGRectMake(0, 107, self.width, 136);
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[NETSAudienceSendGiftCell class] forCellWithReuseIdentifier:[NETSAudienceSendGiftCell description]];
        _collectionView.allowsMultipleSelection = NO;
    }
    return _collectionView;
}

@end
