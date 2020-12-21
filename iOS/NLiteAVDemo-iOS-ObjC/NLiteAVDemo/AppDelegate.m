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

@interface AppDelegate ()<UNUserNotificationCenterDelegate,NERtcEngineDelegate>
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initWindow];
    [self setupRTCSDK];
    [self registerAPNS];
    [self setIQKeyboard];
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
- (void)setupRTCSDK {
    // Rtc
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.engineDelegate = self;
    context.appKey = kAppKey;
    [coreEngine setupEngineWithContext:context];
    NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
    config.maxProfile = kNERtcVideoProfileHD720P;
    [coreEngine setLocalVideoConfig:config];
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
}

- (void)setIQKeyboard {
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
}

- (void)registerAPNS
{
    // 1.申请权限
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!granted) {
                [self.window makeToast:@"请到设置中开启推送功能"];
            }
        }];
    } else {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    // 2.注册通知
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

// 3.APNS注册回调
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:deviceTokenKey];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 }

// 4.接收通知
// iOS 10.0 在前台收到通知
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
//}

//在后收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    completionHandler();
}
//低于iOS 10.0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

@end
