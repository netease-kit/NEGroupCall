//
//  NEGroupVideoView.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEGroupVideoView : UIView
@property(strong,nonatomic)UIView *videoView;
@property(strong,nonatomic,nullable)NSString *userName;
- (void)updateMicroEnable:(BOOL)microEnable;

@end

NS_ASSUME_NONNULL_END
