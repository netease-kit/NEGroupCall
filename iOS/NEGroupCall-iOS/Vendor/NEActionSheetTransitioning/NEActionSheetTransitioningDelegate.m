
//
//  NEActionSheetTransitioningDelegate.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/26.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NEActionSheetTransitioningDelegate.h"
#import "NEActionSheetPresentationController.h"
#import "NEActionSheetDismissalController.h"

@interface NEActionSheetTransitioningDelegate ()

// present动画
@property (nonatomic, strong) NEActionSheetPresentationController *presentationController;

// dismiss动画
@property (nonatomic, strong) NEActionSheetDismissalController *dismissalController;

@end

@implementation NEActionSheetTransitioningDelegate

@dynamic dismissOnTouchOutside;

+ (instancetype)defaultInstance {
    static dispatch_once_t onceToken;
    static NEActionSheetTransitioningDelegate *instance;
    dispatch_once(&onceToken, ^{
        instance = [[NEActionSheetTransitioningDelegate alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.presentationController = [[NEActionSheetPresentationController alloc] init];
        self.dismissalController = [[NEActionSheetDismissalController alloc] init];
    }
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.presentationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.dismissalController;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.presentationController.dismissAnimator;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [self.presentationController respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.presentationController respondsToSelector:aSelector]) {
        return self.presentationController;
    }
    return [super forwardingTargetForSelector:aSelector];
}

@end
