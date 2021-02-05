//
//  NETSBaseView.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/30.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NETSBaseViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NETSBaseView : UIView<NETSBaseViewProtocol>
/**
 数据模型(对外只读，对内可修改)
 */
@property (nonatomic, readonly, strong) id model;

/**
 初始化对象(指定初始化方法)
 
 @param frame 布局
 @param model 数据模型
 @return 视图对象
 */
- (instancetype)initWithFrame:(CGRect)frame model:(nullable id<NETSBaseViewProtocol>)model NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
