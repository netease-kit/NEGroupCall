//
//  NETSFilterSettingActionSheet.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSFilterSettingActionSheet.h"
#import "UIView+NTES.h"
#import "TopmostView.h"
#import "NETSBeautyParam.h"
#import "NETSFUManger.h"

///
/// 滤镜设置cell
///

@interface NETSFilterSettingCell : UICollectionViewCell

/// 滤镜效果图
@property (nonatomic, strong)   UIImageView *filterView;
/// 滤镜名称
@property (nonatomic, strong)   UILabel     *nameLab;

/// 实例化直播列表页cell
+ (NETSFilterSettingCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                   indexPath:(NSIndexPath *)indexPath
                                       datas:(NSArray<NETSBeautyParam *> *)datas;

/// 计算直播列表页cell size
+ (CGSize)size;

@end

@implementation NETSFilterSettingCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.filterView];
        [self.contentView addSubview:self.nameLab];
    }
    return self;
}

- (void)layoutSubviews
{
    self.filterView.frame = CGRectMake((self.contentView.width - 48) / 2.0, 0, 48, 48);
    self.nameLab.frame = CGRectMake(0, self.filterView.bottom + 6, self.contentView.width, 18);
}

/// 选中cell
- (void)setSelected:(BOOL)selected
{
    if (selected) {
        self.filterView.layer.borderColor = HEXCOLOR(0x2778fc).CGColor;
        self.filterView.layer.borderWidth = 2;
    } else {
        self.filterView.layer.borderWidth = 0;
    }
}

/// TODO: 安装视图
- (void)installWithModel:(NETSBeautyParam *)model indexPath:(NSIndexPath *)indexPath
{
    _filterView.image = [UIImage imageNamed:model.mParam];
    _nameLab.text = model.mTitle;
}

+ (NETSFilterSettingCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                   indexPath:(NSIndexPath *)indexPath
                                       datas:(NSArray <NETSBeautyParam *> *)datas
{
    NETSFilterSettingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NETSFilterSettingCell description]
                                                                            forIndexPath:indexPath];
    if ([datas count] > indexPath.row) {
        id obj = datas[indexPath.row];
        [cell installWithModel:obj indexPath:indexPath];
    }
    return cell;
}

+ (CGSize)size
{
    return CGSizeMake(68, 90);;
}

#pragma mark - lzay load

- (UIImageView *)filterView
{
    if (!_filterView) {
        _filterView = [[UIImageView alloc] init];
        _filterView.layer.cornerRadius = 24;
        _filterView.layer.masksToBounds = YES;
        _filterView.backgroundColor = [UIColor redColor];
    }
    return _filterView;
}

- (UILabel *)nameLab
{
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = [UIFont systemFontOfSize:12];
        _nameLab.textColor = HEXCOLOR(0x222222);
        _nameLab.textAlignment = NSTextAlignmentCenter;
        _nameLab.text = @"原图";
    }
    return _nameLab;
}

@end

///

@interface NETSFilterSettingActionSheet () <UICollectionViewDelegate, UICollectionViewDataSource>

/// 标题视图
@property (nonatomic, strong)   UILabel             *nameLab;
/// 饱和度滑动条
@property (nonatomic, strong)   UISlider            *slider;
/// 滤镜展示视图
@property (nonatomic, strong)   UICollectionView    *collectionView;

@end

@implementation NETSFilterSettingActionSheet

