//
//  CTLTopRoundedCorners.m
//  Clientelle
//
//  Created by Kevin Liu on 3/19/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CTLTopRoundedCorners.h"
#import "UIColor+CTLColor.h"

@implementation CTLTopRoundedCorners

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat radius = 5;
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    // Make sure corner radius isn't larger than half the shorter side
    if (radius > width/2.0)
        radius = width/2.0;
    
    if (radius > height/2.0)
        radius = height/2.0;
    
    CGFloat minx = CGRectGetMinX(rect); //(x) bottom-left
    CGFloat midx = CGRectGetMidX(rect); //(x) center
    CGFloat maxx = CGRectGetMaxX(rect); //(x) top-right
    CGFloat miny = CGRectGetMinY(rect); //(y) bottom-left
    CGFloat midy = CGRectGetMidY(rect); //(y) center
    CGFloat maxy = CGRectGetMaxY(rect); //(y) top-right
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, height);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddLineToPoint(context, maxx, maxy);

    CGContextSetFillColorWithColor(context, [UIColor ctlGroupedTableBackgroundColor].CGColor);
    CGContextFillPath(context);
    CGContextSaveGState(context);
    
    CGRect maskRect = CGRectInset(self.bounds, -10, 0);
    CGRect shadowRect = CGRectInset(self.bounds, 0, -10);
    
    shadowRect.origin.y += 10;
    maskRect.origin.y -= 10;
    maskRect.size.height += 10;
     
    // now configure the background view layer with the shadow
    CALayer *layer = self.layer;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 1.5f;
    layer.shadowOpacity = 0.75f;
    layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:shadowRect cornerRadius:5].CGPath;
    layer.masksToBounds = NO;

    // and finally add the shadow mask
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRect:maskRect].CGPath;
    layer.mask = maskLayer;
    
    [super drawRect:rect];    
}

@end
