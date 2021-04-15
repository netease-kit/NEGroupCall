//
//  NETSShowStatusActionSheet.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSShowStatusActionSheet.h"
#import "TopmostView.h"
#import "UIView+NTES.h"
#import <NERtcSDK/NERtcSDK.h>

@interface NETSShowStatusActionSheet () <NERtcEngineMediaStatsObserver>

/// 展示数据控件
@property (nonatomic, strong)   UILabel *label;

@property (nonatomic, assign)   uint32_t    cpuAppUsage;
@property (nonatomic, assign)   uint32_t    cpuTotalUsage;
@property (nonatomic, assign)   int64_t     audioSentBitrate;
@property (nonatomic, assign)   int64_t     audioRecvBitrate;
@property (nonatomic, assign)   int64_t     videoSentFrameRate;
@property (nonatomic, assign)   int64_t     videoRecvBitrate;
@property (nonatomic, assign)   int32_t     encodedFrameWidth;
@property (nonatomic, assign)   int32_t     encodedFrameHeight;
@property (nonatomic, assign)   int32_t     encoderOutputFrameRate;
@property (nonatomic, assign)   uint64_t    upRtt;
@property (nonatomic, assign)   uint32_t    txVideoPacketLossRate;
@property (nonatomic, assign)   uint32_t    rxVideoPacketLossRate;

@end

@implementation NETSShowStatusActionSheet

+ (void)show
{
    CGRect frame = [UIScreen mainScreen].bounds;
    NETSShowStatusActionSheet *sheet = [[NETSShowStatusActionSheet alloc] initWithFrame:frame title:@"实时数据"];
    sheet.resetBtn.hidden = YES;
    [[NERtcEngine sharedEngine] addEngineMediaStatsObserver:sheet];
    
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    
    /// 暂存顶层视图交互设置
    sheet.topUserInteractionEnabled = topmostView.userInteractionEnabled;
    
    topmostView.userInteractionEnabled = YES;
    [topmostView addSubview:sheet];
}

- (void)dealloc
{
    [[NERtcEngine sharedEngine] removeEngineMediaStatsObserver:self];
}

/// 更新状态信息
- (void)updateStatus
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *res = [NSString stringWithFormat:@"%dx%d %dfps\nLastmile Delay: %llums\nVideo Send/Recv: %lldkbps/%lldkbps\nAudio Send/Recv: %lldkbps/%lldkbps\nCPU: App/Total %d%%/%d%%\nSend/Recv Loss: %d%%/%d%%", self->_encodedFrameWidth, self->_encodedFrameHeight, self->_encoderOutputFrameRate, self->_upRtt, self->_audioSentBitrate, self->_audioRecvBitrate, self->_videoSentFrameRate, self->_videoRecvBitrate, self->_cpuAppUsage, self->_cpuTotalUsage, self->_txVideoPacketLossRate, self->_rxVideoPacketLossRate];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.maximumLineHeight = 18;
        style.minimumLineHeight = 18;
        NSDictionary *attr = @{
            NSParagraphStyleAttributeName: style,
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: HEXCOLOR(0x333333)
        };
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:res attributes:attr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_label.attributedText = attrStr;
        });
    });
}

#pragma mark - override method

- (void)setupSubViews
{
    [self.content addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topLine.mas_bottom).offset(12);
        make.left.equalTo(self.content).offset(20);
        make.right.equalTo(self.content).offset(-20);
        make.height.mas_equalTo(126);
        make.bottom.equalTo(self.content).offset(kIsFullScreen ? -44 : -10);
    }];
}

#pragma mark - NERtcEngineMediaStatsObserver

- (void)onRtcStats:(NERtcStats *)stat
{
    _cpuAppUsage = stat.cpuAppUsage;
    _cpuTotalUsage = stat.cpuTotalUsage;
    _upRtt = stat.upRtt;
    _txVideoPacketLossRate = stat.txVideoPacketLossRate;
    _rxVideoPacketLossRate = stat.rxVideoPacketLossRate;
    
    [self updateStatus];
}

- (void)onLocalAudioStat:(NERtcAudioSendStats *)stat
{
    _audioSentBitrate = stat.sentBitrate;
    
    [self updateStatus];
}

- (void)onRemoteAudioStats:(NSArray<NERtcAudioRecvStats*> *)stats
{
    NERtcAudioRecvStats *stat = stats.lastObject;
    _audioRecvBitrate = stat.receivedBitrate;
    
    [self updateStatus];
}

-(void)onLocalVideoStat:(NERtcVideoSendStats *)stat
{
    _videoSentFrameRate = stat.sentFrameRate;
    _encodedFrameWidth = stat.encodedFrameWidth;
    _encodedFrameHeight = stat.encodedFrameHeight;
    _encoderOutputFrameRate = stat.encoderOutputFrameRate;
    
    [self updateStatus];
}

- (void)onRemoteVideoStats:(NSArray<NERtcVideoRecvStats*> *)stats
{
    NERtcVideoRecvStats *stat = stats.lastObject;
    _videoRecvBitrate = stat.receivedBitrate;
    
    [self updateStatus];
}

#pragma mark - lazy load

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 0;
    }
    return _label;
}

@end
