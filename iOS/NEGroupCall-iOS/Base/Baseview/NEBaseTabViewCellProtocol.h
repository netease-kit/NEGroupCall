//
//  NEBaseTabViewCellProtocol.h
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/15.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NEBaseTabViewCellProtocol <NSObject>
@optional

/**
 子视图添加
 */
- (void)ne_setupViews;

/**
 业务逻辑绑定
 */
- (void)ne_bindViewModel;

@end

NS_ASSUME_NONNULL_END
