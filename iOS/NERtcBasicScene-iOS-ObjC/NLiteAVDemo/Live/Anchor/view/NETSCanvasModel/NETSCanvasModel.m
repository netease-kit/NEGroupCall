//
//  NETSCanvasModel.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/15.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSCanvasModel.h"
#import <NERtcSDK/NERtcSDK.h>

@interface NETSCanvasModel ()

@property (nonatomic, strong) NERtcVideoCanvas *canvas;

@end

@implementation NETSCanvasModel

- (NERtcVideoCanvas *)setupCanvas
{
    //显示渲染视图，UI切换为通话渲染状态
    _renderContainer.hidden = NO;
    
    //SDK setup canvas
    self.canvas.container = _renderContainer;
    self.canvas.renderMode = kNERtcVideoRenderScaleCropFill;
    return self.canvas;
}

- (void)resetCanvas
{
    
    //隐藏渲染视图，UI切换为通话之前的状态
    _renderContainer.hidden = YES;
    
    //SDK内部会在渲染时在外部配置的渲染view上增加内部实际渲染view，因此需要在重置的时候清理一下
    [_renderContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - lazy load

- (NERtcVideoCanvas *)canvas
{
    if (!_canvas) {
        _canvas = [[NERtcVideoCanvas alloc] init];
    }
    return _canvas;
}

@end
