//
//  NEBaseView.h
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/24.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEPickerView : NEBaseView

@property(nonatomic,strong)NSArray *dataSource;               //数据
@property (nonatomic, assign) NSInteger selectDefault;          //默认选中
@property(nonatomic,copy)void(^selectValue)(NSInteger value); //选中值
- (void)show;

@end

NS_ASSUME_NONNULL_END
