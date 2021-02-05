//
//  NETSMessageModel.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSMessageModel.h"
#import "M80AttributedLabel.h"
#import "NEAccount.h"
#import "NETSLiveAttachment.h"
#import "NETSLiveUtils.h"
#import "NETSGiftModel.h"

@interface NETSMessageModel ()

/// 昵称
@property (nonatomic,assign) NSRange nickRange;
/// 文字区间
@property (nonatomic,assign) NSRange textRange;

@property (nonatomic, assign)    BOOL        isAnchor;
@property (nonatomic, copy)      NSString    *giftIcon;

@end

@implementation NETSMessageModel

- (void)caculate:(CGFloat)width
{
    ntes_main_sync_safe(^{
        M80AttributedLabel *label = NTESCaculateLabel();
        [self drawAttributeLabel:label];
        CGFloat tmpW = self.isAnchor ? (width - 32) : width;
        CGSize size = [label sizeThatFits:CGSizeMake(tmpW, CGFLOAT_MAX)];
        if (self.isAnchor) {
            size = CGSizeMake(size.width + 32, size.height);
        }
        self->_size = size;
    });
}

- (void)drawAttributeLabel:(M80AttributedLabel *)label
{
    if ([label.attributedText length] > 0) {
        NSAttributedString *empty = [[NSAttributedString alloc] initWithString:@""];
        [label setAttributedText:empty];
    }
    
    if (self.isAnchor) {
        UIImage *authorIco = [UIImage imageNamed:@"anthor_ico"];
        [label appendImage:authorIco maxSize:CGSizeMake(32, 16) margin:UIEdgeInsetsZero alignment:M80ImageAlignmentCenter];
    }
    [label appendAttributedText:self.formatMessage];
    if (!isEmptyString(self.giftIcon)) {
        UIImage *rewardIco = [UIImage imageNamed:self.giftIcon];
        [label appendImage:rewardIco maxSize:CGSizeMake(20, 20) margin:UIEdgeInsetsZero alignment:M80ImageAlignmentCenter];
    }
}

- (NSAttributedString *)formatMessage
{
    NSString *showMessage = [self showMessage];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:showMessage];
    switch (_type) {
        case NETSMessageNormal:
        {
            [text setAttributes:@{NSForegroundColorAttributeName:HEXCOLOR(0x828282), NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}
                          range:_nickRange];
            [text setAttributes:@{NSForegroundColorAttributeName:HEXCOLOR(0xffffff), NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}
                          range:_textRange];
        }
            break;
        case NETSMessageNotication:
        {
            [text setAttributes:@{NSForegroundColorAttributeName:HEXCOLOR(0xffffff), NSFontAttributeName: [UIFont boldSystemFontOfSize:14]}
                          range:_textRange];
        }
            break;
        default:
            break;
    }
    return text;
}

- (NSRange)textRange
{
    NSString *showMessage = [self showMessage];
    return NSMakeRange(showMessage.length - self.message.text.length, self.message.text.length);
}

- (NSString *)showMessage
{
    NSString *showMessage = @"";
    switch (_type) {
        case NETSMessageNormal:
        {
            NIMCustomObject *obj = _message.messageObject;
            if ([obj.attachment isKindOfClass:[NETSLiveTextAttachment class]]) {
                // 构造文本消息
                NETSLiveTextAttachment *attach = (NETSLiveTextAttachment *)obj.attachment;
                
                self.isAnchor = attach.isAnchor;
                
                NSString *nickname = [self fromNickNameWithMessage:_message];
                showMessage = [NSString stringWithFormat:@"%@：%@", nickname, attach.message];

                _textRange = NSMakeRange(showMessage.length - attach.message.length, attach.message.length);
                _nickRange = NSMakeRange(0, showMessage.length - attach.message.length);
            }
            else if ([obj.attachment isKindOfClass:[NETSLiveWealthChangeAttachment class]]) {
                // 构造打赏消息
                NETSLiveWealthChangeAttachment *attach = (NETSLiveWealthChangeAttachment *)obj.attachment;
                
                NETSGiftModel *reward = [NETSLiveUtils getRewardWithGiftId:attach.giftId];
                self.giftIcon = reward.icon;
                
                NSString *nickname = attach.nickname;
                NSString *msg = @"赠送礼物x1 ";
                showMessage = [NSString stringWithFormat:@"%@: %@", nickname, msg];

                _textRange = NSMakeRange(showMessage.length - msg.length, msg.length);
                _nickRange = NSMakeRange(0, showMessage.length - msg.length);
            } else {
                NSString *nickName = [self fromNickNameWithMessage:_message];
                showMessage = [NSString stringWithFormat:@"%@：%@", nickName, _message.text];
                _textRange = NSMakeRange(showMessage.length-_message.text.length, _message.text.length);
                _nickRange = NSMakeRange(0, showMessage.length-_message.text.length);
            }

            break;
        }
        case NETSMessageNotication:
        {
            showMessage = [NSString stringWithFormat:@"%@", _message.text];
            _textRange = NSMakeRange(0, showMessage.length);
            _nickRange = NSMakeRange(0, 0);
            break;
        }
        default:
            break;
    }
    return showMessage;
}

M80AttributedLabel *NTESCaculateLabel()
{
    static M80AttributedLabel *label;
    if (!label) {
        label = [[M80AttributedLabel alloc] init];
        label.font = [UIFont boldSystemFontOfSize:14];
        label.numberOfLines = 0;
        label.lineBreakMode = kCTLineBreakByCharWrapping;
    }
    return label;
}

- (NSString *)fromNickNameWithMessage:(NIMMessage *)message
{
    NEUser *user = [NEAccount shared].userModel;
    NSString *nickName = @"";
    if ([message.from isEqualToString:user.imAccid]) {
        nickName = user.nickname;
    } else {
        NIMMessageChatroomExtension *ext = [message.messageExt isKindOfClass:[NIMMessageChatroomExtension class]] ?
        (NIMMessageChatroomExtension *)message.messageExt : nil;
        nickName = ext.roomNickname;
    }
    return nickName ?: @"";
}

@end
