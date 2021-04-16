//
//  NETSGCDTimer.m
//  NLiteAVDemo
//
//  Created by Think on 2021/1/10.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSGCDTimer.h"

@interface NETSGCDTimer ()

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation NETSGCDTimer

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                       repeats:(BOOL)repeats
                                         queue:(dispatch_queue_t)queue
                                         block:(void (^)(void))block
{
    NETSGCDTimer *timer = [[NETSGCDTimer alloc] initWithInterval:interval repeats:repeats queue:queue triggerImmediately:YES block:block];
    return timer;
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                       repeats:(BOOL)repeats
                                         queue:(dispatch_queue_t)queue
                            triggerImmediately:(BOOL)immediately
                                         block:(void (^)(void))block
{
    NETSGCDTimer *timer = [[NETSGCDTimer alloc] initWithInterval:interval repeats:repeats queue:queue triggerImmediately:immediately block:block];
    return timer;
}

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         repeats:(BOOL)repeats
                           queue:(dispatch_queue_t)queue
              triggerImmediately:(BOOL)immediately
                           block:(void (^)(void))block
{
    self = [super init];
    if (self) {
        if (immediately) {
            dispatch_async(queue, block);
            if (!repeats) {
                return self;
            }
        }
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
        __weak typeof(self) wself = self;
        dispatch_source_set_event_handler(self.timer, ^{
            if (!repeats) {
                dispatch_source_cancel(wself.timer);
            }
            block();
        });
        dispatch_resume(self.timer);
    }
    return self;
}

- (void)dealloc
{
    [self invalidate];
}

- (void)invalidate
{
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

@end
