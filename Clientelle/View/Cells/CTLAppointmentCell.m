//
//  CTLAppointmentCell.m
//  Clientelle
//
//  Created by Kevin Liu on 3/12/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "NSDate+CTLDate.h"

#import "CTLAppointmentCell.h"
#import "CTLViewDecorator.h"

@implementation CTLAppointmentCell

- (IBAction)segueToMapView:(id)sender
{
    [self.delegate showMap:self];
}

- (void)drawRect:(CGRect)rect
{
    self.contentView.backgroundColor = [UIColor clearColor];
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
    CAShapeLayer *dottedLine = [decorator createDottedLine:self.frame];
    [self.contentView.layer addSublayer:dottedLine];
    
    CAShapeLayer *dottedLine2 = [decorator createDottedVerticalLine:self.frame];
    [self.mapButton.layer addSublayer:dottedLine2];
}

@end
