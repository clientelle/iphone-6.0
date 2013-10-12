//
//  CTLMessageCell.m
//  Clientelle
//
//  Created by Kevin Liu on 5/28/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "CTLViewDecorator.h"

#import "CTLMessageCell.h"
#import "CTLCDMessage.h"


@implementation CTLMessageCell

- (void)awakeFromNib {
    self.messageTextView.textColor = [UIColor ctlGreen];
}

+ (CGFloat)heightForCellWithMessage:(CTLCDMessage *)message
{
    CGFloat originalCellHeight = 65.0f;
    CGFloat originalMessageTextHeight = 20.0f;
    CGFloat messageTextHeight = [[message message_text] sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(236.0f, 1000.0f)].height;
    
    return originalCellHeight + messageTextHeight - originalMessageTextHeight;
}

@end
