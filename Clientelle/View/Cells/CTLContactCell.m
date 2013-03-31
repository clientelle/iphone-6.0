//
//  CTLUserCell.m
//  Clientelle
//
//  Created by Kevin on 6/21/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "CTLContactCell.h"
#import "CTLViewDecorator.h"
#import "CTLABPerson.h"

@implementation CTLContactCell

- (void)configure:(CTLABPerson *)person
{
    self.nameLabel.text = [person compositeName];
    
    if([[person phone] length] > 0){
        self.detailsLabel.text = person.phone;
    }else if([[person email] length] > 0){
        self.detailsLabel.text = person.email;
    }else{
        self.detailsLabel.text = @"";
    }
}

- (void)setIndicator
{
    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0.0f, 0.0f, 6.0f, self.contentView.bounds.size.height);
    leftBorder.backgroundColor = [UIColor colorFromUnNormalizedRGB:229.0f green:174.0f blue:83.0f alpha:1.0f].CGColor;
    [self.layer addSublayer:leftBorder];
    self.indicatorLayer = leftBorder;
}

- (void)drawRect:(CGRect)rect
{
    self.contentView.backgroundColor = [UIColor clearColor];
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
    CAShapeLayer *dottedLine = [decorator createDottedLine:self.frame];
    [self.contentView.layer addSublayer:dottedLine];
}

@end
