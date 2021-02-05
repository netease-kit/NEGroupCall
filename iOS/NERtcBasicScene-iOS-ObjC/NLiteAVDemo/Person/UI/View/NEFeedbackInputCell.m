//
//  NEFeedbackInputCell.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/22.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEFeedbackInputCell.h"

@implementation NEFeedbackInputCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
