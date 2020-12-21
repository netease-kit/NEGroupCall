//
//  NETSFUManger.m
//  NLiteAVDemo
//
//  Created by Think on 2020/11/17.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSFUManger.h"
#import <libCNamaSDK/FURenderer.h>
#import "authpack.h"

static NETSFUManger *shareManager = NULL;

@interface NETSFUManger ()
{
    int items[NETSFUNamaHandleTotal];
}

/// 操作队列
@property (nonatomic, strong) dispatch_queue_t  asyncLoadQueue;
/// 选中的滤镜
@property (nonatomic, strong) NETSBeautyParam   *seletedFliter;
/// 滤镜参数
@property (nonatomic, strong, readwrite) NSArray<NETSBeautyParam *> *filters;
/// 美肤参数
@property (nonatomic, strong, readwrite) NSArray<NETSBeautyParam *> *skinParams;

@end

@implementation NETSFUManger

+ (NETSFUManger *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[NETSFUManger alloc] init];
    });
    
    return shareManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _asyncLoadQueue = dispatch_queue_create("com.faceLoadItem", DISPATCH_QUEUE_SERIAL);
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        [[FURenderer shareRenderer] setupWithData:nil dataSize:0 ardata:nil authPackage:&g_auth_package authSize:sizeof(g_auth_package) shouldCreateContext:YES];
        CFAbsoluteTime delay = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@"setup FU: ---%lf", delay);
        
        /* 美颜 */
        [self setupFilterData];
        [self setupSkinData];
    }
    return self;
}

/// 滤镜数据
- (void)setupFilterData
{
    NSArray *beautyFiltersDataSource = @[@"origin",@"ziran1",@"ziran2",@"ziran3",@"ziran4",@"ziran5",@"ziran6",@"ziran7",@"ziran8",
    @"zhiganhui1",@"zhiganhui2",@"zhiganhui3",@"zhiganhui4",@"zhiganhui5",@"zhiganhui6",@"zhiganhui7",@"zhiganhui8",
                                          @"mitao1",@"mitao2",@"mitao3",@"mitao4",@"mitao5",@"mitao6",@"mitao7",@"mitao8",
                                         @"bailiang1",@"bailiang2",@"bailiang3",@"bailiang4",@"bailiang5",@"bailiang6",@"bailiang7"
                                         ,@"fennen1",@"fennen2",@"fennen3",@"fennen5",@"fennen6",@"fennen7",@"fennen8",
                                         @"lengsediao1",@"lengsediao2",@"lengsediao3",@"lengsediao4",@"lengsediao7",@"lengsediao8",@"lengsediao11",
                                         @"nuansediao1",@"nuansediao2",
                                         @"gexing1",@"gexing2",@"gexing3",@"gexing4",@"gexing5",@"gexing7",@"gexing10",@"gexing11",
                                         @"xiaoqingxin1",@"xiaoqingxin3",@"xiaoqingxin4",@"xiaoqingxin6",
                                         @"heibai1",@"heibai2",@"heibai3",@"heibai4"];
    
    NSDictionary *filtersCHName = @{@"origin":@"原图",@"bailiang1":@"白亮1",@"bailiang2":@"白亮2",@"bailiang3":@"白亮3",@"bailiang4":@"白亮4",@"bailiang5":@"白亮5",@"bailiang6":@"白亮6",@"bailiang7":@"白亮7"
                                    ,@"fennen1":@"粉嫩1",@"fennen2":@"粉嫩2",@"fennen3":@"粉嫩3",@"fennen4":@"粉嫩4",@"fennen5":@"粉嫩5",@"fennen6":@"粉嫩6",@"fennen7":@"粉嫩7",@"fennen8":@"粉嫩8",
                                    @"gexing1":@"个性1",@"gexing2":@"个性2",@"gexing3":@"个性3",@"gexing4":@"个性4",@"gexing5":@"个性5",@"gexing6":@"个性6",@"gexing7":@"个性7",@"gexing8":@"个性8",@"gexing9":@"个性9",@"gexing10":@"个性10",@"gexing11":@"个性11",
                                    @"heibai1":@"黑白1",@"heibai2":@"黑白2",@"heibai3":@"黑白3",@"heibai4":@"黑白4",@"heibai5":@"黑白5",
                                    @"lengsediao1":@"冷色调1",@"lengsediao2":@"冷色调2",@"lengsediao3":@"冷色调3",@"lengsediao4":@"冷色调4",@"lengsediao5":@"冷色调5",@"lengsediao6":@"冷色调6",@"lengsediao7":@"冷色调7",@"lengsediao8":@"冷色调8",@"lengsediao9":@"冷色调9",@"lengsediao10":@"冷色调10",@"lengsediao11":@"冷色调11",
                                    @"nuansediao1":@"暖色调1",@"nuansediao2":@"暖色调2",@"nuansediao3":@"暖色调3",@"xiaoqingxin1":@"小清新1",@"xiaoqingxin2":@"小清新2",@"xiaoqingxin3":@"小清新3",@"xiaoqingxin4":@"小清新4",@"xiaoqingxin5":@"小清新5",@"xiaoqingxin6":@"小清新6",
                                    @"ziran1":@"自然1",@"ziran2":@"自然2",@"ziran3":@"自然3",@"ziran4":@"自然4",@"ziran5":@"自然5",@"ziran6":@"自然6",@"ziran7":@"自然7",@"ziran8":@"自然8",
                                    @"mitao1":@"蜜桃1",@"mitao2":@"蜜桃2",@"mitao3":@"蜜桃3",@"mitao4":@"蜜桃4",@"mitao5":@"蜜桃5",@"mitao6":@"蜜桃6",@"mitao7":@"蜜桃7",@"mitao8":@"蜜桃8",
                                    @"zhiganhui1":@"质感灰1",@"zhiganhui2":@"质感灰2",@"zhiganhui3":@"质感灰3",@"zhiganhui4":@"质感灰4",@"zhiganhui5":@"质感灰5",@"zhiganhui6":@"质感灰6",@"zhiganhui7":@"质感灰7",@"zhiganhui8":@"质感灰8"
    };
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSString *str in beautyFiltersDataSource) {
        NETSBeautyParam *modle = [[NETSBeautyParam alloc] init];
        modle.mParam = str;
        modle.mTitle = [filtersCHName valueForKey:str];
        modle.mValue = 0.4;

        [temp addObject:modle];
    }
    _filters = [temp copy];
    
    self.seletedFliter = _filters[2];
}

