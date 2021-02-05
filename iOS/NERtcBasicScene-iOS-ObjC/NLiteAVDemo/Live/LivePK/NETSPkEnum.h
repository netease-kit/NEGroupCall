//
//  NETSPkEnum.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/9.
//  Copyright © 2021 Netease. All rights reserved.
//

///
/// pk直播服务 枚举
///

#ifndef NETSPkEnum_h
#define NETSPkEnum_h

/// 被邀请者忙碌,拒绝pk邀请自定义字段
static NSString *kInviteeBusyRejectPk = @"busy_now";
/// 邀请者超时,取消pk邀请自定义字段
static NSString *kInviterTimeoutCancelPk = @"time_out_cancel";

/// 直播状态枚举
typedef NS_ENUM(NSUInteger, NETSPkServiceStatus) {
    NETSPkServiceInit       = 0,    // 初始化状态
    NETSPkServicePrevew     = 1,    // 预览状态
    NETSPkServiceSingleLive = 2,    // 单人直播状态
    NETSPkServicePkInviting = 3,    // pk直播邀请中
    NETSPkServicePkLive     = 4     // PK直播状态
};

/// 当前角色枚举
typedef NS_ENUM(NSUInteger, NETSPkServiceRole) {
    NETSPkServiceUnknown    = -1,   // 未知直播者
    NETSPkServiceDefault    = 0,    // 普通直播者
    NETSPkServiceInviter    = 1,    // pk邀请者
    NETSPkServiceInvitee    = 2     // pk被邀请者
};

/// 邀请者被拒绝pk类型
typedef NS_ENUM(NSUInteger, NETSPkRejectedType) {
    NETSPkRejectedArtificial        = 0,    // 被邀请者手动拒绝
    NETSPkRejectedForBusyInvitee    = 1     // 因被邀请者忙碌,自动拒绝邀请者pk邀请
};

#endif /* NETSPkEnum_h */
