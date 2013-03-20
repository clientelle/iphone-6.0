//
//  CTLTextInputCell.m
//  Clientelle
//
//  Created by Kevin on 6/22/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "CTLContactFieldCell.h"
#import "CTLViewDecorator.h"

@implementation CTLContactFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.textInput.backgroundColor = [UIColor clearColor];
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
    CAShapeLayer *dottedLine = [decorator createDottedLine:self.textInput.frame];
    [self.textInput.layer addSublayer:dottedLine];
}

@end
