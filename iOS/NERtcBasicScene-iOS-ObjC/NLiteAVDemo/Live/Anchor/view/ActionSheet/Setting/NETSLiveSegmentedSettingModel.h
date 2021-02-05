//
//  NETSLiveSegmentedSettingModel.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 自定义直播分段设置视图模型
///

@interface NETSLiveSegmentedSettingModel : NSObject

@property (nonatomic, copy)     NSString    *display;
@property (nonatomic, assign)   NSInteger   value;

- (instancetype)initWithDisplay:(NSString *)display
                          value:(NSInteger)value;

@end

NS_ASSUME_NONNULL_END
