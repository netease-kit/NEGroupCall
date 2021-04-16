//
//  NEBaseTabViewCell.m
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/15.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEBaseTabViewCell.h"

@interface NEBaseTabViewCell ()
@property (nonatomic, readwrite, strong) id model;

@end
@implementation NEBaseTabViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier model:(id<NEBaseModelProtocol>)model {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _model = model;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self ne_setupViews];
        [self ne_bindViewModel];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier model:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil model:nil];
}

- (void)ne_setupViews {

}

- (void)ne_bindViewModel {
    
}

@end
