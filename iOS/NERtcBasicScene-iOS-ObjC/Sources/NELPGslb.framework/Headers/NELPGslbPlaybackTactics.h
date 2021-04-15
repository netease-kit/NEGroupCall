//
//  NELPGslbPlaybackTactics.h
//  NELPGslb
//
//  Created by Netease on 2019/1/3.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct BufferParam {
    int launch_delay; // 启动延时
    int buffer_time; // 缓冲区大小
    int jitter_buffer_size; // jitter buffer初始大小
    int jitter_buffer_min; // jitter buffer 最小值
    int jitter_buffer_max; // jitter buffer 最大值
    int jitter_buffer_up_duration; // jitter buffer上升的时间步长
    int jitter_buffer_down_duration; // jitter buffer下降的时间步长
    int jitter_buffer_up_h; // jitter buffer快速上升比例
    int jitter_buffer_up_l; // jitter buffer慢速上升比例
    int jitter_buffer_down; // jitter buffer下降比例
    int flush_buffer_size; // 追赶延时的强度
    int flush_buffer_duration_h; // 追赶延时高档次的时间步长
    int flush_buffer_duration_m; // 追赶延时中档次的时间步长
    int flush_buffer_duration_l; // 追赶延时低档次的时间步长
    int a_buffer_time; // 缓冲区大小
    int a_jitter_buffer_size; // jitter buffer初始大小
    int a_jitter_buffer_min; // jitter buffer 最小值
    int a_jitter_buffer_max; // jitter buffer 最大值
    int a_jitter_buffer_up_duration; // jitter buffer上升的时间步长
    int a_jitter_buffer_down_duration; // jitter buffer下降的时间步长
    int a_jitter_buffer_up_h; // jitter buffer快速上升比例
    int a_jitter_buffer_up_l; // jitter buffer慢速上升比例
    int a_jitter_buffer_down; // jitter buffer下降比例
    int a_flush_buffer_size; // 追赶延时的强度
    int a_flush_buffer_duration_h; // 追赶延时高档次的时间步长
    int a_flush_buffer_duration_m; // 追赶延时中档次的时间步长
    int a_flush_buffer_duration_l; // 追赶延时低档次的时间步长
} BufferParam;

@interface NELPGslbPlaybackTactics : NSObject

// 启动延时
@property (nonatomic, assign) int launch_delay;

// 缓冲区大小
@property (nonatomic, assign) int buffer_time;

// jitter buffer初始大小
@property (nonatomic, assign) int jitter_buffer_size;

// jitter buffer 最小值
@property (nonatomic, assign) int jitter_buffer_min;

// jitter buffer 最大值
@property (nonatomic, assign) int jitter_buffer_max;

// jitter buffer上升的时间步长
@property (nonatomic, assign) int jitter_buffer_up_duration;

// jitter buffer下降的时间步长
@property (nonatomic, assign) int jitter_buffer_down_duration;

// jitter buffer快速上升比例
@property (nonatomic, assign) int jitter_buffer_up_h;

// jitter buffer慢速上升比例
@property (nonatomic, assign) int jitter_buffer_up_l;

// jitter buffer下降比例
@property (nonatomic, assign) int jitter_buffer_down;

// 追赶延时的强度
@property (nonatomic, assign) int flush_buffer_size;

// 追赶延时高档次的时间步长
@property (nonatomic, assign) int flush_buffer_duration_h;

// 追赶延时中档次的时间步长
@property (nonatomic, assign) int flush_buffer_duration_m;

// 追赶延时低档次的时间步长
@property (nonatomic, assign) int flush_buffer_duration_l;

// 缓冲区大小
@property (nonatomic, assign) int a_buffer_time;

// jitter buffer初始大小
@property (nonatomic, assign) int a_jitter_buffer_size;

// jitter buffer 最小值
@property (nonatomic, assign) int a_jitter_buffer_min;

// jitter buffer 最大值
@property (nonatomic, assign) int a_jitter_buffer_max;

// jitter buffer上升的时间步长
@property (nonatomic, assign) int a_jitter_buffer_up_duration;

// jitter buffer下降的时间步长
@property (nonatomic, assign) int a_jitter_buffer_down_duration;

// jitter buffer快速上升比例
@property (nonatomic, assign) int a_jitter_buffer_up_h;

// jitter buffer慢速上升比例
@property (nonatomic, assign) int a_jitter_buffer_up_l;

// jitter buffer下降比例
@property (nonatomic, assign) int a_jitter_buffer_down;

// 追赶延时的强度
@property (nonatomic, assign) int a_flush_buffer_size;

// 追赶延时高档次的时间步长
@property (nonatomic, assign) int a_flush_buffer_duration_h;

// 追赶延时中档次的时间步长
@property (nonatomic, assign) int a_flush_buffer_duration_m;

// 追赶延时低档次的时间步长
@property (nonatomic, assign) int a_flush_buffer_duration_l;

// 中心调度
@property (nullable, nonatomic, copy) NSString *ip_center_schedule;

// 上传日志
@property (nonatomic, assign) int uploadLog;

// 上报统计
@property (nonatomic, assign) int uploadstatistics;

// 流解析时间
@property (nonatomic, assign) int analyze_duration;

// 测速下发命令
@property (nonatomic, strong) NSArray *networkDiagnosisCmds;

//参数解析
- (instancetype)initWithRules:(NSString *)rules;

- (BOOL)isReadySetUpBufferParam;

- (BufferParam)rulesBufferParam;

@end

NS_ASSUME_NONNULL_END
