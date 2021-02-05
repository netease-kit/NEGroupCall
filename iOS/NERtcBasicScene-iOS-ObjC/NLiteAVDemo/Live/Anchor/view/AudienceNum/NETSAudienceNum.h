//
//  NETSAudienceNum.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMChatroomMember;

@interface NETSAudienceNum : UIView

///
/// 刷新观众视图
/// @param datas    - 观众数据
///
- (void)reloadWithDatas:(NSArray <NIMChatroomMember *> *)datas;

@end

NS_ASSUME_NONNULL_END
