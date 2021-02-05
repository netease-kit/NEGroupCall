//
//  NETSAudioMixingActionSheet.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSAudioMixingActionSheet.h"
#import "TopmostView.h"
#import "NETSAudioMixingItem.h"
#import <NERtcSDK/NERtcSDK.h>
#import "NETSLiveConfig.h"

@interface NETSAudioMixingActionSheet () <NETSAudioMixingItemdelegate>

/// 混音设置
@property (nonatomic, strong)   NETSAudioMixingItem *mixingItem;
/// 音效设置
@property (nonatomic, strong)   NETSAudioMixingItem *effectItem;
/// 混音配置集合
@property (nonatomic, strong)   NSArray <NERtcCreateAudioMixingOption *>   *mixOpts;
/// 混音索引
@property (nonatomic, assign)   NSInteger           index;
/// 音效配置集合
@property (nonatomic, strong)   NSArray <NERtcCreateAudioEffectOption *>   *effectOpts;
/// 音效索引
@property (nonatomic, assign)   NSInteger           indexOfEffect;

@end

@implementation NETSAudioMixingActionSheet

+ (void)show
{
    CGRect frame = [UIScreen mainScreen].bounds;
    NETSAudioMixingActionSheet *sheet = [[NETSAudioMixingActionSheet alloc] initWithFrame:frame title:@"伴音"];
    sheet.resetBtn.hidden = YES;
    
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    
    /// 暂存顶层视图交互设置
    sheet.topUserInteractionEnabled = topmostView.userInteractionEnabled;
    
    topmostView.userInteractionEnabled = YES;
    [topmostView addSubview:sheet];
}

- (void)setupSubViews
{
    [self.content addSubview:self.mixingItem];
    [self.content addSubview:self.effectItem];
    
    [self.mixingItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topLine.mas_bottom).offset(10);
        make.left.right.equalTo(self.content);
        make.height.mas_equalTo(102);
    }];
    [self.effectItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mixingItem.mas_bottom);
        make.left.right.height.equalTo(self.mixingItem);
        make.bottom.equalTo(self.content).offset(kIsFullScreen ? -42 : -8);
    }];
}

#pragma mark - 操作混音相关

/// 停止混音
- (void)stopMixing
{
    [[NERtcEngine sharedEngine] stopAudioMixing];
}

/// 播放指定索引的混音
- (void)playMixingAtIndex:(NSUInteger)targetIdx
{
    if (self.mixOpts.count == 0 || targetIdx >= self.mixOpts.count) {
        return;
    }
    _index = targetIdx;
    
    [[NERtcEngine sharedEngine] stopAudioMixing];
    NERtcCreateAudioMixingOption *opt = self.mixOpts[_index];
    int result = [[NERtcEngine sharedEngine] startAudioMixingWithOption:opt];
    if (result != 0) {
        NETSLog(@"play audio mix failed ...");
    }
}

/// 设置混音音量
- (void)changeMixingVolumn:(CGFloat)value
{
    [[NERtcEngine sharedEngine] setAudioMixingSendVolume:value];
    [[NERtcEngine sharedEngine] setAudioMixingPlaybackVolume:value];
    
    [NETSLiveConfig shared].mixVolume = value;
}

#pragma mark - 操作音效相关

/// 停止播放音效
- (void)stopEffectWithIndex:(uint32_t)index
{
    [[NERtcEngine sharedEngine] stopEffectWitdId:index];
}

/// 播放指定索引音效
- (void)playEffectAtIndex:(NSUInteger)targetIdx
{
    if (self.effectOpts.count == 0 || targetIdx >= self.effectOpts.count) {
        return;
    }
    
    _indexOfEffect = targetIdx;
    NERtcCreateAudioEffectOption *opt = self.effectOpts[_indexOfEffect];
    opt.playbackVolume = self.effectItem.sliderValue;
    [[NERtcEngine sharedEngine] stopAllEffects];
    uint32_t eid = (uint32_t)_indexOfEffect;
    int result = [[NERtcEngine sharedEngine] playEffectWitdId:eid effectOption:opt];
    if (result != 0) {
        NETSLog(@"play audio effect failed ...");
    }
}

