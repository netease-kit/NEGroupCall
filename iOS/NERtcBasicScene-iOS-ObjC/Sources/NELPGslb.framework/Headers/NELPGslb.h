//
//  NELPGslb.h
//  NELPGslb
//
//  Created by Netease on 2018/5/10.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NELPGslbResult.h"
#import "NELPGslbDetailResult.h"

NS_ASSUME_NONNULL_BEGIN
/**
 * 调度任务的url
 */
extern NSString *const NELPGslbUrlKey;

/**
 * 调度任务的状态key
 */
extern NSString *const NELPGslbStatusKey;

/**
 * 原始地址key
 */
extern NSString *const NELPGslbOriginalUrlKey;

/**
 * 调度后地址列表key
 */
extern NSString *const NELPGslbAddressesKey;

/**
 * 调度状态查询
 */
typedef NS_ENUM(NSInteger, NELPGslbStatus) {
    /**
     * 等待
     */
    NELPGslbStatusWaiting = 0,
    /**
     * 调度中
     */
    NELPGslbStatusRunning,
    /**
     * 完成
     */
    NELPGslbStatusComplete,
};

/**
 *  日志等级
 */
typedef NS_ENUM(NSInteger, NELPGslbLogLevel)
{
    NELPGslbLogLevelDefault = 1,
    /**
     *  输出详细
     */
    NELPGslbLogLevelVerbose = 2,
    /**
     *  输出调试信息
     */
    NELPGslbLogLevelDebug   = 3,
    /**
     *  输出标准信息
     */
    NELPGslbLogLevelInfo    = 4,
    /**
     *  输出警告
     */
    NELPGslbLogLevelWarn    = 5,
    /**
     *  输出错误
     */
    NELPGslbLogLevelError   = 6,
    /**
     * 一些错误信息，如头文件找不到，非法参数使用
     */
    NELPGslbLogLevelFatal   = 7,
    /**
     * 不输出
     */
    NELPGslbLogLevelSilent  = 8
};

/**
 * @brief 调度结果查询回调
 *
 * @param error  调度错误
 * @param result 调度结果
 */
typedef void(^NELPGslbQueryResultBlock)(NELPGslbResult * _Nullable result, NSError * _Nullable error);

/**
 * @brief 调度结果查询详细回调(当前主要用在播放器内部)
 *
 * @param result 调度结果
 */
typedef void(^NELPGslbQueryDetailResultBlock)(NELPGslbDetailResult *result);   //NELPGslbResult


@interface NELPGslb : NSObject

/**
 @brief 设置日志打印级别(不设置的话默认为NELPGslbLogLevelInfo级别)
 
 @param logLevel 日志级别
 */
+ (void)setLogLevel:(NELPGslbLogLevel)logLevel;

/**
 @brief 设置预调度结果有效期
 
 @param validity 有效期(单位秒)。默认：30*60 最小取值：60
 */
+ (void)setResultValidityS:(NSInteger)validity;

/**
 @brief 增加预调度任务
 
 @param urls 预调度的url
 */
+ (void)addUrls:(NSArray <NSString *>*)urls;

/**
 @brief 移除预调度任务
 
 @param urls 预调度的url
 */
+ (void)removeUrls:(NSArray <NSString *>*)urls;

/**
 @brief 强制刷新所有预调度任务
 */
+ (void)refreshUrls;

/**
 @brief 查询预调度任务
 
 @param completion 查询完成。结果提取key:NELPGslbUrlKey(url) 和 NELPGslbStatusKey(状态)
 */
+ (void)queryTasks:(void (^)(NSArray <NSDictionary *> *tasks))completion;

/**
 @brief 查询预调度任务结果

 @param url 待查询的地址
 @param completion 调度结果完成
 */
+ (void)queryUrlResult:(NSString *)url
            completion:(NELPGslbQueryResultBlock)completion;

/**
 @brief 查询详细预调度任务结果

 @param url 待查询的地址
 @param completion 调度结果完成
 */
+ (void)queryUrlDetailResult:(NSString *)url
                  completion:(NELPGslbQueryDetailResultBlock)completion;

/**
 @brief 取消请求

 @param session 请求的session
 */
+ (void)cancelRequest:(id)session;

/**
 @brief 设置自定义的调度服务器地址(私有化部署)

 @param gslbRequestUrl   调度服务器地址
 */
+ (void)setGslbRequestUrl:(NSString *)gslbRequestUrl;

NS_ASSUME_NONNULL_END

@end
