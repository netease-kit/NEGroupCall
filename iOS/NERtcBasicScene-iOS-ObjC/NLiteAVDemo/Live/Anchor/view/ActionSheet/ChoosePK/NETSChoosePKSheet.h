//
//  NETSChoosePKSheet.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSBaseActionSheet.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSLiveRoomModel;
@class NETSChoosePKSheet;

@protocol NETSChoosePKSheetDelegate <NSObject>

///
/// 选中主播进行PK
/// @param sheet    - 选择PK视图
/// @param room     - 主播房间
///
- (void)choosePkOnSheet:(NETSChoosePKSheet *)sheet withRoom:(NETSLiveRoomModel *)room;

@end

@interface NETSChoosePKSheet : NETSBaseActionSheet

///
/// 展示选择主播PK ActionSheet
/// @param target   - 代理对象
///
+ (void)showWithTarget:(id<NETSChoosePKSheetDelegate>)target;

@end

NS_ASSUME_NONNULL_END
