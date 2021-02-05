//
//  NETSAnchorCoverSetting.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/10.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 主播直播视图 封面设置面板
///

@interface NETSAnchorCoverSetting : UIView

/// 直播主题
- (NSString *)getTopic;

// 直播封面
- (NSString *)getCover;

@end

NS_ASSUME_NONNULL_END
