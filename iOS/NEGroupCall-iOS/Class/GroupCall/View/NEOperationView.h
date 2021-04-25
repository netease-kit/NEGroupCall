//
//  NEOperationView.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol NEOperationViewDelegate <NSObject>

- (void)didSelectIndex:(NSInteger)index button:(UIButton *)button;

- (void)didSwitchBeauty:(BOOL)on;

- (void)didSelectStatsBtn;

@end

@interface NEOperationView : UIView
@property(weak,nonatomic)id delegate;
        
- (instancetype)initWithImages:(NSArray <NSString *>*)images
               selectedImages:(NSArray <NSString *>*)selectedImages
             isOpenMicrophone:(BOOL)isOpenMicrophone
                 isOpenCamera:(BOOL)isOpenCamera;

@end

NS_ASSUME_NONNULL_END
