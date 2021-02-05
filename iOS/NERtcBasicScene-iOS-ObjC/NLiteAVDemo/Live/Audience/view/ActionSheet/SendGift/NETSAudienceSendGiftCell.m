//
//  NETSAudienceSendGiftCell.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSAudienceSendGiftCell.h"
#import "UIView+NTES.h"
#import "NETSGiftModel.h"

@interface NETSAudienceSendGiftCell ()

@property (nonatomic, strong)   UIView          *bgView;
@property (nonatomic, strong)   UIImageView     *icon;
@property (nonatomic, strong)   UILabel         *info;

@end

@implementation NETSAudienceSendGiftCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.bgView];
        [self.bgView addSubview:self.icon];
        [self.bgView addSubview:self.info];
    }
    return self;
}

- (void)layoutSubviews
{
    self.bgView.frame = CGRectMake(4, 20, 72, 100);
    self.icon.frame = CGRectMake(16, 8, 40, 40);
    self.info.frame = CGRectMake(0, self.icon.bottom + 4, 72, 40);
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        self.bgView.layer.borderColor = [UIColor blueColor].CGColor;
        self.bgView.layer.borderWidth = 0.5;
    } else {
        self.bgView.layer.borderWidth = 0;
    }
}

- (void)installWithModel:(NETSGiftModel *)model
{
    self.icon.image = [UIImage imageNamed:model.icon];
    self.info.attributedText = [self descriptionWithGift:model];
    self.info.textAlignment = NSTextAlignmentCenter;
}

- (NSAttributedString *)descriptionWithGift:(NETSGiftModel *)gift
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = 20;
    style.maximumLineHeight = 20;
    
    NSDictionary *displayDic = @{NSFontAttributeName: [UIFont systemFontOfSize:13], NSForegroundColorAttributeName: HEXCOLOR(0x222222), NSParagraphStyleAttributeName: style};
    NSDictionary *priceDic = @{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: HEXCOLOR(0x666666), NSParagraphStyleAttributeName: style};
    NSMutableAttributedString *res = [[NSMutableAttributedString alloc] initWithString:gift.display attributes:displayDic];
    NSAttributedString *price = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n(%d云币)", gift.price]
                                                                attributes:priceDic];
    [res appendAttributedString:price];
    return [res copy];
}

+ (NETSAudienceSendGiftCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                           indexPath:(NSIndexPath *)indexPath
                                               datas:(NSArray <NETSGiftModel *> *)datas
{
    NETSAudienceSendGiftCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NETSAudienceSendGiftCell description] forIndexPath:indexPath];
    if ([datas count] > indexPath.row) {
        NETSGiftModel *gift = datas[indexPath.row];
        [cell installWithModel:gift];
    }
    return cell;
}

/// 计算直播列表页cell size
+ (CGSize)size
{
    return CGSizeMake(80, 136);
}

#pragma mark - lazy load

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.layer.cornerRadius = 4;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UIImageView *)icon
{
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

- (UILabel *)info
{
    if (!_info) {
        _info = [[UILabel alloc] init];
        _info.numberOfLines = 2;
    }
    return _info;
}

@end
