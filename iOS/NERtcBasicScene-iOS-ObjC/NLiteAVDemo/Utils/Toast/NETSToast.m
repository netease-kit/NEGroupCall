//
//  NETSToast.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/3.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSToast.h"
#import "TopmostView.h"

@implementation NETSToast

+ (void)showToast:(NSString *)toast
{
    ntes_main_async_safe(^{
        [[TopmostView viewForApplicationWindow] makeToast:toast duration:3.0 position:CSToastPositionCenter];
    });
}

+ (void)showToast:(NSString *)toast pos:(id)pos
{
    ntes_main_async_safe(^{
        [[TopmostView viewForApplicationWindow] makeToast:toast duration:3.0 position:pos];
    });
}

+ (void)showLoading
{
    ntes_main_async_safe(^{
        [[TopmostView viewForApplicationWindow] makeToastActivity:CSToastPositionCenter];
    });
}

+ (void)hideLoading
{
    ntes_main_async_safe(^{
        [[TopmostView viewForApplicationWindow] hideToastActivity];
    });
}

@end
