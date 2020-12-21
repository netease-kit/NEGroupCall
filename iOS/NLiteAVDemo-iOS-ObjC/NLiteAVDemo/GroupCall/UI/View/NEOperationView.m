//
//  NEOperationView.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEOperationView.h"

@implementation NEOperationView
- (instancetype)initWithImages:(NSArray <NSString *>*)images selectedImages:(NSArray <NSString *>*)selectedImages;
{
    self = [super init];
    if (self) {
        [self initUIWithImages:images selectedImages:selectedImages];
    }
    return self;
}
- (void)initUIWithImages:(NSArray <NSString *>*)images selectedImages:(NSArray <NSString *>*)selectedImages {
    self.backgroundColor = [UIColor colorWithRed:39/255.0 green:48/255.0 blue:48/255.0 alpha:1.0];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < images.count; i ++) {
        NSString *imageName = images[i];
        NSString *selectedImageName = selectedImages[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 10;
        [array addObject:button];
    }
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:array];
    stackView.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 30, 0, 30));
    }];
}
- (void)buttonEvent:(UIButton *)button {
    button.selected = !button.selected;
    if (self.delegate) {
        [self.delegate didSelectIndex:button.tag - 10 button:button];
    }
}
@end
