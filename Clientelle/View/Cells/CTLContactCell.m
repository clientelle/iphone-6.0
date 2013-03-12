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

@implementation CTLContactCell

- (void)setIndicator {
    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0.0f, 0.0f, 6.0f, self.contentView.bounds.size.height);
    leftBorder.backgroundColor = [UIColor colorFromUnNormalizedRGB:229.0f green:174.0f blue:83.0f alpha:1.0f].CGColor;
    [self.layer addSublayer:leftBorder];
    self.indicatorLayer = leftBorder;
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