+ (void)show
{
    CGRect frame = [UIScreen mainScreen].bounds;
    NETSFilterSettingActionSheet *sheet = [[NETSFilterSettingActionSheet alloc] initWithFrame:frame title:@"滤镜"];
    NETSBeautyParam *param = [NETSFUManger shared].seletedFliter;
    [sheet setFilterParam:param];
    
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    
    /// 暂存顶层视图交互设置
    sheet.topUserInteractionEnabled = topmostView.userInteractionEnabled;
    
    topmostView.userInteractionEnabled = YES;
    [topmostView addSubview:sheet];
    
    // 定位到选中的item
    NSInteger idx = [sheet _selectedIndex];
    if (idx > 0 && idx < [[NETSFUManger shared].filters count]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [sheet.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (NSInteger)_selectedIndex
{
    NSArray<NETSBeautyParam *> *filters = [NETSFUManger shared].filters;
    NETSBeautyParam *selFilter = [NETSFUManger shared].seletedFliter;
    NSInteger res = -1;
    for (NSInteger i = 0; i < [filters count]; i++) {
        NETSBeautyParam *filter = filters[i];
        if ([filter.mParam isEqualToString:selFilter.mParam]) {
            res = i;
            break;
        }
    }
    return res;
}

#pragma mark - override method

- (void)setupSubViews
{
    [self.content addSubview:self.nameLab];
    [self.content addSubview:self.slider];
    [self.content addSubview:self.collectionView];
    
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topLine.mas_bottom).offset(12);
        make.left.equalTo(self.content).offset(20);
        make.size.mas_equalTo(CGSizeMake(50, 46));
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab.mas_right).offset(45);
        make.right.equalTo(self.content).offset(-20);
        make.top.bottom.equalTo(self.nameLab);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLab.mas_bottom);
        make.left.right.equalTo(self.content);
        make.height.mas_equalTo(90);
        make.bottom.equalTo(self.content).offset(kIsFullScreen ? -44 : -10);
    }];
}

- (void)resetSetting:(UIButton *)sender
{
    NETSLog(@"重置滤镜参数...");
    [[NETSFUManger shared] resetFilters];
    NETSBeautyParam *param = [NETSFUManger shared].seletedFliter;
    [self setFilterParam:param];
    [self.collectionView reloadData];
}

- (void)valueChanged:(UISlider *)slider
{
    NETSLog(@"饱和度设置...");
    NETSBeautyParam *param = [NETSFUManger shared].seletedFliter;
    param.mValue = slider.value;
    [[NETSFUManger shared] setFilterParam:param];
}

- (void)setFilterParam:(NETSBeautyParam *)param
{
    self.slider.value = param.mValue;
    [[NETSFUManger shared] setFilterParam:param];
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray<NETSBeautyParam *> *filters = [NETSFUManger shared].filters;
    return [filters count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray<NETSBeautyParam *> *filters = [NETSFUManger shared].filters;
    NETSFilterSettingCell *cell = [NETSFilterSettingCell cellWithCollectionView:collectionView
                                                                      indexPath:indexPath
                                                                          datas:filters];
    if ([filters count] > indexPath.row) {
        NETSBeautyParam *filter = filters[indexPath.row];
        NETSBeautyParam *selected = [NETSFUManger shared].seletedFliter;
        cell.selected = [filter.mParam isEqualToString:selected.mParam];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray<NETSBeautyParam *> *filters = [NETSFUManger shared].filters;
    if ([filters count] > indexPath.row) {
        NETSBeautyParam *param = filters[indexPath.row];
        [self setFilterParam:param];
    }
    [self.collectionView reloadData];
}

#pragma mark - lzay load

- (UILabel *)nameLab
{
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = [UIFont systemFontOfSize:14];
        _nameLab.textColor = HEXCOLOR(0x222222);
        _nameLab.textAlignment = NSTextAlignmentLeft;
        _nameLab.text = @"饱和度";
    }
    return _nameLab;
}

- (UISlider *)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.minimumValue = 0;
        _slider.maximumValue = 1;
        [_slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(68, 90);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 8;
        layout.minimumLineSpacing = 8;
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        
        CGRect frame = CGRectMake(0, 107, self.width, 90);
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[NETSFilterSettingCell class] forCellWithReuseIdentifier:[NETSFilterSettingCell description]];
        _collectionView.allowsMultipleSelection = NO;
    }
    return _collectionView;
}

@end
