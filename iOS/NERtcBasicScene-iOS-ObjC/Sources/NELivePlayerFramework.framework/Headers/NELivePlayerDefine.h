//
//  NELivePlayerDefine.h
//  NELivePlayerFramework
//
//  Created by Netease on 2018/5/8.
//  Copyright © 2018年 netease. All rights reserved.
//  播放器相关宏定义

#ifndef NELivePlayerDefine_h
#define NELivePlayerDefine_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NELivePlayerSyncContent;
@class NELivePlayerGslbResult;

/**
 *  预调度的状态
 */
typedef NS_ENUM(NSInteger, NELPGslbTaskStatus) {
    /**
     *  等待状态
     */
    NELP_GSLB_TASK_WAITING = 0,
    /**
     *  运行状态
     */
    NELP_GSLB_TASK_RUNNING,
    /**
     *  完成状态
     */
    NELP_GSLB_TASK_COMPLETE
};

/**
 *  日志等级
 */
typedef NS_ENUM(NSInteger, NELPLogLevel)
{
    /**
     *  输出详细
     */
    NELP_LOG_DEFAULT = 1,
    /**
     *  输出详细
     */
    NELP_LOG_VERBOSE = 2,
    /**
     *  输出调试信息
     */
    NELP_LOG_DEBUG   = 3,
    /**
     *  输出标准信息
     */
    NELP_LOG_INFO    = 4,
    /**
     *  输出警告
     */
    NELP_LOG_WARN    = 5,
    /**
     *  输出错误
     */
    NELP_LOG_ERROR   = 6,
    /**
     *  一些错误信息，如头文件找不到，非法参数使用
     */
    NELP_LOG_FATAL   = 7,
    /**
     *  不输出
     */
    NELP_LOG_SILENT  = 8,
};

/**
 *  错误码
 */
typedef NS_ENUM(NSInteger, NELPPLayerErrorCode) {
    /**
     *  初始化的URL格式错误
     */
    NELP_INIT_URL_FORMAT_ERROR = 1000,
    /**
     *  初始化的URL是推流地址
     */
    NELP_INIT_URL_ISPUSH_ERROR = 1001,
    /**
     *  初始化的URL解析错误
     */
    NELP_INIT_URL_PARSE_ERROR = 1002,
    /**
     * 解密视频，解密参数错误
     */
    NELP_DECRYPTION_PARMAS_ERROR = 2000,
    /**
     * 解密视频，密钥错误
     */
    NELP_DECRYPTION_KEY_CHECK_ERROR = 2001,
    /**
     * 解密视频，获取密钥服务端请求过程中错误
     */
    NELP_DECRYPTION_GET_KEY_REMOTE_ERROR = 2003,
    /**
     * 解密视频，未知错误
     */
    NELP_DECRYPTION_UNKNOWN_ERROR = 2004,
    /**
     *  播放过程中，HTTP连接失败
     */
    NELP_PLAY_HTTP_CONNECT_ERROR = -1001,
    /**
     *  播放过程中，RTMP连接失败
     */
    NELP_PLAY_RTMP_CONNECT_ERROR = -1002,
    /**
     *  播放过程中，解析失败
     */
    NELP_PLAY_STREAM_PARSE_ERROR = -1003,
    /**
     *  播放过程中，缓冲失败
     */
    NELP_PLAY_BUFFING_ERROR    = -1004,
    /**
     *  播放过程中，音频相关操作初始化失败
     */
    NELP_PLAY_AUDIO_OPEN_ERROR = -2001,
    /**
     *  播放过程中，视频相关操作初始化失败
     */
    NELP_PLAY_VIDEO_OPEN_ERROR = -2002,
    /**
     *  播放过程中，没有音视频流
     */
    NELP_PLAY_STREM_IS_ERROR   = -3001,
    /**
     *  播放过程中，音频解码失败
     */
    NELP_PLAY_AUDIO_DECODE_ERROR = -4001,
    /**
     *  播放过程中，视频解码失败
     */
    NELP_PLAY_VIDEO_DECODE_ERROR = -4002,
    /**
     *  播放过程中，音频播放失败
     */
    NELP_PLAY_AUDIO_RENDER_ERROR = -5001,
    /**
     *  播放过程中，视频播放失败
     */
    NELP_PLAY_VIDEO_RENDER_ERROR = -5002,
    /**
     *  播放过程中，未知错误
     */
    NELP_PLAY_UNKNOWN_ERROR      = -10000,
};

