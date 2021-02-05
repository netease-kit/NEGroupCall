//
//  NELPGslbStatInfo.h
//  NELPGslb
//
//  Created by Netease on 2019/1/3.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NELPGslbDetailUrlItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NELPGslbStatInfo : NSObject

//http开始的时间
@property (nonatomic, assign) int64_t beginHttpTime;

//http结束的时间
@property (nonatomic, assign) int64_t endHttpTime;

//是否执行了排序
@property (nonatomic, assign) BOOL isSorted;

//sort结束的时间
@property (nonatomic, assign) int64_t endSortTime;

//结果与服务端一致
@property (nonatomic, assign) BOOL isDiffFromServer;

//错误
@property (nonatomic, strong) NSError *error;

//http返回code
@property (nonatomic, assign) NSInteger httpRetCode;

//gslb请求id
@property (nonatomic, copy) NSString *requestId;

//gslb下发的时间
@property (nonatomic, assign) int64_t time;

//gslb下发时刻本地的时间
@property (nonatomic, assign) int64_t localTime;

//http返回的全部信息
@property (nonatomic, strong) NSDictionary *httpResponse;

//http返回的调度结果
@property (nonatomic, strong) NSMutableArray <NELPGslbDetailUrlItem *> *httpResults;

@end

NS_ASSUME_NONNULL_END
