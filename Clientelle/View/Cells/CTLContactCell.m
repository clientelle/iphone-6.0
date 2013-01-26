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

-(void)drawRect:(CGRect)rect {
   /* [self.contentView setBackgroundColor:[UIColor colorFromUnNormalizedRGB:245 green:245 blue:245 alpha:1.0f]];
    CALayer *bevelLine = [CALayer layer];
    bevelLine.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 1.0f);
    bevelLine.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:bevelLine]; */
    
    [self.contentView setBackgroundColor:[UIColor colorFromUnNormalizedRGB:245 green:245 blue:245 alpha:1.0f]];
    
    CALayer *bevelTopLine = [CALayer layer];
    bevelTopLine.frame = CGRectMake(0.0f, 1.0f, self.frame.size.width, 1.0f);
    bevelTopLine.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:bevelTopLine];
    
    CALayer *bevelLine = [CALayer layer];
    bevelLine.frame = CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, 1.0f);
    bevelLine.backgroundColor = [UIColor colorFromUnNormalizedRGB:200.0f green:200.0f blue:200.0f alpha:1.0f].CGColor;
    [self.layer addSublayer:bevelLine];
    
}

@end
