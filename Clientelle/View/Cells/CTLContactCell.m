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

@end
