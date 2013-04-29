//
//  CTLCellBackground.m
//  Clientelle
//
//  Created by Kevin Liu on 3/17/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CTLCellBackground.h"

@implementation CTLCellBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]].CGColor;
    
    CGContextSetFillColorWithColor(context, background);
    CGContextFillRect(context, self.bounds);
}

@end
