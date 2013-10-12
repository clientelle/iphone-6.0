//
//  CTLDottedLine.m
//  Clientelle
//
//  Created by Kevin Liu on 3/17/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "UIColor+CTLColor.h"
#import "CTLViewDecorator.h"

@implementation CTLViewDecorator

- (CAShapeLayer *)createDottedLine:(CGRect)frame
{
    UIColor *fill = [UIColor ctlMediumGray];
    CAShapeLayer *shapelayer = [CAShapeLayer layer];
    shapelayer.strokeStart = 0.0;
    shapelayer.strokeColor = fill.CGColor;
    shapelayer.lineWidth = 1.0;
    shapelayer.lineJoin = kCALineJoinRound;
    shapelayer.lineDashPattern = @[@(1), @(3)];

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0, frame.size.height)];
    [path addLineToPoint:CGPointMake(frame.size.width, frame.size.height)];
    shapelayer.path = path.CGPath;
    
    return shapelayer;
}

- (CAShapeLayer *)createDottedVerticalLine:(CGFloat)height
{
    UIColor *fill = [UIColor ctlMediumGray];
    CAShapeLayer *shapelayer = [CAShapeLayer layer];
    shapelayer.strokeStart = 0.0;
    shapelayer.strokeColor = fill.CGColor;
    shapelayer.lineWidth = 1.0;
    shapelayer.lineJoin = kCALineJoinRound;
    shapelayer.lineDashPattern = @[@(1), @(3)];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 10.0f)];
    [path addLineToPoint:CGPointMake(0, height)];
    shapelayer.path = path.CGPath;
    
    return shapelayer;
}

@end
