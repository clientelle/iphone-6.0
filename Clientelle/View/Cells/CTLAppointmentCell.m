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
    self.titleLabel.layer.sublayers = nil;
    [self.doneButton setImage:nil forState:UIControlStateNormal];
    
    if(isOverDue){
        self.dateLabel.textColor = [UIColor ctlRed];
        self.titleLabel.textColor = [UIColor ctlRed];
    }
}

- (void)decorateCompletedCell
{
    UIImage *checkMark = [UIImage imageNamed:@"26-checkmark-gray"];
    [self.doneButton setImage:checkMark forState:UIControlStateNormal];
    
    CGFloat maxWidth = 245.0f;
    CGSize titleLabelSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
    
    if(titleLabelSize.width > maxWidth){
        titleLabelSize.width = 230.0f;
    }
    
    CALayer *strikeThru = [CALayer layer];
    strikeThru.borderWidth = 1;
    strikeThru.borderColor = [UIColor darkGrayColor].CGColor;
    strikeThru.frame = CGRectMake(-5.0f, (titleLabelSize.height/2) + 1, titleLabelSize.width+10.0f, 1.0f);
    
    [self.titleLabel.layer addSublayer:strikeThru];
    [self.titleLabel setTextColor:[UIColor darkGrayColor]];
    [self.dateLabel setTextColor:[UIColor darkGrayColor]];
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
