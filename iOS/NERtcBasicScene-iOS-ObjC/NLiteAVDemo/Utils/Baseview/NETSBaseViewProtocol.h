//
//  NETSBaseViewProtocol.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/30.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NETSBaseViewProtocol <NSObject>

@optional

/**
 子视图添加
 */
- (void)nets_setupViews;

/**
 业务逻辑绑定
 */
- (void)nets_bindViewModel;


@end
