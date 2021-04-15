//
//  NETSPkService+im.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/9.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSPkService.h"

NS_ASSUME_NONNULL_BEGIN

/**
 PK直播服务 分类 im通信能力
 */

@interface NETSPkService (im)

/**
 主播端(邀请者/被邀请者) 发送im消息
 @param text            - im文字信息
 @param errorPtr        - 错误引用
 */
- (void)sendMessageWithText:(NSString *)text
                   errorPtr:(NSError * __nullable *)errorPtr;

/**
 主播端(邀请者/被邀请者) 发送pk开始im信息
 @param data            - passthrough信息
 @param errorPtr        - 错误引用
 */
- (void)_sendPkStartImMsgWithData:(NETSPassThroughHandlePkStartData *)data
                         errorPtr:(NSError * __nullable *)errorPtr;

/**
 主播端(邀请者/被邀请者) 发送pk结束im信息
 @param data                - passthrough信息
 @param currentAnchorWin    - 当前观众所在房间主播是否胜利
 @param errorPtr            - 错误引用
 */
- (void)_sendPkEndImMsgWithData:(nullable NETSPassThroughHandlePunishData *)data
               currentAnchorWin:(BOOL)currentAnchorWin
                       errorPtr:(NSError * __nullable *)errorPtr;

/**
 主播端(邀请者/被邀请者) 发送pk惩罚开始im信息
 @param data            - passthrough信息
 @param errorPtr        - 错误引用
 */
- (void)_sendPunishStartImMsgWithData:(NETSPassThroughHandlePunishData *)data
                             errorPtr:(NSError * __nullable *)errorPtr;

/**
 主播端(邀请者/被邀请者) 发送pk惩罚结束im信息
 @param data            - passthrough信息
 @param errorPtr        - 错误引用
 */
- (void)_sendPunishEndImMsgWithData:(nullable NETSPassThroughHandlePkEndData *)data
                           errorPtr:(NSError * __nullable *)errorPtr;

/**
 主播端(邀请者/被邀请者) 云币同步im信息
 @param data            - passthrough信息
 */
- (NIMMessage *)_syncCoinMegWithData:(NETSPassThroughHandleRewardData *)data;

/**
 主播端(邀请者/被邀请者) 发送云币同步im信息
 @param msg             - passthrough信息
 @param errorPtr        - 错误引用
 */
- (void)_sendSyncCoinsImMsg:(NIMMessage *)msg
                   errorPtr:(NSError * __nullable *)errorPtr;

@end

NS_ASSUME_NONNULL_END
