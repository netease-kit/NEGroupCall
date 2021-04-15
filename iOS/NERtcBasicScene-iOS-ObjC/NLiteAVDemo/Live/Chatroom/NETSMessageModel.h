//
//  NETSMessageModel.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@class M80AttributedLabel;

///
/// IM消息
///

typedef NS_ENUM(NSInteger, NETSMessageType) {
    NETSMessageNormal = 0,
    NETSMessageNotication,
};

@interface NETSMessageModel : NSObject

/// 消息
@property (nonatomic,strong) NIMMessage *message;
/// 消息类型
@property (nonatomic,assign) NETSMessageType type;
/// 消息size
@property (nonatomic,assign) CGSize size;
/// 消息富文本
@property (nonatomic,readonly) NSAttributedString *formatMessage;

///
/// 计算宽度
/// @param width - 宽度
///
- (void)caculate:(CGFloat)width;

///
/// 绘制富文本
/// @param label - 富文本容器
///
- (void)drawAttributeLabel:(M80AttributedLabel *)label;

@end

NS_ASSUME_NONNULL_END