/// 美颜数据
- (void)setupSkinData
{
    NSArray *prams = @[@"color_level", @"blur_level", @"cheek_thinning", @"eye_enlarging"];
    NSDictionary *titelDic = @{@"color_level":@"美白", @"blur_level":@"磨皮", @"cheek_thinning":@"瘦脸", @"eye_enlarging":@"大眼"};
    NSDictionary *defaultValueDic = @{@"color_level":@(0.3), @"blur_level":@(0.7), @"cheek_thinning":@(0), @"eye_enlarging":@(0.4)};
    NSDictionary *minValArr = @{@"color_level":@(0.0), @"blur_level":@(0.0), @"cheek_thinning":@(0.0), @"eye_enlarging":@(0.0)};
    NSDictionary *maxValArr = @{@"color_level":@(2.0), @"blur_level":@(6.0), @"cheek_thinning":@(1.0), @"eye_enlarging":@(1.0)};
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSString *str in prams) {
        NETSBeautyParam *modle = [[NETSBeautyParam alloc] init];
        modle.mParam = str;
        modle.mTitle = [titelDic valueForKey:str];
        modle.mValue = [[defaultValueDic valueForKey:str] floatValue];
        modle.minVal = [[minValArr valueForKey:str] floatValue];
        modle.maxVal = [[maxValArr valueForKey:str] floatValue];
        modle.defaultValue = modle.mValue;
        [temp addObject:modle];
    }
    _skinParams = [temp copy];
}

- (void)loadFilter
{
    dispatch_async(_asyncLoadQueue, ^{
        if (self->items[NETSFUNamaHandleTypeBeauty] == 0) {

            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

            NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification.bundle" ofType:nil];
            self->items[NETSFUNamaHandleTypeBeauty] = [FURenderer itemWithContentsOfFile:path];

            /* 默认精细磨皮 */
            [FURenderer itemSetParam:self->items[NETSFUNamaHandleTypeBeauty] withName:@"heavy_blur" value:@(0)];
            [FURenderer itemSetParam:self->items[NETSFUNamaHandleTypeBeauty] withName:@"blur_type" value:@(2)];
            /* 默认自定义脸型 */
            [FURenderer itemSetParam:self->items[NETSFUNamaHandleTypeBeauty] withName:@"face_shape" value:@(4)];
            
            CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);

            NSLog(@"加载美颜道具耗时: %f ms", endTime * 1000.0);
     
        }
    });
}

- (void)setBeautyDefaultParameters:(NETSFUBeautyModuleType)type
{
    if((type & FUBeautyModuleTypeSkin) == FUBeautyModuleTypeSkin) {
        for (NETSBeautyParam *modle in _skinParams) {
            modle.mValue = modle.defaultValue;
            if ([modle.mParam isEqualToString:@"blur_level"]) {
                [FURenderer itemSetParam:items[NETSFUNamaHandleTypeBeauty] withName:modle.mParam value:@(modle.mValue * 6)];
            } else {
                [FURenderer itemSetParam:items[NETSFUNamaHandleTypeBeauty] withName:modle.mParam value:@(modle.mValue)];
            }
        }
    }
}

- (void)setParamItemAboutType:(NETSFUNamaHandleType)type
                         name:(NSString *)paramName
                        value:(float)value
{
    dispatch_async(_asyncLoadQueue, ^{
        if (self->items[type]) {
            int res = [FURenderer itemSetParam:self->items[type] withName:paramName value:@(value)];
            NSLog(@"设置type(%lu)----参数（%@）-----值(%lf) -----res(%d)", (unsigned long)type, paramName, value, res);
        }
    });
}

- (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    CVPixelBufferRef buffer = [[FURenderer shareRenderer] renderPixelBuffer:pixelBuffer withFrameId:0 items:items itemCount:sizeof(items)/sizeof(int) flipx:YES]; // flipx 参数设为YES可以使道具做水平方向的镜像翻转
    
    return buffer;
}

@end
