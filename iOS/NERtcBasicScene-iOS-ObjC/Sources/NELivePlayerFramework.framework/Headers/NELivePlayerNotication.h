//
//  NELivePlayerNotication.h
//  NELivePlayerFramework
//
//  Created by Netease on 2018/5/8.
//  Copyright © 2018年 netease. All rights reserved.
//  播放器通知定义

#ifndef NELivePlayerNotication_h
#define NELivePlayerNotication_h

#ifdef __cplusplus
#define NELP_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define NELP_EXTERN extern __attribute__((visibility ("default")))
#endif

/**
 * 调用prepareToPlay后，播放器初始化视频文件完成后的消息通知
 */
NELP_EXTERN NSString *const NELivePlayerDidPreparedToPlayNotification;

/**
 * 播放器加载状态发生改变时的消息通知
 */
NELP_EXTERN NSString *const NELivePlayerLoadStateChangedNotification;

/**
 * 播放器播放完成或播放发生错误时的消息通知。
 * 携带UserInfo:{NELivePlayerPlaybackDidFinishReasonUserInfoKey : [NSNumber],
 *                       NELivePlayerPlaybackDidFinishErrorKey : [NSNumber]}
 */
NELP_EXTERN NSString *const NELivePlayerPlaybackFinishedNotification;
/**
 * 播放器播放结束原因的key
 */
NELP_EXTERN NSString *const NELivePlayerPlaybackDidFinishReasonUserInfoKey;
/**
 * 播放成功时，此字段为nil。播放器播放结束具体错误码。具体至含义见NELPPLayerErrorCode
 */
NELP_EXTERN NSString *const NELivePlayerPlaybackDidFinishErrorKey;

/**
 * 播放器播放状态发生改变时的消息通知
 */
NELP_EXTERN NSString *const NELivePlayerPlaybackStateChangedNotification;

/**
 * 播放器解码器打开后的消息通知，指示硬件解码是否开启
 */
NELP_EXTERN NSString *const NELivePlayerHardwareDecoderOpenNotification;

/**
 * 播放器第一帧视频显示时的消息通知
 */
NELP_EXTERN NSString *const NELivePlayerFirstVideoDisplayedNotification;

/**
 * 播放器第一帧音频播放时的消息通知
 */
NELP_EXTERN NSString *const NELivePlayerFirstAudioDisplayedNotification;

/**
 * 播放器资源释放完成时的消息通知
 */
NELP_EXTERN NSString *const NELivePlayerReleaseSueecssNotification;

/**
 * seek完成时的消息通知，仅适用于点播，直播不支持。
 * 携带UserInfo:{NELivePlayerMoviePlayerSeekCompletedTargetKey : [NSNumber],
 *              NELivePlayerMoviePlayerSeekCompletedErrorKey : [NSNumber]}
 */
NELP_EXTERN NSString *const NELivePlayerMoviePlayerSeekCompletedNotification;
/**
 * seek失败时失败原因key
 */
NELP_EXTERN NSString *const NELivePlayerMoviePlayerSeekCompletedErrorKey;
/**
 * seek完成时的时间
 */
NELP_EXTERN NSString *const NELivePlayerMoviePlayerSeekCompletedTargetKey;   ///seek完成时的时间

/**
 * 播放过程中的Http状态码。
 * 携带UserInfo:{NELivePlayerHttpCodeResponseInfoKey : [NELivePlayerHttpCodeModel]}
 */
NELP_EXTERN NSString *const NELivePlayerHttpCodeResponseNotification;

/**
 * Http状态模型获取的key
 */
NELP_EXTERN NSString *const NELivePlayerHttpCodeResponseInfoKey; //Http状态模型获取的key

/**
 * 播放器失败重试通知
 */
NELP_EXTERN NSString *const NELivePlayerRetryNotification;

/**
 * 播放器失败当前重试次数
 */
NELP_EXTERN NSString *const NELivePlayerPlaybackDidRetryCountKey;


/**
 * 播放器视频尺寸发生改变时的消息通知
 * 携带UserInfo:{
 *                  NELivePlayerVideoWidthKey : @(width),
 *                  NELivePlayerVideoHeightKey: @(height)
 *             }
 */
NELP_EXTERN NSString *const NELivePlayerVideoSizeChangedNotification;

/**
* 播放器视频尺寸宽度Key
*/
NELP_EXTERN NSString *const NELivePlayerVideoWidthKey;

/**
* 播放器视频尺寸高度Key
*/
NELP_EXTERN NSString *const NELivePlayerVideoHeightKey;

#pragma mark - 即将废弃的通知
/**
 * 视频码流包解析异常时的消息通知
 */
NELP_EXTERN NSString *const NELivePlayerVideoParseErrorNotification NS_DEPRECATED_IOS(2_0, 2_0);

/**
 * 播放器解码卡顿通知
 */
NELP_EXTERN NSString *const NELivePlayerDecodeNotFluentNotification NS_DEPRECATED_IOS(2_0, 2_0);

#endif /* NELivePlayerNotication_h */