/// 修改音效音量
- (void)changeEffectVolumn:(CGFloat)value
{
    uint32_t eid = (uint32_t)_indexOfEffect;
    [[NERtcEngine sharedEngine] setEffectSendVolumeWithId:eid volume:value];
    [[NERtcEngine sharedEngine] setEffectPlaybackVolumeWithId:eid volume:value];
    
    [NETSLiveConfig shared].effectVolume = value;
}

#pragma mark - NETSAudioMixingItemdelegate

- (void)didClickItem:(NETSAudioMixingItem *)item selected:(BOOL)selected index:(NSInteger)index
{
    if (item == self.mixingItem) {
        if (selected) {
            [self playMixingAtIndex:index];
            [NETSLiveConfig shared].mixingIdx = index;
        } else {
            [self stopMixing];
            [NETSLiveConfig shared].mixingIdx = -1;
        }
    } else {
        if (selected) {
            [self playEffectAtIndex:index];
            [NETSLiveConfig shared].effectIdx = index;
        } else {
            [self stopEffectWithIndex:(uint32_t)index];
            [NETSLiveConfig shared].effectIdx = -1;
        }
    }
}

- (void)didChangedItem:(NETSAudioMixingItem *)item sliderValue:(float)sliderValue
{
    if (item == self.mixingItem) {
        [self changeMixingVolumn:sliderValue];
    } else {
        [self changeEffectVolumn:sliderValue];
    }
}

#pragma mark - lazy load

- (NETSAudioMixingItem *)mixingItem
{
    if (!_mixingItem) {
        _mixingItem = [[NETSAudioMixingItem alloc] initWithTitle:@"背景音乐" btn1Tit:@"音乐1" btn2Tit:@"音乐2" sliderMinVal:0 sliderMaxVal:100 delegate:self];
        _mixingItem.sliderValue = [NETSLiveConfig shared].mixVolume;
        [_mixingItem setSelectedIndex:[NETSLiveConfig shared].mixingIdx];
    }
    return _mixingItem;
}

- (NETSAudioMixingItem *)effectItem
{
    if (!_effectItem) {
        _effectItem = [[NETSAudioMixingItem alloc] initWithTitle:@"音效" btn1Tit:@"音效1" btn2Tit:@"音效2" sliderMinVal:0 sliderMaxVal:100 delegate:self];
        _effectItem.sliderValue = [NETSLiveConfig shared].effectVolume;
        [_effectItem setSelectedIndex:[NETSLiveConfig shared].effectIdx];
    }
    return _effectItem;
}

- (NSArray <NERtcCreateAudioMixingOption *> *)mixOpts
{
    if (!_mixOpts) {
        NSMutableArray *temp = [NSMutableArray array];
        for (int i = 0; i < 2; i++) {
            NSString *name = [NSString stringWithFormat:@"%d", i + 1];
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"mp3"];
            if (path) {
                NERtcCreateAudioMixingOption *opt = [[NERtcCreateAudioMixingOption alloc] init];
                opt.path = path;
                opt.playbackVolume = self.mixingItem.sliderValue;
                opt.sendVolume = self.mixingItem.sliderValue;
                opt.loopCount = 0;
                [temp addObject:opt];
            }
        }
        _mixOpts = [temp copy];
    }
    return _mixOpts;
}

- (NSArray <NERtcCreateAudioEffectOption *> *)effectOpts
{
    if (!_effectOpts) {
        NSMutableArray *temp = [NSMutableArray array];
        for (int i = 0; i < 2; i++) {
            NSString *name = [NSString stringWithFormat:@"audio_effect_%d", i];
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"wav"];
            if (path) {
                NERtcCreateAudioEffectOption *opt = [[NERtcCreateAudioEffectOption alloc] init];
                opt.path = path;
                opt.playbackVolume = self.effectItem.sliderValue;
                opt.sendVolume = self.effectItem.sliderValue;
                opt.loopCount = 1;
                [temp addObject:opt];
            }
        }
        _effectOpts = [temp copy];
    }
    return _effectOpts;
}

@end
