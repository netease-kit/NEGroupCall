//
//  NETSLiveChatCell.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveChatCell.h"
#import "M80AttributedLabel.h"
#import "UIView+NTES.h"
#import "NETSMessageModel.h"

@interface NETSLiveChatCell ()
{
    CGRect _preRect;
}
/// 消息模型
@property (nonatomic, strong) NETSMessageModel *model;
/// 富文本控件
@property (nonatomic,strong) M80AttributedLabel *attributedLabel;

@end

@implementation NETSLiveChatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///
/// self code
///

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.layer.cornerRadius = 12.0;
        [self.contentView addSubview:self.attributedLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(0, 0, _model.size.width + 8*2, _model.size.height + 4.0);
    self.contentView.centerY = self.height/2;
    _attributedLabel.frame = CGRectMake(8, 0, _model.size.width, _model.size.height);
    _attributedLabel.bottom = self.contentView.height;
}

/// 安装视图
- (void)installWithModel:(NETSMessageModel *)model indexPath:(NSIndexPath *)indexPath
{
    [model drawAttributeLabel:self.attributedLabel];
    
    _model = model;
    
    switch (model.type) {
        case NETSMessageNormal:
        {
            self.contentView.backgroundColor = HEXCOLORA(0xffffff, 0.1);
            break;
        }
        case NETSMessageNotication:
        {
            self.contentView.backgroundColor = [UIColor clearColor];
            break;
        }
        default:
            break;
    }
    
    [self setNeedsLayout];
}

+ (NETSLiveChatCell *)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath datas:(NSArray <NETSMessageModel *> *)datas
{
    NETSLiveChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[NETSLiveChatCell description]];
    if ([datas count] > indexPath.row) {
        NETSMessageModel *model = datas[indexPath.row];
        [cell installWithModel:model indexPath:indexPath];
    }
    return cell;
}

+ (CGFloat)heightWithIndexPath:(NSIndexPath *)indexPath datas:(NSArray <NETSMessageModel *> *)datas
{
    if ([datas count] > indexPath.row) {
        NETSMessageModel *model = datas[indexPath.row];
        return (model.size.height + 8.0 + 9.0);
    }
    return 0;
}

#pragma mark - Get
- (M80AttributedLabel *)attributedLabel
{
    if (!_attributedLabel) {
        _attributedLabel = [[M80AttributedLabel alloc] init];
        _attributedLabel.numberOfLines = 0;
        _attributedLabel.font = [UIFont systemFontOfSize:14];
        _attributedLabel.backgroundColor = [UIColor clearColor]; // UIColorFromRGBA(0xffffff, 0.1);
        _attributedLabel.lineBreakMode = kCTLineBreakByCharWrapping;
    }
    return _attributedLabel;
}


@end
