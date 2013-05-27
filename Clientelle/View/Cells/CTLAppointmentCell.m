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

- (void)decorateInCompletedCell:(NSDate *)date
{
    [self.doneButton setImage:nil forState:UIControlStateNormal];

    if([date compare:[NSDate date]] == NSOrderedAscending){
        self.dateLabel.textColor = [UIColor ctlRed];
        self.timeLabel.textColor = [UIColor ctlRed];
    }
}

- (void)decorateCompletedCell:(NSDate *)date
{
    UIImage *checkMark = [UIImage imageNamed:@"26-checkmark-gray"];
    [self.doneButton setImage:checkMark forState:UIControlStateNormal];
    self.dateLabel.textColor = [UIColor darkGrayColor];
    
    if([date compare:[NSDate date]] == NSOrderedAscending){
        //TODO: implement timeago
        self.timeLabel.text = @"Past due";
    }else{
        NSString *timeString = [NSString stringWithFormat:@"@%@", [NSDate formatShortTimeOnly:date]];
        self.timeLabel.text = [timeString lowercaseString];
    }
}

- (void)drawRect:(CGRect)rect
{
    self.contentView.backgroundColor = [UIColor clearColor];
    
    UIColor *borderColor = [UIColor colorFromUnNormalizedRGB:225.0f green:225.0f blue:225.0f alpha:1.0];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.backgroundColor = borderColor.CGColor;
    topBorder.frame = CGRectMake(0, 0, self.frame.size.width, 1.0f);
    [self.layer addSublayer:topBorder];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = borderColor.CGColor;
    bottomBorder.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 1.0f);
    [self.layer addSublayer:bottomBorder];
    
    
    CALayer *headerLayer = [CALayer layer];
    headerLayer.backgroundColor = [UIColor colorFromUnNormalizedRGB:200.0f green:200.0f blue:200.0f alpha:0.2].CGColor;
    headerLayer.borderColor = [UIColor darkGrayColor].CGColor;
    headerLayer.frame = CGRectMake(0, 0, self.frame.size.width, 25.0f);
    [self.layer addSublayer:headerLayer];
    
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];

    CAShapeLayer *dottedLine = [decorator createDottedVerticalLine:self.mapButton.frame.size.height];
    self.mapButton.imageEdgeInsets = UIEdgeInsetsMake(5.0f, 0, 0, 0);
    [self.mapButton.layer addSublayer:dottedLine];
}

@end
