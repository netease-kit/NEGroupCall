//
//  NEMultiCallSetupViewController.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/3/11.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEMultiCallSetupViewController.h"
#import "NEChannelSetupCell.h"
#import "NEChannelSetupModel.h"
#import "NEPickerView.h"
#import "NEChannelSetupService.h"

typedef NS_ENUM(NSUInteger, NEScenarioType) {
    NEScenarioTypeVoice = 1, //语音
    NEScenarioTypeMusic//音乐
};

@interface NEMultiCallSetupViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NEPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *resolutionRatioArray;
@property (nonatomic, strong) NSArray *frameRateArray;
@property (nonatomic, strong) NSArray *videoDataArray;
@property (nonatomic, strong) NSArray *audioDataArray;
@property (nonatomic, strong) NSArray *musicArray;
@property (nonatomic, strong) NSArray *voiceArray;
@property(nonatomic, assign) NEScenarioType scenarioType;
@end

@implementation NEMultiCallSetupViewController

- (void)ne_initializeConfig {
    self.title = @"设置";
    self.view.backgroundColor = UIColor.whiteColor;
    self.resolutionRatioArray = @[@"160*90",@"320*180", @"640*360", @"1280*720", @"1920*1080"];
    self.frameRateArray = @[@"7",@"10",@"15",@"24",@"30"];
    self.musicArray = @[@"清晰",@"高清",@"极致"];
    self.voiceArray = @[@"一般",@"清晰",@"高清"];
    self.scenarioType = NEScenarioTypeMusic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ne_getNewData];
    [self ne_initializeConfig];
    [self ne_addSubViews];
}

- (void)ne_getNewData {
    
    self.videoDataArray = [NEChannelSetupModel getData:@"videoSetting.json"];
    self.audioDataArray = [NEChannelSetupModel getData:@"audioSetting.json"];
    self.dataArray = [[NSMutableArray alloc]initWithArray:self.videoDataArray];
    [self.tableView reloadData];
}


- (void)ne_addSubViews {
    [self.view addSubview:self.segment];
    [self.view addSubview:self.tableView];

    [self.segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(32);

    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segment.mas_bottom).offset(20);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
}

- (CGSize)preferredContentSize {
    return CGSizeMake(kScreenWidth, 180);
}


#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NEChannelSetupCell *setupCell = [NEChannelSetupCell settingCellForTableView:self.tableView cellStyle:UITableViewCellStyleDefault];
    __weak __typeof(self)weakSelf = self;
    setupCell.musicSubject = [RACSubject subject];
    [setupCell.musicSubject subscribeNext:^(id  _Nullable x) {
        self.scenarioType = NEScenarioTypeMusic;
        weakSelf.dataArray =  [[NSMutableArray alloc]initWithArray:[NEChannelSetupModel handleSoundQuality:@"高清" orginArray:weakSelf.dataArray]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    setupCell.voiceSubject = [RACSubject subject];
    [setupCell.voiceSubject subscribeNext:^(id  _Nullable x) {
        self.scenarioType = NEScenarioTypeVoice;
        weakSelf.dataArray =  [[NSMutableArray alloc]initWithArray:[NEChannelSetupModel handleSoundQuality:@"清晰" orginArray:weakSelf.dataArray]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    NEChannelSetupModel *model = self.dataArray[indexPath.row];
    setupCell.selectionStyle = UITableViewCellSelectionStyleNone;
    setupCell.dataModel = model;
    return setupCell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  44;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NEChannelSetupModel *model = self.dataArray[indexPath.row];
    if (model.performSelector && model.performSelector.length >0) {
        SuppressPerformSelectorLeakWarning(
            SEL sel = NSSelectorFromString(model.performSelector);
            if ([self respondsToSelector:sel]) {
                [self performSelector:sel withObject:indexPath];
            }
        );
    }

}

#pragma mark - private method
- (void)segmentClickAction:(UISegmentedControl *)segMent {
    if (segMent.selectedSegmentIndex == 0) {
        self.dataArray = [[NSMutableArray alloc]initWithArray:self.videoDataArray];
        [self.tableView reloadData];
    }else {
        self.dataArray = [[NSMutableArray alloc]initWithArray:self.audioDataArray];
        [self.tableView reloadData];
    }
}

//设置分辨率
- (void)setupResolutionRatio:(NSIndexPath *)indexPath {
    
    self.pickerView.dataSource = self.resolutionRatioArray;
    self.pickerView.selectDefault = 3;
    __weak __typeof(self)weakSelf = self;
    self.pickerView.selectValue = ^(NSInteger value) {
        NSString *selectValue = weakSelf.resolutionRatioArray[value];
        YXAlogDebug(@"分辨率设置为:%@",selectValue);
        [NEChannelSetupService sharedService].resolutionRatio = selectValue;
        weakSelf.videoDataArray =  [NEChannelSetupModel handleResolutionRatio:selectValue orginArray:weakSelf.videoDataArray];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self.pickerView show];
}

//设置帧率
- (void)setupFrameRate:(NSIndexPath *)indexPath {
    self.pickerView.dataSource = self.frameRateArray;
    self.pickerView.selectDefault = 4;
    __weak __typeof(self)weakSelf = self;
    self.pickerView.selectValue = ^(NSInteger value) {
        NSString *selectValue = weakSelf.frameRateArray[value];
        YXAlogDebug(@"帧率设置为:%@",selectValue);
        [NEChannelSetupService sharedService].frameRate = selectValue;
        weakSelf.videoDataArray =  [NEChannelSetupModel handleFrameRate:selectValue orginArray:weakSelf.videoDataArray];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self.pickerView show];
}

//设置音质
- (void)setupSoundQuality:(NSIndexPath *)indexPath {
    
    self.pickerView.dataSource = self.scenarioType == NEScenarioTypeMusic ? self.musicArray : self.voiceArray;
    self.pickerView.selectDefault = 1;
    __weak __typeof(self)weakSelf = self;
    self.pickerView.selectValue = ^(NSInteger value) {
        NSString *selectValue = weakSelf.pickerView.dataSource[value];
        YXAlogDebug(@"音质设置为:%@",selectValue);
        [NEChannelSetupService sharedService].soundQuality = selectValue;
        weakSelf.audioDataArray =  [NEChannelSetupModel handleSoundQuality:selectValue orginArray:weakSelf.audioDataArray];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self.pickerView show];
}

#pragma mark - lazyMethod
- (UISegmentedControl *)segment {
    if (!_segment) {
        _segment = [[UISegmentedControl alloc]initWithItems:@[@"视频",@"音频"]];
        _segment.selectedSegmentIndex = 0;
        [_segment addTarget:self action:@selector(segmentClickAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _segment;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 108) style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 15);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.tableFooterView = [[UIView alloc]init];
    }
    return _tableView;
}

- (NEPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[NEPickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    }
    return _pickerView;
}


@end
