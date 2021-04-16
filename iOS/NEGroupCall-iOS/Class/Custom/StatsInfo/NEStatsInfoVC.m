//
//  NEStatsInfoVC.m
//  NEGroupCall-iOS
//
//  Created by Long on 2021/3/31.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEStatsInfoVC.h"

@interface NEStatsInfoVC () 

@property (nonatomic, strong)   UILabel *info;

@end

@implementation NEStatsInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"实时数据";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.info];
    self.info.frame = CGRectMake(20, 20, self.view.width - 40, 132);
}

- (CGSize)preferredContentSize
{
    CGFloat height = 180 + (kIsFullScreen ? 34 : 0);
    return CGSizeMake(kScreenWidth, height);
}

#pragma mark - NERtcEngineMediaStatsObserver

-(void)onRtcStats:(NERtcStats *)stat {
    
    YXAlogInfo(@"本地视频上行丢包率%d，本地视频下行丢包率%d===本地音频上行丢包率%d，本地音频下行丢包率%d",stat.txVideoPacketLossRate,stat.rxVideoPacketLossRate,stat.txAudioPacketLossRate,stat.rxAudioPacketLossRate);
    NSAttributedString *msg = [self _attrInfoWithFormat:@"网络延时: %llu ms\n视频发送/接收码率: %llu/%llu kbps\n音频发送/接收码率: %llu/%llu kbps\n本地上行/下行视频丢包率: %u/%u %%\n本地上行/下行音频丢包率: %u/%u %%\nCPU占用 总/App: %u/%u %%", stat.upRtt, stat.txVideoKBitRate, stat.rxVideoKBitRate, stat.txAudioKBitRate, stat.rxAudioKBitRate, stat.txVideoPacketLossRate,stat.rxVideoPacketLossRate, stat.txAudioPacketLossRate,stat.rxAudioPacketLossRate, stat.cpuTotalUsage, stat.cpuAppUsage];
    _info.attributedText = msg;
}

- (NSAttributedString *)_attrInfoWithFormat:(NSString *)format, ...
{
    va_list ap;
    va_start(ap, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:ap] ?: @"";
    va_end(ap);
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.maximumLineHeight = 22;
    style.minimumLineHeight = 22;
    return [[NSAttributedString alloc] initWithString:msg attributes:@{NSParagraphStyleAttributeName: style}];
}

#pragma mark lazy load

- (UILabel *)info
{
    if (!_info) {
        _info = [[UILabel alloc] init];
        _info.font = [UIFont systemFontOfSize:14];
        _info.textColor = HEXCOLOR(0x000000);
        _info.numberOfLines = 0;
        
        NSAttributedString *msg = [self _attrInfoWithFormat:@"网络延时: - ms\n视频发送/接收码率: -/- kbps\n音频发送/接收码率: -/- kbps\n本地上行/下行视频丢包率: -/- %%\n本地上行/下行音频丢包率: -/- %%\nCPU占用 总/App: -/- %%"];
        _info.attributedText = msg;
    }
    return _info;
}

@end
