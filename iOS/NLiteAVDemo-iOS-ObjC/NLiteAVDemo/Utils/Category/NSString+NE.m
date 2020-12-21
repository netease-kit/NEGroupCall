//
//  NSString+NE.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/23.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NSString+NE.h"

@implementation NSString (NE)
- (NSString *)ne_trimming {
    return [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}
- (BOOL)ne_isNumber {
    NSString *string = [self ne_trimming];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    return string.length > 0 ? NO : YES;
}
@end
