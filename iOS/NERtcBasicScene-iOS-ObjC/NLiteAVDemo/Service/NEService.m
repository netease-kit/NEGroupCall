//
//  NEService.m
//  NEDemo
//
//  Created by Think on 2020/8/26.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEService.h"
#import "NSMacro.h"

@implementation NEService

+ (instancetype)shared
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)runTask:(id<NEServiceTask>)task completion:(NERequestHandler)completion
{
    NSURLRequest *request = [task taskRequest];
    NSURLSessionTask *sessionTask =
    [[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
        NSLog(@"RequestURL:%@ \n error:%@ \n response:%@",request.URL.absoluteString,connectionError,response);
                                        id jsonData = nil;
                                        NSError *error = nil;
                                        
                                        if (connectionError == nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
                                            NSInteger status = [(NSHTTPURLResponse *)response statusCode];
                                            if (status == 200 && data) {
                                                jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:0
                                                                                             error:nil];
                                                if ([jsonData isKindOfClass:[NSDictionary class]]) {
                                                    NSDictionary *dict = jsonData;
                                                    if ([dict objectForKey:@"code"]) {
                                                        long code = [[dict objectForKey:@"code"] longValue];
                                                        NSString *msg = [dict objectForKey:@"msg"]?:@"";
                                                        if (code != 200) {
                                                            error = [NSError errorWithDomain:@"NTESErrorBusinessDomain"
                                                                                        code:code
                                                                                    userInfo:@{NSLocalizedDescriptionKey:msg}];
                                                        }
                                                    }
                                                }
                                            }else {
                                                error = connectionError;
                                            }
                                        }
                                        else {
                                            error = connectionError;
                                        }
                                        ntes_main_sync_safe(^{
                                            if (completion) {
                                                NSDictionary *dataDic = [jsonData objectForKey:@"data"];
                                                [(NETask *)task yy_modelSetWithDictionary:dataDic];
                                                completion(jsonData,task,error);
                                            }
                                        });
                                    }];
    [sessionTask resume];
}



@end
