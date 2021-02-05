//
//  NENavigator.m
//  NLiteAVDemo
//
//  Created by Think on 2020/8/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NENavigator.h"
#import "NTELoginVC.h"
#import "NEAccount.h"
#import "NEGroupVideoJoinVC.h"
#import "NETSLiveListVC.h"
#import "NETSAnchorVC.h"
#import "NETSAudienceCollectionViewVC.h"
#import "NETSToast.h"

@interface NENavigator ()

@end

@implementation NENavigator

+ (NENavigator *)shared
{
    static NENavigator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NENavigator alloc] init];
    });
    return instance;
}

- (void)loginWithOptions:(NELoginOptions * _Nullable)options
{
    if ([NEAccount shared].hasLogin) {
        return;
    }
    if (_loginNavigationController && _navigationController.presentingViewController == _loginNavigationController) {
        return;
    }
    NTELoginVC *loginVC = [[NTELoginVC alloc] initWithOptions:options];
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    loginNav.navigationBar.barTintColor = [UIColor whiteColor];
    loginNav.navigationBar.translucent = NO;
    loginNav.modalPresentationStyle = UIModalPresentationFullScreen;
    __weak typeof(self) weakSelf = self;
    [_navigationController presentViewController:loginNav animated:YES completion:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.loginNavigationController = loginNav;
    }];
}

- (void)closeLoginWithCompletion:(_Nullable NELoginBlock)completion
{
    if (_loginNavigationController.presentingViewController) {
        [_loginNavigationController dismissViewControllerAnimated:YES completion:completion];
    } else {
        if (_loginNavigationController.navigationController) {
            [_loginNavigationController.navigationController popViewControllerAnimated:NO];
        } else {
            [_loginNavigationController popViewControllerAnimated:NO];
        }
        if (completion) {
            completion();
        }
    }
}

- (void)showGroupVC {
    NEGroupVideoJoinVC *groupVC = [[NEGroupVideoJoinVC alloc] init];
    groupVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:groupVC animated:YES];
}

- (void)showLiveListVC
{
    NETSLiveListVC *vc = [[NETSLiveListVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showAnchorVC
{
    NETSAnchorVC *vc = [[NETSAnchorVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showLivingRoom:(NSArray<NETSLiveRoomModel*> *)roomData selectindex:(NSInteger)index
{
    NETSAudienceCollectionViewVC *vc = [[NETSAudienceCollectionViewVC alloc]initWithScrollData:roomData currentRoom:index];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showRootNavWitnIndex:(NSInteger)index
{
    UITabBarController *tab = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    if (index >= [tab.viewControllers count]) {
        NETSLog(@"索引越界");
    }
    for (UIViewController *vc in tab.viewControllers) {
        if (![vc isKindOfClass:[UINavigationController class]]) {
            continue;
        }
        UINavigationController *nav = (UINavigationController *)vc;
        [nav popToRootViewControllerAnimated:NO];
    }
    
    [tab setSelectedIndex:index];
    [UIApplication sharedApplication].delegate.window.rootViewController = tab;
    UINavigationController *nav = tab.viewControllers[index];
    self.navigationController = nav;
}

@end
