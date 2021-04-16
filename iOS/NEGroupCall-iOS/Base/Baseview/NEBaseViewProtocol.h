//
//  NEBaseViewProtocol.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/30.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NEBaseViewProtocol<NSObject>

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
