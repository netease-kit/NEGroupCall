//
//  NEEvaluateListView.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEEvaluateListView.h"
@interface NEEvaluateListView ()
@property(strong,nonatomic)NSArray *titleArray;
//@property(strong,nonatomic)UIStackView *stackView;

@end
@implementation NEEvaluateListView
- (instancetype)initWithTitleArray:(NSArray *)titleArray
{
    self = [super init];
    if (self) {
        self.titleArray = titleArray;
        [self initUI];
    }
    return self;
}
- (void)initUI {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.titleArray.count; i ++) {
        NSString *name = self.titleArray[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:name forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"duoxuan"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"duoxuanSelect"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

        button.tag = i + 101;
        [array addObject:button];
    }
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:array];
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.axis = UILayoutConstraintAxisVertical;
    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 20, 0, 20));
    }];
}
- (void)buttonClick:(UIButton *)button {
    button.selected = !button.selected;
//    NSNumber *object = @(button.tag);
    if (self.didSelectedIndex) {
        self.didSelectedIndex(button.tag - 101, button.selected);
    }
//    if (button.selected) {
//        if (![self.selectTypes containsObject:object]) {
//            [self.selectTypes addObject:object];
//        }
//    }else {
//        if ([self.selectTypes containsObject:object]) {
//            [self.selectTypes removeObject:object];
//        }
//    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
