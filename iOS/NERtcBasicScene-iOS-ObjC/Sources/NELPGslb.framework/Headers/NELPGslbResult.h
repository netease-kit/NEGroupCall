//
//  NELPGslbResult.h
//  NELPGslb
//
//  Created by Netease on 2020/11/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NELPGslbUrlItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface NELPGslbResult : NSObject

@property (nonatomic, strong) id session;
@property (nonatomic, strong) NSMutableArray <NELPGslbUrlItem *> *addresses;

@end

NS_ASSUME_NONNULL_END

