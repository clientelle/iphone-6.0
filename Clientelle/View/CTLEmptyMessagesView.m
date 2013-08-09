//
//  CTLEmptyMessagesView.m
//  Clientelle
//
//  Created by Kevin Liu on 6/16/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CTLViewDecorator.h"
#import "CTLEmptyMessagesView.h"

@implementation CTLEmptyMessagesView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
    CAShapeLayer *dottedLine = [decorator createDottedLine:self.frame];
    [self.layer addSublayer:dottedLine];
}

@end
