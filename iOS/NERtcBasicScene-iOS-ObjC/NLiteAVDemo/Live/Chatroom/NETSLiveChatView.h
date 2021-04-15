//
//  NETSLiveChatView.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NIMSDK/NIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 直播IM视图
///

@protocol NETSLiveChatViewDelegate <NSObject>

///
/// 点击IM对话视图
/// @param point    - 新增的消息数组
///
- (void)onTapChatView:(CGPoint)point;

@end

@interface NETSLiveChatView : UIView

/// 会话tableview
@property (nonatomic,strong) UITableView *tableView;
/// 代理句柄
@property (nonatomic,weak) id<NETSLiveChatViewDelegate> delegate;

///
/// 增加消息
/// @param messages - 新增的消息数组
///
- (void)addMessages:(NSArray<NIMMessage *> *)messages;

@end

NS_ASSUME_NONNULL_END
