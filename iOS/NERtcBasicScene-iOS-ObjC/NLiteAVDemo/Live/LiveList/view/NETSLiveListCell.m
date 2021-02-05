//
//  NETSLiveListCell.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveListCell.h"
#import "NETSLiveModel.h"

@interface NETSLiveListCell ()

/// 封面
@property (nonatomic, strong)   UIImageView *coverView;
/// 渐变阴影
@property (nonatomic, strong)   CAGradientLayer *shadowLayer;
/// pk标志
@property (nonatomic, strong)   UIImageView *pkView;
/// 房间名称
@property (nonatomic, strong)   UILabel     *roomName;
/// 主播名称
@property (nonatomic, strong)   UILabel     *anchorName;
/// 观众人数
@property (nonatomic, strong)   UILabel     *audienceNum;

@end

@implementation NETSLiveListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.pkView];
    [self.contentView addSubview:self.roomName];
    [self.contentView addSubview:self.anchorName];
    [self.contentView addSubview:self.audienceNum];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.coverView.layer insertSublayer:self.shadowLayer atIndex:0];
    [self.pkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.coverView).offset(8);
        make.size.mas_equalTo(CGSizeMake(86, 24));
    }];
    [self.roomName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverView).offset(8);
        make.bottom.equalTo(self.coverView).offset(-22);
        make.size.mas_equalTo(CGSizeMake(104, 20));
    }];
    [self.anchorName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.roomName);
        make.top.equalTo(self.roomName.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(104, 18));
    }];
    [self.audienceNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.coverView).offset(-8);
        make.centerY.equalTo(self.anchorName);
        make.size.mas_equalTo(CGSizeMake(30, 18));
    }];
}

- (void)installWithModel:(NETSLiveRoomModel *)model indexPath:(NSIndexPath *)indexPath
{
    self.roomName.text = model.roomTopic;
    self.anchorName.text = model.nickname;
    NSURL *coveUrl = [NSURL URLWithString:model.liveCoverPic];
    [self.coverView sd_setImageWithURL:coveUrl];
    self.audienceNum.text = [NSString stringWithFormat:@"%d", model.audienceCount];
    
    self.pkView.hidden = !(model.live == NETSRoomPKing);
}

+ (NETSLiveListCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                   indexPath:(NSIndexPath *)indexPath
                                       datas:(NSArray <NETSLiveRoomModel *> *)datas
{
    if ([datas count] <= indexPath.row) {
        return [NETSLiveListCell new];
    }
    
    NETSLiveListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NETSLiveListCell description]
                                                                       forIndexPath:indexPath];
    NETSLiveRoomModel *model = datas[indexPath.row];
    [cell installWithModel:model indexPath:indexPath];
    return cell;
}

+ (CGSize)size
{
    CGFloat length = (kScreenWidth - 8 * 3) / 2.0;
    return CGSizeMake(length, length);
}

#pragma mark - lazy load

- (UIImageView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIImageView alloc] init];
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.clipsToBounds  = YES;
    }
    return _coverView;
}

- (CAGradientLayer *)shadowLayer
{
    if (!_shadowLayer) {
        _shadowLayer = [CAGradientLayer layer];
        NSArray *colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithWhite:1 alpha:0] CGColor],
                           (id)[[UIColor colorWithWhite:0 alpha:0.4] CGColor],
                           nil
                           ];
        [_shadowLayer setColors:colors];
        [_shadowLayer setStartPoint:CGPointMake(0.0f, 0.4f)];
        [_shadowLayer setEndPoint:CGPointMake(0.0f, 1.0f)];
        CGFloat length = (kScreenWidth - 8 * 3) / 2.0;
        [_shadowLayer setFrame:CGRectMake(0, 0, length, length)];
    }
    return _shadowLayer;
}

- (UIImageView *)pkView
{
    if (!_pkView) {
        _pkView = [[UIImageView alloc] init];
        _pkView.image = [UIImage imageNamed:@"pking_ico"];
    }
    return _pkView;
}

- (UILabel *)roomName
{
    if (!_roomName) {
        _roomName = [[UILabel alloc] init];
        _roomName.font = [UIFont systemFontOfSize:13];
        _roomName.textColor = [UIColor whiteColor];
        _roomName.text = @"房间名称房间名称";
    }
    return _roomName;
}

- (UILabel *)anchorName
{
    if (!_anchorName) {
        _anchorName = [[UILabel alloc] init];
        _anchorName.font = [UIFont systemFontOfSize:12];
        _anchorName.textColor = [UIColor whiteColor];
        _anchorName.text = @"主播名称";
    }
    return _anchorName;
}

- (UILabel *)audienceNum
{
    if (!_audienceNum) {
        _audienceNum = [[UILabel alloc] init];
        _audienceNum.font = [UIFont systemFontOfSize:12];
        _audienceNum.textColor = [UIColor whiteColor];
        _audienceNum.text = @"1234";
    }
    return _audienceNum;
}

@end
