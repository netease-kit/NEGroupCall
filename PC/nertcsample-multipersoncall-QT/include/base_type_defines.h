#ifndef BASE_TYPE_DEFINES_H
#define BASE_TYPE_DEFINES_H

enum NetWorkQualityType { NETWORKQUALITY_GOOD = 0, NETWORKQUALITY_GENERAL, NETWORKQUALITY_POOR, NETWORKQUALITY_BAD };

struct NERoomStats {
    unsigned int cpu_app_usage;     /**< 当前 App 的 CPU 使用率 (%)。*/
    unsigned int cpu_total_usage;	/**< 当前系统的 CPU 使用率 (%)。*/
    int tx_audio_kbitrate;	        /**< 音频发送码率。(kbps)*/
    int rx_audio_kbitrate;	        /**< 音频接收码率。(kbps)*/
    int tx_video_kbitrate;	        /**< 视频发送码率。(kbps)*/
    int rx_video_kbitrate;	        /**< 视频接收码率。(kbps)*/
    int up_rtt;	                    /**< 上行平均往返时延rtt(ms) */
    int down_rtt;	                /**< 下行平均往返时延rtt(ms) */
    int tx_audio_packet_loss_rate;  /**< 本地上行音频实际丢包率。(%) */
    int tx_video_packet_loss_rate;  /**< 本地上行视频实际丢包率。(%) */
    int rx_audio_packet_loss_rate;  /**< 本地下行音频实际丢包率。(%) */
    int rx_video_packet_loss_rate;  /**< 本地下行视频实际丢包率。(%) */
};

#endif // BASE_TYPE_DEFINES_H
