//
//  NSMacro.h
//  NLiteAVDemo
//
//  Created by Think on 2020/8/26.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

// base host
#define BASE_HOST @""

// 隐私政策URL
static NSString *kPrivatePolicyURL = @"https://reg.163.com/agreement_mobile_ysbh_wap.shtml?v=20171127";
// 用户协议URL
static NSString *kUserAgreementURL = @"http://yunxin.163.com/clauses";


// 线程
void ntes_main_sync_safe(dispatch_block_t block);
void ntes_main_async_safe(dispatch_block_t block);


/// 设备尺寸
#define kScreenWidth        [UIScreen mainScreen].bounds.size.width
#define kScreenHeight       [UIScreen mainScreen].bounds.size.height
#define kScreenMinLen       MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define kScreenMaxLen       MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define KStatusHeight       [[UIApplication sharedApplication] statusBarFrame].size.height
#define KNavBottom          KStatusHeight + 44
#define KIsSmallSize        [UIScreen mainScreen].bounds.size.width <= 568 ? YES : NO



/// 是否全面屏
#define kIsFullScreen        (@available(iOS 11.0, *) && UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom > 0.0)

/// weakSelf strongSelf reference
#define WEAK_SELF(weakSelf) __weak __typeof(&*self) weakSelf = self;
#define STRONG_SELF(strongSelf) __strong __typeof(&*weakSelf) strongSelf = weakSelf;

/// 聊天室通知
#define kChatroomUserLeave @"kChatroomNumberLeave"
#define kChatroomUserEnter @"kChatroomNumberEnter"


#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


// 字符串判空
bool isEmptyString(NSString *string);

/// 配置日志
void setupLogger(void);

/// 默认PK直播时长150s(2:30)
#define kPkLiveTotalTime        150

/// 默认PK直播惩罚时长60s(1:00)
#define kPkLivePunishTotalTime  60
