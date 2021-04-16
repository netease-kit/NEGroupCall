//
//  NETSApiOptions.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NETSApiModelMapping.h"

NS_ASSUME_NONNULL_BEGIN

/**
 请求工具配置项
 */

typedef NS_ENUM(NSUInteger, NETSRequestMethod) {
    NETSRequestMethodGET = 0,
    NETSRequestMethodPOST
};

@interface NETSApiOptions : NSObject

// host
@property (nonatomic, copy, nonnull)     NSString    *host;
// 接口
@property (nonatomic, copy, nonnull)     NSString    *baseUrl;
// 请求参数
@property (nonatomic, strong, nonnull)  NSDictionary<NSString *, NSString *>    *params;
// 返回数据映射
@property (nonatomic, strong, nonnull)  NSArray<NETSApiModelMapping *>          *modelMapping;
// 请求方式
@property (nonatomic, assign)           NETSRequestMethod                       apiMethod;
// 超时时间(默认10)
@property (nonatomic, assign)           int32_t                                 timeoutInterval;

@end

NS_ASSUME_NONNULL_END
