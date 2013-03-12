//
//  CTLAppointmentCell.m
//  Clientelle
//
//  Created by Kevin Liu on 3/12/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "CTLAppointmentCell.h"

@implementation CTLAppointmentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)drawRect:(CGRect)rect{
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    UIColor *fill = [UIColor ctlMediumGray];
    CAShapeLayer *shapelayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    //draw a line
    [path moveToPoint:CGPointMake(0.0, self.frame.size.height)]; //add yourStartPoint here
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];// add yourEndPoint here
    
    shapelayer.strokeStart = 0.0;
    shapelayer.strokeColor = fill.CGColor;
    shapelayer.lineWidth = 1.0;
    shapelayer.lineJoin = kCALineJoinRound;
    shapelayer.lineDashPattern = @[@(1), @(3)];
    shapelayer.path = path.CGPath;
    
    [self.contentView.layer addSublayer:shapelayer];
}

@end
