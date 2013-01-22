//
//  CTLColor.m
//  Clientelle
//
//  Created by Kevin Liu on 8/19/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import "UIColor+CTLColor.h"

@implementation UIColor(CTLColor)

+(UIColor *)colorFromUnNormalizedRGB:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [self colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

+ (UIColor *)textInputHighlightBackgroundColor
{
    return [self colorFromUnNormalizedRGB:240.0f green:240.0f blue:240.0f alpha:1.0f];
}

+ (UIColor *)ctlTorquoise
{
    return [UIColor colorFromUnNormalizedRGB:177.0f green:204.0f blue:187.0f alpha:1.0f];
}

@end
