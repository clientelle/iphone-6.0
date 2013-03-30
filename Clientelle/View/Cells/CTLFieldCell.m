//
//  CTLTextInputCell.m
//  Clientelle
//
//  Created by Kevin on 6/22/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import "CTLFieldCell.h"
#import "CTLViewDecorator.h"

@implementation CTLFieldCell

- (void)drawRect:(CGRect)rect
{
    self.textInput.backgroundColor = [UIColor clearColor];
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
    CAShapeLayer *dottedLine = [decorator createDottedLine:self.textInput.frame];
    [self.textInput.layer addSublayer:dottedLine];
}

@end
