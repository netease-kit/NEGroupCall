//
//  NEMenuHeader.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/18.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEMenuHeader : UITableViewHeaderFooterView

@property (nonatomic, assign) NSInteger    section;

/**
 获取组头高度
 */
+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
