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
    [self setIQKeyboard];
    setupLogger();
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

@end
