//
//  CTLMessageCell.m
//  Clientelle
//
//  Created by Kevin Liu on 5/28/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CTLViewDecorator.h"
#import "CTLConversationCell.h"

@implementation CTLConversationCell

- (void)drawRect:(CGRect)rect
{
    self.contentView.backgroundColor = [UIColor clearColor];
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
    CAShapeLayer *dottedLine = [decorator createDottedLine:self.frame];
    [self.contentView.layer addSublayer:dottedLine];
}

@end
