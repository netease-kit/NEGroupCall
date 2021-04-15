//
//  AppDelegate.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/18.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "AppDelegate.h"
#import "NEMenuViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "NENavigator.h"
#import "NEPersonVC.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <NERtcSDK/NERtcSDK.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate,NERtcEngineDelegate>
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initWindow];
    [self setIQKeyboard];
    [self _addLogger];
    
    return YES;
}

- (void)initWindow {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    NEMenuViewController *menuVC = [[NEMenuViewController alloc] init];
    UINavigationController *appNav = [[UINavigationController alloc] initWithRootViewController:menuVC];
    appNav.tabBarItem.title = @"应用";
    appNav.tabBarItem.image = [UIImage imageNamed:@"application"];
    appNav.tabBarItem.selectedImage = [UIImage imageNamed:@"application_select"];

    NEPersonVC *personVC = [[NEPersonVC alloc] init];
    UINavigationController *personNav = [[UINavigationController alloc] initWithRootViewController:personVC];
    personNav.tabBarItem.title = @"个人中心";
    personNav.tabBarItem.image = [UIImage imageNamed:@"mine"];
    personNav.tabBarItem.selectedImage = [UIImage imageNamed:@"mine_select"];

    UITabBarController *tab = [[UITabBarController alloc] init];
    tab.tabBar.tintColor = [UIColor whiteColor];
    tab.tabBar.barStyle = UIBarStyleBlack;
    tab.viewControllers = @[appNav,personNav];
    
    self.window.rootViewController = tab;
    [NENavigator shared].navigationController = appNav;
    [self.window makeKeyAndVisible];
}

- (void)setIQKeyboard {
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
}

- (void)_addLogger
{
    // 添加DDASLLogger，你的日志语句将被发送到Xcode控制台
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    // 添加DDFileLogger，你的日志语句将写入到一个文件中，默认路径在沙盒的Library/Caches/Logs/目录下，文件名为bundleid+空格+日期.log。
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logPath = [paths.firstObject stringByAppendingPathComponent:@"NETSPkLive"];
    DDLogFileManagerDefault *mailFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logPath];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:mailFileManager];
    NSString *logDirectory = [fileLogger.logFileManager logsDirectory];
    DDLogDebug(@"PATH: %@", logDirectory);
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
}

@end
