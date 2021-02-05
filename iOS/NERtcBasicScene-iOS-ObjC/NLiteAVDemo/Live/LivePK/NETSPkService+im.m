//
//  NETSPkService+im.m
//  NLiteAVDemo
//
//  Created by Think on 2021/1/9.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSPkService+im.h"
#import "NETSChatroomService.h"

@implementation NETSPkService (im)

- (void)sendMessageWithText:(NSString *)text
                   errorPtr:(NSError * __nullable *)errorPtr
{
    NSString *chatroomId = self.singleRoom.chatRoomId;
    NSString *nickname = self.singleRoom.nickname;
    
    [NETSChatroomService sendMessage:text inRoomId:chatroomId userMode:NETSUserModeAnchor nickname:nickname errorPtr:errorPtr];
}

- (void)_sendPkStartImMsgWithData:(NETSPassThroughHandlePkStartData *)data
                         errorPtr:(NSError * __nullable *)errorPtr
{
    NSString *roomId = self.singleRoom.chatRoomId;
    
    NIMMessage *message = [NETSChatroomService pkMessageWithState:NETSLiveAttachmentStatusStart
                                                 startedTimestamp:data.pkStartTime
                                                 currentTimestamp:data.currentTime
                                              otherAnchorNickname:data.inviteeNickname
                                                otherAnchorAvatar:data.inviteeAvatar
                                                 currentAnchorWin:NO];
    [NETSChatroomService sendMessage:message roomId:roomId errorPtr:errorPtr];
}

- (void)_sendPkEndImMsgWithData:(nullable NETSPassThroughHandlePunishData *)data
               currentAnchorWin:(BOOL)currentAnchorWin
                       errorPtr:(NSError * __nullable *)errorPtr
{
    NSString *roomId = self.singleRoom.chatRoomId;
    
    NIMMessage *pkEndMsg = [NETSChatroomService pkMessageWithState:NETSLiveAttachmentStatusEnd
                                                  startedTimestamp:data.pkStartTime
                                                  currentTimestamp:data.currentTime
                                               otherAnchorNickname:@""
                                                 otherAnchorAvatar:@""
                                                  currentAnchorWin:currentAnchorWin];
    [NETSChatroomService sendMessage:pkEndMsg roomId:roomId errorPtr:errorPtr];
}

- (void)_sendPunishStartImMsgWithData:(NETSPassThroughHandlePunishData *)data
                             errorPtr:(NSError * __nullable *)errorPtr;
{
    NSString *roomId = self.singleRoom.chatRoomId;
    
    NIMMessage *punStarMsg = [NETSChatroomService punishMessageWithState:NETSLiveAttachmentStatusStart
                                                        startedTimestamp:data.pkPulishmentTime
                                                        currentTimestamp:data.currentTime
                                                     otherAnchorNickname:@""
                                                       otherAnchorAvatar:@""];
    [NETSChatroomService sendMessage:punStarMsg roomId:roomId errorPtr:errorPtr];
}

- (void)_sendPunishEndImMsgWithData:(nullable NETSPassThroughHandlePkEndData *)data
                           errorPtr:(NSError * __nullable *)errorPtr
{
    NSString *roomId = self.singleRoom.chatRoomId;
    
    NIMMessage *punStarMsg = [NETSChatroomService punishMessageWithState:NETSLiveAttachmentStatusEnd
                                                        startedTimestamp:data.pkPulishmentTime
                                                        currentTimestamp:data.currentTime
                                                     otherAnchorNickname:@""
                                                       otherAnchorAvatar:@""];
    [NETSChatroomService sendMessage:punStarMsg roomId:roomId errorPtr:errorPtr];
}

- (NIMMessage *)_syncCoinMegWithData:(NETSPassThroughHandleRewardData *)data
{
    int32_t totalCoinCount = data.rewardCoinTotal;
    int32_t pkCoinCount = data.inviterRewardPKCoinTotal;
    int32_t otherPKCoinCount = data.inviteeRewardPKCoinTotal;
    NSArray *originRewardList = data.rewardPkList;
    NSArray *originOtherRewardList = data.inviteeRewardPkList;
    
    if (self.liveRole == NETSPkServiceInvitee) {
        totalCoinCount = data.inviteeRewardCoinTotal;
        pkCoinCount = data.inviteeRewardPKCoinTotal;
        otherPKCoinCount = data.inviterRewardPKCoinTotal;
        originRewardList = data.inviteeRewardPkList;
        originOtherRewardList = data.rewardPkList;
    }
    
    return [NETSChatroomService rewardeMessageWithNickname:data.nickname giftId:data.giftId fromUserAvRoomUid:data.fromUserAvRoomUid totalCoinCount:totalCoinCount pkCoinCount:pkCoinCount otherPKCoinCount:otherPKCoinCount originRewardList:originRewardList originOtherRewardList:originOtherRewardList];
}

- (void)_sendSyncCoinsImMsg:(NIMMessage *)msg
                   errorPtr:(NSError * __nullable *)errorPtr
{
    NSString *roomId = self.singleRoom.chatRoomId;
    [NETSChatroomService sendMessage:msg roomId:roomId errorPtr:errorPtr];
}

@end
