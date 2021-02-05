//
//  NETSPullStreamErrorView.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/18.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveBaseErrorView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 拉流失败窗体
 */

@protocol NETSPullStreamErrorViewDelegate <NSObject>

/**
 点击返回按钮
 */
- (void)clickBackAction;

/**
 点击重新连接按钮
 */
- (void)clickRetryAction;

@end

@interface NETSPullStreamErrorView : NETSLiveBaseErrorView

@property (nonatomic, weak) id<NETSPullStreamErrorViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
