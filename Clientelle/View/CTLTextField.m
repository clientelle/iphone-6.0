//
//  CTLTextField.m
//  Clientelle
//
//  Created by Kevin Liu on 6/17/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLViewDecorator.h"
#import "CTLTextField.h"

@implementation CTLTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor clearColor];
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
    CAShapeLayer *dottedLine = [decorator createDottedLine:self.frame];
    [self.layer addSublayer:dottedLine];

}


@end
