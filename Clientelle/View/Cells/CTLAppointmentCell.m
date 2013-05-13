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


- (IBAction)markAsComplete:(id)sender
{
    [self.delegate changeAppointmentStatus:self];
}

- (IBAction)segueToMapView:(id)sender
{
    [self.delegate showMap:self];
}

- (void)decorateInCompletedCell:(BOOL)isOverDue
{
    [self.doneButton setImage:nil forState:UIControlStateNormal];
    if(isOverDue){
        self.dateLabel.textColor = [UIColor ctlRed];
    }
}

- (void)decorateCompletedCell
{
    UIImage *checkMark = [UIImage imageNamed:@"26-checkmark-gray"];
    [self.doneButton setImage:checkMark forState:UIControlStateNormal];
    self.dateLabel.textColor = [UIColor darkGrayColor];
}

- (void)drawRect:(CGRect)rect
{
    self.contentView.backgroundColor = [UIColor clearColor];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.backgroundColor = [UIColor colorFromUnNormalizedRGB:235.0f green:235.0f blue:235.0f alpha:1.0].CGColor;
    topBorder.frame = CGRectMake(0, 0, self.frame.size.width, 1.0f);
    [self.layer addSublayer:topBorder];
    
    
    CALayer *headerLayer = [CALayer layer];
    headerLayer.backgroundColor = [UIColor colorFromUnNormalizedRGB:200.0f green:200.0f blue:200.0f alpha:0.2].CGColor;
    headerLayer.borderColor = [UIColor darkGrayColor].CGColor;
    headerLayer.frame = CGRectMake(0, 0, self.frame.size.width, 25.0f);
    [self.layer addSublayer:headerLayer];
    
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
//    CAShapeLayer *dottedLine = [decorator createDottedLine:self.frame];
//    [self.contentView.layer addSublayer:dottedLine];
    
    CAShapeLayer *vDottedLine = [decorator createDottedVerticalLine:self.mapButton.frame.size.height];
    self.mapButton.imageEdgeInsets = UIEdgeInsetsMake(5.0f, 0, 0, 0);
    [self.mapButton.layer addSublayer:vDottedLine];
}

@end
