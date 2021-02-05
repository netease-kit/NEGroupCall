//
//  NELivePlayerModel.h
//  NELivePlayerFramework
//
//  Created by Netease on 2018/9/27.
//  Copyright © 2018年 netease. All rights reserved.
//  播放器相关模型定义

#import <Foundation/Foundation.h>
#import "NELivePlayerDefine.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 缓存配置模型
@interface NELPUrlCacheConfig : NSObject

/**
 是否缓存。默认：NO。
 */
@property (nonatomic, assign) BOOL isCache;

/*
* 缓存的路径地址
*
* 每个视频缓存时都会在缓存文件夹路径下面生成两个文件，一个是视频缓存文件，一个是视频缓存索引文件。
*
* 如果为空，那么内部自动缓存到默认地址，并且每次释放播放器、重置播放器、切换拉流地址会删除缓存的视频文件。
*
* 如果不为空，那么SDK会根据设置进来的文件夹路径进行缓存，APP应用层自行管理缓存的文件，SDK不会删除缓存的文件，
* 用户应该每个视频都设置一个对应的缓存文件夹给播放器，这样用户知道每个视频的缓冲文件对应的文件夹，用户只需要对文件夹进行管理就可以管理该视频的缓存文件。
* 如果多个不同地址（类似于防盗链场景）播放的同一个视频，只需要设置相同的缓存文件夹路径就可以自动识别进行缓存文件，不会重复缓存。
*/

@property (nullable, nonatomic, copy) NSString * cacheRootPath;

@end

#pragma mark - 解密配置模型
@interface NELPUrlDecryptionConfig : NSObject
/**
 * 解密类型
 */
@property (nonatomic, readonly) NELPUrlDecryptionType type;
/**
 * 原始密钥。Type 为 NELPUrlDecryptionOriginalKey 时需要设置
 */
@property (nullable, nonatomic, readonly) NSData *originalKey;

/**
 TransferToken.Type 为 NELPUrlDecryptionService 时需要设备
 */
@property (nonatomic, readonly) NSString *transferToken;

/**
 accid 为 NELPUrlDecryptionService 时需要设备
 */
@property (nonatomic, readonly) NSString *accid;

/**
 appKey 为 NELPUrlDecryptionService 时需要设备
 */
@property (nonatomic, readonly) NSString *appKey;

/**
 token 为 NELPUrlDecryptionService 时需要设备
 */
@property (nonatomic, readonly) NSString *token;

/**
 快速构造方法（原始密钥解密）

 @param originalKey 原始密钥
 @return 配置实例
 */
+ (instancetype)configWithOriginalKey:(nullable NSData *)originalKey;

/**
 快速构造方法（服务端管理密钥解密）

 @param transferToken transferToken
 @param accid accid
 @param appKey appKey
 @param token token
 @return 配置实例
 */
+ (instancetype)configWithTransferToken:(NSString *)transferToken
                                  accid:(NSString *)accid
                                 appKey:(NSString *)appKey
                                  token:(NSString *)token;

@end

#pragma mark - 播放源 Url 相关配置模型
@interface NELPUrlConfig : NSObject

/**
 缓存配置
 */
@property (nullable, nonatomic, strong) NELPUrlCacheConfig *cacheConfig;

/**
 解密配置(点播)
 */
@property (nullable, nonatomic, strong) NELPUrlDecryptionConfig *decryptionConfig;


/**
 解密配置(直播)
 */
@property (nullable, nonatomic, copy) NSString *liveUrlDecryptionKey;

/**
 http请求自定义的header field
 */
@property (nullable, nonatomic, strong) NSDictionary *httpHeaders;

@end

#pragma mark - 失败重连配置模型
@interface NELPRetryConfig : NSObject

/**
 重试次数。默认值：0。 -1表示无限重试。
 */
@property (nonatomic, assign) NSTimeInterval count;

/**
 默认重试间隔时间。默认值：0。 0表示立即重试。单位：s
 */
@property (nonatomic, assign) NSTimeInterval defaultIntervalS;

/**
 自定义重试间隔时间。nil表示使用默认间隔。如果数组元素个数大于重试次数，取前面的重试次数个值；如果小于，后面未配置的值使用默认时间间隔。
 */
@property (nonatomic, strong) NSMutableArray <NSNumber *> *customIntervalS;

@end

#pragma mark - HTTP通知信息携带的模型
/**
 * HTTP通知信息携带的模型
 */
@interface NELivePlayerHttpCodeModel : NSObject
/**
 * http 请求返回状态码
 */
@property (nonatomic, assign) int code;
/**
 * http 请求返回Header
 */
@property (nonatomic, copy) NSString *header;
@end

#pragma mark - 自定义透传信息模型
/**
 * 自定义透传信息模型
 */
@interface NELivePlayerSyncContent : NSObject
/**
 * 透传的信息
 */
@property (nonatomic, strong) NSArray <NSString *>*contents;
@end

#pragma mark - 音轨信息模型类
/**
 音轨信息类
 */
@interface NELivePlayerAudioTrackInfo : NSObject

/**
 采样率
 */
@property (nonatomic, assign) NSInteger sampleRate;

/**
 码率
 */
@property (nonatomic, assign) NSInteger bitrate;

/**
 声道数
 */
@property (nonatomic, assign) NSInteger numOfChannels;

/**
 编码器类型
 */
@property (nonatomic, copy) NSString *codecName;

/**
 语言
 */
@property (nonatomic, copy) NSString *language;

/**
 标题
 */
@property (nonatomic, copy) NSString *title;

@end

#pragma mark - PCM配置模型类
/**
 PCM配置模型类
 */
@interface NELivePlayerPcmConfig : NSObject

/**
 通道数
 */
@property (nonatomic, assign) int channels;

/**
 采样率
 */
@property (nonatomic, assign) int sampleRate;

@end

#pragma mark - 播放的实时信息

@interface NELivePlayerRealTimeInfo : NSObject

/**
 视频接收的码率
 */
@property (nonatomic, assign) NSInteger videoReceiveBitrate;
/**
 视频接收的楨率
 */
@property (nonatomic, assign) NSInteger videoReceiveFramerate;
/**
 视频播放的楨率
 */
@property (nonatomic, assign) NSInteger videoPlayFramerate;
/**
 视频缓存的时长
 */
@property (nonatomic, assign) uint64_t videoCacheDuration;
/**
 视频缓存的大小
 */
@property (nonatomic, assign) uint64_t videoCacheBytes;
/**
 音频接收的码率
 */
@property (nonatomic, assign) NSInteger audioReceiveBitrate;
/**
 音频缓存的时长
 */
@property (nonatomic, assign) uint64_t audioCacheDuration;
/**
 音频缓存的大小
 */
@property (nonatomic, assign) uint64_t audioCacheBytes;
/**
 音频和视频的播放时间差
 */
@property (nonatomic, assign) NSTimeInterval AVPlayTimeDifference;

@end

NS_ASSUME_NONNULL_END
