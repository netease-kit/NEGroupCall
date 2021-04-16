//
//  NEPickerView.h
//  NEGroupCall-iOS
//
//  Created by vvj on 2021/3/24.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEPickerView.h"

@interface NEPickerView()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) UIButton *confirmButton;
@property (nonatomic,strong) UIView *midLine;
@property (nonatomic,strong) UIPickerView *pickerView;
@property (nonatomic,assign) NSInteger selectRow;
@property (nonatomic,strong) UIView *selectTopView;
@property (nonatomic,strong) UIView *selectBottomView;

@end
@implementation NEPickerView

- (void)ne_setupViews {
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.34];
    [self addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.cancelButton];
    [self.backgroundView addSubview:self.confirmButton];
    [self.backgroundView addSubview:self.midLine];
    [self.backgroundView addSubview:self.pickerView];
}


- (void)show {
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
    //动画出现
    CGRect frame = self.backgroundView.frame;
    if (frame.origin.y == kScreenHeight) {
        frame.origin.y -= self.backgroundView.height;
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundView.frame = frame;
        }];
    }
    [self setPickerViewSelectColor];
}

-(void)setDataSource:(NSArray *)dataSource{
    _dataSource = dataSource;
    [self.pickerView reloadAllComponents];
}

-(void)setSelectDefault:(NSInteger)selectDefault{
    _selectDefault = selectDefault;
    [self.pickerView selectRow:selectDefault inComponent:0 animated:NO];
    self.selectRow = selectDefault;
    [self.pickerView reloadAllComponents];
}

- (void)cancelButtonClick:(UIButton *)sender {
    [self removeSelfFromSupView];

}

- (void)confirmButtonClick:(UIButton *)sender {
    self.selectValue(self.selectRow);
    [self removeSelfFromSupView];
}

- (void)removeSelfFromSupView
{
    CGRect selfFrame = self.backgroundView.frame;
    selfFrame.origin.y += self.backgroundView.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.frame = selfFrame;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self removeSelfFromSupView];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataSource.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//    [self setPickerViewSelectColor];
    UILabel *pickerLabel = (UILabel *)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.font = [UIFont systemFontOfSize:18];
        pickerLabel.text = [NSString stringWithFormat:@"%@",self.dataSource[row]];
        if (row == self.selectRow) {
            pickerLabel.textColor = HEXCOLOR(0x333333);
        }else{
            pickerLabel.textColor = HEXCOLOR(0x999999);
        }
    }
    return pickerLabel;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.selectDefault = row;
    self.selectRow = row;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight - 236 -  [NETSDeviceSIzeInfo get_iPhoneBottomSafeDistance], kScreenWidth, 236 + [NETSDeviceSIzeInfo get_iPhoneBottomSafeDistance])];
        _backgroundView.backgroundColor = [UIColor whiteColor];
    }
    return _backgroundView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [NETSViewFactory createBtnFrame:CGRectMake(0, 0, 70, 41) title:@"取消" bgImage:nil selectBgImage:nil image:@"" target:self action:@selector(cancelButtonClick:)];
        [_cancelButton setTitleColor:HEXCOLOR(0x999999) forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [NETSViewFactory createBtnFrame:CGRectMake(kScreenWidth - 76, 0, 76, 41) title:@"确定" bgImage:nil selectBgImage:nil image:@"" target:self action:@selector(confirmButtonClick:)];
        [_confirmButton setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _confirmButton;
}

- (UIView *)midLine {
    if (!_midLine) {
        _midLine = [[UIView alloc]initWithFrame:CGRectMake(0, 41, kScreenWidth, 1)];
        _midLine.backgroundColor = HEXCOLOR(0xe5e5e5);
    }
    return _midLine;
}

- (UIView *)selectTopView {
    if (!_selectTopView) {
        _selectTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
        _selectTopView.backgroundColor = HEXCOLOR(0xe5e5e5);
    }
    return _selectTopView;
}

- (UIView *)selectBottomView {
    if (!_selectBottomView) {
        _selectBottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 41, kScreenWidth, 0.5)];
        _selectBottomView.backgroundColor = HEXCOLOR(0xe5e5e5);
    }
    return _selectBottomView;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 42, kScreenWidth, 195)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

- (void)setPickerViewSelectColor {
    for(UIView *singleLine in self.pickerView.subviews){
        if (singleLine.frame.size.height < 1){
            singleLine.backgroundColor = [UIColor clearColor];
        }
    }
    NSArray *subviews = self.pickerView.subviews;
    if (!(subviews.count > 0)) {
        return;
    }
    NSArray *coloms = subviews.firstObject;
    if (coloms) {
        NSArray *subviewCache = [coloms valueForKey:@"subviewCache"];
        if (subviewCache.count > 0) {
            UIView *middleContainerView = [subviewCache.firstObject valueForKey:@"middleContainerView"];
            if (middleContainerView) {
                [middleContainerView addSubview:self.selectTopView];
                [middleContainerView addSubview:self.selectBottomView];
            }
        }
    }
}

@end
