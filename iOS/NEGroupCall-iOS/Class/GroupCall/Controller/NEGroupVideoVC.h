//
//  NEGroupCallVC.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEBaseViewController.h"
#import "NEJoinRoomTask.h"

NS_ASSUME_NONNULL_BEGIN
@protocol NEGroupVideoVCDelegate <NSObject>

- (void)didLeaveRoom:(NSString *)roomID roomUid:(NSInteger)uid;

@end
@interface NEGroupVideoVC : NEBaseViewController
@property(weak,nonatomic)id delegate;
@property(strong,nonatomic)NSString *nickname;
@property(strong,nonatomic)NEJoinRoomTask *task;
@property(nonatomic, assign) BOOL isCameraOpen;
@property(nonatomic, assign) BOOL isMicrophoneOpen;

@end

NS_ASSUME_NONNULL_END
