//
//  NEBaseViewController.m
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEBaseViewController.h"
#import "NETSDeviceSIzeInfo.h"

@interface NEBaseViewController ()
@property (nonatomic,assign,readwrite) CGFloat currentNavHeight;
@property (nonatomic, readwrite, assign) CGFloat currentTabbarHeight;
@end

@implementation NEBaseViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    NEBaseViewController *viewController = [super allocWithZone:zone];
    @weakify(viewController)
    [[viewController rac_signalForSelector:@selector(viewDidLoad)] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(viewController)
        
        [viewController ne_layoutNavigation];
        [viewController ne_initializeConfig];
        [viewController ne_addSubViews];
        [viewController ne_bindViewModel];
        [viewController ne_getNewData];

    }] ;
    return viewController;
}


- (void)initialize {
    self.currentNavHeight = [UIApplication sharedApplication].statusBarFrame.size.height+44.0;
    self.currentTabbarHeight = [NETSDeviceSIzeInfo get_iPhoneTabBarHeight];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = HEXCOLOR(0x1A1A24);
}

#pragma mark ========= 导航栏Item添加 =========
- (void)addLeftNavItem:(NSString *)title actionBlock:(void (^)(id))actionBlock {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftButton];
    [self.leftButton setTitle:title forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftItem;
    [[self.leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        if (actionBlock) {
            actionBlock(x);
        }
    }];
}
- (void)addLeftImageNavItem:(NSString *)imageName actionBlock:(void(^)(id sender))actionBlock {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftButton];
    [self.leftButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.leftButton setTitle:@"" forState:UIControlStateNormal];
    [self.leftButton setContentEdgeInsets:UIEdgeInsetsMake(0, -50, 0, 0)];
    self.navigationItem.leftBarButtonItem = leftItem;
    [[self.leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        if (actionBlock) {
            actionBlock(x);
        }
    }];
}

- (void)addRightNavItem:(NSString *)title actionBlock:(void (^)(id))actionBlock {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightButton];
    [self.rightButton setTitle:title forState:UIControlStateNormal];
    [self.rightButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = TextFont_16;
    self.navigationItem.rightBarButtonItem = rightItem;
    [[self.rightButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        if (actionBlock) {
            actionBlock(x);
        }
    }];
}

- (void)addRightImageNavItem:(NSString *)imageName actionBlock:(void(^)(id sender))actionBlock {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightButton];
    [self.rightButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
     [self.rightButton setTitle:@"" forState:UIControlStateNormal];
    [self.rightButton setContentEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
     self.navigationItem.rightBarButtonItem = rightItem;
     [[self.rightButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
         if (actionBlock) {
             actionBlock(x);
         }
     }];
}
/**
 初始化导航栏配置
 */
- (void)ne_layoutNavigation {
    
}


/**
 配置子视图
 */
- (void)ne_addSubViews {
    
}

/**
 初始化相关配置
 */
- (void)ne_initializeConfig {
    
}

/**
 绑定视图模型以及相关事件
 */
- (void)ne_bindViewModel {
    
}

/**
 加载数据
 */
- (void)ne_getNewData {
    
}


  //#pragma mark - 控制屏幕旋转方法
//是否自动旋转,返回YES可以自动旋转,返回NO禁止旋转
- (BOOL)shouldAutorotate{
    return NO;
}

//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark ========= Lazy =========
- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [NETSViewFactory createBtnFrame:CGRectMake(0, 0, 60, 30) title:@"取消" bgImage:nil selectBgImage:nil image:@"" target:nil action:nil];
        [_leftButton setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_leftButton setContentEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
        
    }
    return _leftButton;
}
- (UIButton *)rightButton {
    if (!_rightButton) {
        //设置位置可增加响应范围大小
        _rightButton = [NETSViewFactory createBtnFrame:CGRectMake(0, 0, 60, 30) title:@"" bgImage:nil selectBgImage:nil image:@"" target:nil action:nil];
        [_rightButton setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_rightButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -30)];

    }
    return _rightButton;
}

- (void)dealloc {
    //输出当前控制器销毁信息
    YXAlogInfo(@"releaseVc %@ %s",NSStringFromClass([self class]),__FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
