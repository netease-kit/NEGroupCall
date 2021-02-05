//
//  NETSAudienceSendGiftSheet.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSBaseActionSheet.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSGiftModel, NETSAudienceSendGiftSheet;

@protocol NETSAudienceSendGiftSheetDelegate <NSObject>

- (void)didSendGift:(NETSGiftModel *)gift onSheet:(NETSAudienceSendGiftSheet *)sheet;

@end

@interface NETSAudienceSendGiftSheet : NETSBaseActionSheet

+ (void)showWithTarget:(id<NETSAudienceSendGiftSheetDelegate>)target gifts:(NSArray<NETSGiftModel *> *)gifts;

@end

NS_ASSUME_NONNULL_END
