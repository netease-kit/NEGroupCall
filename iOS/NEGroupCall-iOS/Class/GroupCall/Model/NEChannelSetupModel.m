//
//  NEChannelSetupModel.m
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/24.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEChannelSetupModel.h"

@implementation NEChannelSetupModel

+ (NSArray *)getData:(NSString *)fileName {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:fileName ofType:nil]];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSArray *resultArr = [[array.rac_sequence.signal map:^id _Nullable(NSDictionary *dict) {
        NEChannelSetupModel *model = [NEChannelSetupModel yy_modelWithDictionary:dict];
        return model;
    }] toArray] ;
    return resultArr;
}

+ (NSArray *)handleResolutionRatio:(NSString *)ratioValue orginArray:(NSArray*)orginArray {
    NSMutableArray *dataArray = [NSMutableArray arrayWithArray:orginArray];
    NEChannelSetupModel *model = [self getTargetDataModel:@"分辨率" dataSource:dataArray];
    model.content = ratioValue;
    return  [dataArray copy];
}

+ (NSArray *)handleFrameRate:(NSString *)frameRate orginArray:(NSArray*)orginArray {
    NSMutableArray *dataArray = [NSMutableArray arrayWithArray:orginArray];
    NEChannelSetupModel *model = [self getTargetDataModel:@"帧率" dataSource:dataArray];
    model.content = frameRate;
    return  [dataArray copy];
}

+ (NSArray *)handleSoundQuality:(NSString *)soundQuality orginArray:(NSArray*)orginArray {
    NSMutableArray *dataArray = [NSMutableArray arrayWithArray:orginArray];
    NEChannelSetupModel *model = [self getTargetDataModel:@"音质" dataSource:dataArray];
    model.content = soundQuality;
    return  [dataArray copy];
}

+ (NEChannelSetupModel *)getTargetDataModel:(NSString *)title dataSource:(NSMutableArray *)dataSource{
    for (NEChannelSetupModel *interfaceModel in dataSource) {
        if ([interfaceModel.title isEqualToString:title]) {
            return interfaceModel;
        }
    }
    return nil;
}
@end