/**
 *  缓冲策略
 */
typedef NS_ENUM(NSInteger, NELPBufferStrategy) {
    /**
     *  极速模式，适用于视频直播，延时最小，网络抖动时容易发生卡顿
     */
    NELPTopSpeed = 0,
    /**
     *  网络直播低延时，适用于视频直播，延时低，网络抖动时偶尔有卡顿
     */
    NELPLowDelay,
    /**
     *  网络直播流畅，适用于视频直播，流畅性好，延时比低延时模式稍大
     */
    NELPFluent,
    /**
     *  网络点播抗抖动，适用于视频点播和本地视频，抗抖动性强
     */
    NELPAntiJitter,
    /**
     *  网络直播, 延时追赶策略
     */
    NELPDelayPullUp
};

/**
 *  画面显示模式
 */
typedef NS_ENUM(NSInteger, NELPMovieScalingMode) {
    /**
     *  无缩放
     */
    NELPMovieScalingModeNone,
    /**
     *  等比例缩放，某一边会有黑边填充
     */
    NELPMovieScalingModeAspectFit,
    /**
     *  等比例缩放，某一边可能会被裁减
     */
    NELPMovieScalingModeAspectFill,
    /**
     *  全屏显示，画面宽高比可能与视频原始宽高比不一致
     */
    NELPMovieScalingModeFill
};

/**
 * 播放状态
 */
typedef NS_ENUM(NSInteger, NELPMoviePlaybackState) {
    /**
     * 停止状态
     */
    NELPMoviePlaybackStateStopped,
    /**
     * 播放状态
     */
    NELPMoviePlaybackStatePlaying,
    /**
     * 暂停状态，可调play继续播放
     */
    NELPMoviePlaybackStatePaused,
    /**
     * Seek状态
     */
    NELPMoviePlaybackStateSeeking
};

/**
 * 加载状态
 */
typedef NS_ENUM(NSInteger, NELPMovieLoadState) {
    /**
     * 在该状态下，播放器初始化完成，可以播放，若shouldAutoplay 设置成YES，播放器初始化完成后会自动播放
     */
    NELPMovieLoadStatePlayable,
    /**
     * 在该状态下，在网络不好的情况下缓冲完成，可以播放
     */
    NELPMovieLoadStatePlaythroughOK,
    /**
     * 在播放过程中网络不好需要缓冲数据的时候播放会自动暂停
     */
    NELPMovieLoadStateStalled
};

/**
 * 播放结束的原因
 */
typedef NS_ENUM(NSInteger, NELPMovieFinishReason) {
    /**
     * 正常播放结束
     */
    NELPMovieFinishReasonPlaybackEnded,
    /**
     * 播放发生错误导致结束
     */
    NELPMovieFinishReasonPlaybackError,
    /**
     * 人为退出(暂未使用，保留值)
     */
    NELPMovieFinishReasonUserExited,
};

/**
 * 视频信息
 */
typedef struct NELPVideoInfo {
    /**
     * 视频编码器类型 如: h264
     */
    const char *codec_type;
    /**
     * 视频宽度
     */
    NSInteger   width;
    /**
     * 视频高度
     */
    NSInteger   height;
    /**
     * 视频的帧率
     */
    CGFloat     fps;
    /**
     * 码率 (单位: kb/s)
     */
    NSInteger   bitrate;
}NELPVideoInfo;

/**
 * 音频信息
 */
typedef struct NELPAudioInfo {
    /**
     * 音频编码器类型 如: aac
     */
    const char *codec_type;
    /**
     * 音频的采样率
     */
    NSInteger  sample_rate;
    /**
     * 码率 (单位: kb/s)
     */
    NSInteger  bitrate;
    /**
     * 音频的通道数
     */
    NSInteger  numOfChannels;
}NELPAudioInfo;

/**
 * 回调的视频数据格式
 */
typedef NS_ENUM(int, NELPVideoFormatE) {
    /**
     * YUV420
     */
    NELP_YUV420 = 1,
};

/**
 * 回调的视频数据结构
 */
typedef struct NELPVideoRawData {
    /**
     * 回调的视频数据格式
     */
    NELPVideoFormatE format;
    /**
     * stride 信息，对于YUV420，stride[0]为Y，stride[1]为U，stride[2]为V
     */
    int              stride[3];
    /**
     * stride 个数，如YUV420格式为3个
     */
    int              stride_num;
    /**
     * 视频宽度
     */
    int              width;
    /**
     * 视频高度
     */
    int              height;
    /**
     * 视频数据
     */
    unsigned char   *UsrData;
} NELPVideoRawData;

