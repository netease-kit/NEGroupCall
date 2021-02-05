//
//  NELPNetworkDiagnosisReporter.h
//  NELivePlayerFramework
//
//  Created by He on 2019/6/11.
//  Copyright © 2019 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NELPNetworkDiagnosisHandler) (BOOL success);

@interface NELPNetworkDiagnosisReporter : NSObject
+ (void)reportResult:(NSArray *)array
             pullUrl:(NSString *)pullUrl
             thirdId:(NSString * _Nullable)thirdId
          completion:(NELPNetworkDiagnosisHandler _Nullable)handler;
@end

NS_ASSUME_NONNULL_END
