//
//  CTLTextInputCell.m
//  Clientelle
//
//  Created by Kevin on 6/22/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//
#import "CTLViewDecorator.h"
#import "UIColor+CTLColor.h"
#import "CTLFieldCell.h"

@implementation CTLFieldCell

- (void)drawRect:(CGRect)rect
{
    self.textInput.backgroundColor = [UIColor clearColor];
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
    CAShapeLayer *dottedLine = [decorator createDottedLine:self.textInput.frame];
    [self.textInput.layer addSublayer:dottedLine];
    
    [self.textInput addTarget:self action:@selector(addHighlight:) forControlEvents:UIControlEventEditingDidBegin];
    
    [self.textInput addTarget:self action:@selector(removeHighlight:) forControlEvents:UIControlEventEditingDidEnd];
}

- (void)addHighlight:(UITextField *)textField
{
    [textField setBackgroundColor:[UIColor ctlFadedGray]];
}

- (void)removeHighlight:(UITextField *)textField
{
    [textField setBackgroundColor:[UIColor clearColor]];
}

@end
