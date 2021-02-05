//
//  NETSMoreSettingCell.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSMoreSettingCell.h"
#import "UIView+NTES.h"
#import "NETSMoreSettingModel.h"
#import "UIImage+NTES.h"

@interface NETSMoreSettingCell ()

/// 灰色圆形背景
@property (nonatomic, strong)   UIView      *circleBg;
/// 标志icon
@property (nonatomic, strong)   UIImageView *icon;
/// 标题label
@property (nonatomic, strong)   UILabel     *label;

@end

@implementation NETSMoreSettingCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.circleBg];
        [self.circleBg addSubview:self.icon];
        [self.contentView addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews
{
    self.circleBg.frame = CGRectMake((self.contentView.width - 60) / 2.0, 8, 60, 60);
    self.icon.frame = CGRectMake((self.circleBg.width - 24) / 2.0, (self.circleBg.height - 24) / 2.0, 24, 24);
    self.label.frame = CGRectMake(0, self.circleBg.bottom + 6, self.contentView.width, 18);
}

- (void)installWithModel:(NETSMoreSettingModel *)model indexPath:(NSIndexPath *)indexPath
{
    NSString *icoName = [model displayIcon];
    UIColor *col = HEXCOLOR(0x5d5d5d);
    if ([model isKindOfClass:[NETSMoreSettingStatusModel class]]) {
        NETSMoreSettingStatusModel *statusModel = (NETSMoreSettingStatusModel *)model;
        col = statusModel.disable ? HEXCOLOR(0xfa292e) : HEXCOLOR(0x5d5d5d);
    }
    self.icon.image = [[UIImage imageNamed:icoName] ne_imageWithTintColor:col];
    self.label.text = model.display;
}

+ (NETSMoreSettingCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                      indexPath:(NSIndexPath *)indexPath
                                          datas:(NSArray <NETSMoreSettingModel *> *)datas
{
    NETSMoreSettingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NETSMoreSettingCell description] forIndexPath:indexPath];
    if ([datas count] > indexPath.row) {
        NETSMoreSettingModel *model = datas[indexPath.row];
        [cell installWithModel:model indexPath:indexPath];
    }
    return cell;
}

+ (CGSize)size
{
    CGFloat width = (kScreenWidth - 10) / 4.0;
    return CGSizeMake(width, 100);
}

#pragma mark - lazy load

- (UIView *)circleBg
{
    if (!_circleBg) {
        _circleBg = [[UIView alloc] init];
        _circleBg.backgroundColor = HEXCOLOR(0xF2F3F5);
        _circleBg.layer.cornerRadius = 30;
        _circleBg.layer.masksToBounds = YES;
    }
    return _circleBg;
}

- (UIImageView *)icon
{
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:12];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = HEXCOLOR(0x333333);
    }
    return _label;
}

@end
