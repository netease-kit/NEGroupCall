//
//  NEBaseTabViewCell.h
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/15.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEBaseModelProtocol.h"
#import "NEBaseTabViewCellProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface NEBaseTabViewCell : UITableViewCell<NEBaseTabViewCellProtocol>
/**
 数据模型(对外只读，对内可修改)
 */
@property (nonatomic, readonly, strong) id model;


/**
 初始化方法
 
 @param style 样式
 @param reuseIdentifier 标记id
 @param model 数据模型
 @return 视图对象
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier model:(id<NEBaseModelProtocol>)model NS_DESIGNATED_INITIALIZER;


@end

NS_ASSUME_NONNULL_END
