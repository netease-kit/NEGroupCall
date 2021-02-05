//
//  NETSBaseView.m
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/30.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSBaseView.h"

@interface NETSBaseView()

@property (nonatomic, readwrite, strong) id model;

@end

@implementation NETSBaseView

- (instancetype)initWithFrame:(CGRect)frame model:(id<NETSBaseViewProtocol>)model {
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        self.backgroundColor = [UIColor whiteColor];
        [self nets_setupViews];
        [self nets_bindViewModel];
    }
    return self;
}


- (instancetype)init {
    return [self initWithFrame:CGRectZero model:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame model:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithFrame:CGRectZero model:nil];
}

- (void)nets_setupViews {
    
}

- (void)nets_bindViewModel {
    
}

@end
