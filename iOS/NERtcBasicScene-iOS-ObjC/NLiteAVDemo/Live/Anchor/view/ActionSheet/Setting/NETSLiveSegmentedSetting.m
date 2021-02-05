//
//  NETSLiveSegmentedSetting.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/16.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveSegmentedSetting.h"
#import "NETSSettingSegmented.h"
#import "NETSLiveSegmentedSettingModel.h"

@implementation NETSLiveSegmentedSetting

- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items
{
    self = [super init];
    if (self) {
        _items = items;
        [self addSubview:self.titleLab];
        [self addSubview:self.segment];
        
        self.titleLab.text = title;
    }
    return self;
}

- (void)layoutSubviews
{
    self.titleLab.frame = CGRectMake(20, 0, 60, self.frame.size.height);
    
    CGSize size = CGSizeMake(60, 32);
    self.segment.frame = CGRectMake(self.frame.size.width - 20 - size.width * [_items count],
                                    (self.frame.size.height - size.height) / 2.0,
                                    size.width * [_items count],
                                    size.height);
}

/// 分段控件选择事件
- (void)didSegmentValueChanged:(NETSSettingSegmented *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changedLiveSegmented:selectedIndex:selectedItem:)]) {
        NSInteger selectedIndex = sender.selectedSegmentIndex;
        NETSLiveSegmentedSettingModel *selectedItem = nil;
        if (selectedIndex < [_items count]) {
            selectedItem = _items[selectedIndex];
            _selectedValue = selectedItem.value;
        }
        [self.delegate changedLiveSegmented:self selectedIndex:selectedIndex selectedItem:selectedItem];
    }
}

- (void)setSelectedValue:(NSInteger)selectedValue
{
    if (_selectedValue == selectedValue) {
        return;
    }
    for (int i = 0; i < [_items count]; i++) {
        NETSLiveSegmentedSettingModel *item = _items[i];
        if (selectedValue == item.value) {
            _selectedValue = selectedValue;
            _segment.selectedSegmentIndex = i;
            return;
        }
    }
}

#pragma mark - lazy load

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:14];
        _titleLab.textColor = HEXCOLOR(0x222222);
    }
    return _titleLab;
}

- (NETSSettingSegmented *)segment
{
    if (!_segment) {
        NSMutableArray *displays = [NSMutableArray arrayWithCapacity:[_items count]];
        for (NETSLiveSegmentedSettingModel *obj in _items) {
            [displays addObject:obj.display];
        }
        _segment = [[NETSSettingSegmented alloc] initWithItems:[displays copy]];
        _segment.selectedSegmentIndex = 0;
        [_segment addTarget:self action:@selector(didSegmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _segment;
}

@end
