//
//  NETSBaseView.m
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/30.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEBaseView.h"

@interface NEBaseView()

@property (nonatomic, readwrite, strong) id model;

@end

@implementation NEBaseView

- (instancetype)initWithFrame:(CGRect)frame model:(id<NEBaseViewProtocol>)model {
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        self.backgroundColor = [UIColor whiteColor];
        [self ne_setupViews];
        [self ne_bindViewModel];
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

- (void)ne_setupViews {
    
}

- (void)ne_bindViewModel {
    
}

@end
