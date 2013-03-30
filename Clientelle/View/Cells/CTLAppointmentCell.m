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
#import "CTLCDAppointment.h"

@implementation CTLAppointmentCell

- (void)configure:(CTLCDAppointment *)appointment
{
    self.appointment = appointment;
    
    self.titleLabel.text = appointment.title;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ - %@", [NSDate formatShortTimeOnly:appointment.startDate], [NSDate formatShortTimeOnly:appointment.endDate]];
    
    self.dateLabel.text = [NSDate formatShortDateOnly:appointment.startDate];
    //if([appointment.startDate compare:[NSDate date]] == NSOrderedAscending){
}

- (IBAction)segueToMapView:(id)sender
{
    NSDictionary *addressDict = @{@"address": [self.appointment address], @"city": [self.appointment city], @"state": [self.appointment state], @"zip": [self.appointment address]};
        
    NSArray *addressArray = [addressDict allValues];
    NSMutableArray *addyArray = [[NSMutableArray alloc] init];
    
    for(NSUInteger i=0;i<[addressArray count];i++){
        if([[addressArray objectAtIndex:i] length] > 0){
            [addyArray addObject:[addressArray objectAtIndex:i]];
        }
    }
    
    NSString *addressStr = [addyArray componentsJoinedByString:@", "];
    NSString *encodedAddress = [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *mapURLString = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@", encodedAddress];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapURLString]];
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
