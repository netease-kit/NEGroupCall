//
//  NETSRequest.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NETSApiOptions.h"

NS_ASSUME_NONNULL_BEGIN

/**
 请求错误domain
 */
#define NETSRequestErrorParseDomain @"NETSRequestErrorParseDomain"
#define NETSRequestErrorCodeDomain @"NETSRequestErrorCodeDomain"
#define NETSRequestErrorParamDomain @"NETSRequestErrorParamDomain"

/**
 请求错误码
 */
typedef NS_ENUM(NSUInteger, NETSRequestErrorCode) {
    NETSRequestErrorUnknown         = 0,
    NETSRequestErrorSerialization   = 1001,
    NETSRequestErrorAuthorization   = 1002,
    NETSRequestErrorMapping         = 1003
};

typedef void(^NETSRequestCompletion)(NSDictionary * _Nonnull response);
typedef void(^NETSRequestError)(NSError * _Nonnull error, NSDictionary * _Nullable response);

@interface NETSRequest : NSObject

// 请求配置项
@property (nonatomic, strong, nullable)   NETSApiOptions  *options;
// 请求返回数据
@property (nonatomic, strong, nullable, readonly)   NSURLResponse   *response;
// 请求完成闭包
@property (nonatomic, copy, nullable)   NETSRequestCompletion   completionBlock;
// 请求失败闭包
@property (nonatomic, copy, nullable)   NETSRequestError        errorBlock;

/**
 实例化请求
 @param options - 请求配置参数
 */
- (instancetype)initWithOptions:(NETSApiOptions *)options;

/**
 异步请求
 */
- (void)asyncRequest;

/**
 通用参数(扩展)
 */
+ (NSDictionary <NSString *, NSString *> *)commonParams;

@end

NS_ASSUME_NONNULL_END