/**
 * 回调的音频数据结构
 */
typedef struct NELPAudioRawData {
    /**
     * 通道数
     */
    int            channels;
    /**
     * 采样率
     */
    int            samplerate;
    /**
     * 数据长度
     */
    int            data_size;
    /**
     * 音频数据
     */
    unsigned char *usrData;
} NELPAudioRawData;

/**
 * 切片清晰度
 */
typedef NS_ENUM(NSInteger, NELPMultiMediaType) {
    /**
     * 无效的
     */
    NELP_MEDIA_INVALID = -1,
    /**
     * 低清
     */
    NELP_MEDIA_SD      = 0,
    /**
     * 标清
     */
    NELP_MEDIA_MD      = 1,
    /**
     * 高清
     */
    NELP_MEDIA_HD      = 2,
    /**
     * 超清
     */
    NELP_MEDIA_SHD     = 3,
};

/**
 * 切换切片结果
 */
typedef NS_ENUM(NSInteger, NELPSwitchStreamState) {
    /**
     * 切换成功
     */
    NELP_SWITCH_SUCCESS   = 0,
    /**
     * 没有对应的流
     */
    NELP_SWITCH_NO_STREAM = 1,
    /**
     * 切换失败
     */
    NELP_SWITCH_FAILED    = 2,
};

/**
 * 选择流的状态
 */
typedef struct NELPSwitchStreamResult {
    /**
     * 状态
     */
    NELPSwitchStreamState state;
}NELPSwitchStreamResult;

/**
 * AudioQueue
 */
typedef struct NELPAudioQueue {
    float first_pts;
    float last_pts;
    int   nb_packets;
} NELPAudioQueue;


#pragma mark - 相关回调
/**
 * @brief 日志的回调
 *
 * @param 日志回调信息
 */
typedef void(^NELivePlayerLogCallback)(NSString *logMsg);

/**
 * @brief 视频数据的回调
 *
 * @param 回调的视频信息
 */
typedef void(^NELPVideoRawDataCB)(NELPVideoRawData *frame);

/**
 * @brief 音频数据的回调
 *
 * @param 回调的音频信息
 */
typedef void(^NELPAudioRawDataCB)(NELPAudioRawData *frame);

/**
 * @brief 清晰度切换的结果回调
 *
 * @param result 回调的切换结果
 */
typedef void (^NELPSwitchStreamResultCB)(NELPSwitchStreamResult result);

/**
 * @brief 时间戳回调
 *
 * @param realTime 真实时间戳
 */
typedef void (^NELPTimestampCallCB)(NSTimeInterval realTime);

/**
 * @brief 同步自定义信息回调
 *
 * @param content 自定义信息
 */
typedef void (^NELPSyncContentCB)(NELivePlayerSyncContent *content);

/**
 * @brief 字幕显示回调
 *
 * @param isShown 是否显示
 * @param subtitleId 字幕ID
 * @param subtitleText 字幕信息
 */
typedef void(^NELivePlayerSubtitleBlock)(BOOL isShown, NSInteger subtitleId, NSString *subtitleText);

#pragma mark - 音轨信息


typedef NS_ENUM(NSInteger, NELPUrlDecryptionType) {
    NELPUrlDecryptionOriginalKey = 0,    //原始密钥解密
    NELPUrlDecryptionService,            //服务端请求密钥解密
};

#pragma mark - DataSource
@protocol NELivePlayerDataSource <NSObject>
@required

/**
 读取数据

 @param position 读取的位置
 @param buffer 数据缓存
 @param offset 偏移
 @param size 数据长度
 @return 实际读到的数据。< 0 表示失败
 */
- (int)readAtPosition:(long)position
               buffer:(void *)buffer
                 size:(int)size
                error:(NSError **)error;

/**
 获取文件大小

 @return 如果不知道实际大小，那么返回-1
 */
- (BOOL)getSize:(int64_t *)size;

/**
 关闭
 */
- (BOOL)close;

/**
 返回用于拉流播放的链接地址

 @return 地址.null 表示失败
 */
- (NSString *)getPath;

@end

#endif /* NELivePlayerDefine_h */
