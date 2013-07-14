//
//  CTLColor.m
//  Clientelle
//
//  Created by Kevin Liu on 8/19/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import "UIColor+CTLColor.h"

@implementation UIColor(CTLColor)

+(UIColor *)colorFromUnNormalizedRGB:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha{
    return [self colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

+ (UIColor *)ctlOffWhite{
    return [self colorFromUnNormalizedRGB:250.0f green:250.0f blue:250.0f alpha:1.0f];
}

+ (UIColor *)ctlFadedGray{
    return [self colorFromUnNormalizedRGB:200.0f green:200.0f blue:200.0f alpha:0.25f];
}

+ (UIColor *)ctlGreen{
    return [self colorFromUnNormalizedRGB:61.0f green:103.0f blue:0 alpha:1.0f];
}

+ (UIColor *)ctlLightGreen{
    return [self colorFromUnNormalizedRGB:115.0f green:168.0f blue:83.0f alpha:1.0f];
}

+ (UIColor *)ctlTorquoise{
    return [self colorFromUnNormalizedRGB:177.0f green:204.0f blue:187.0f alpha:1.0f];
}

+ (UIColor *)ctlGray{
    return [self colorFromUnNormalizedRGB:200.0f green:200.0f blue:200.0f alpha:1.0f];
}

+ (UIColor *)ctlLightGray{
    return [self colorFromUnNormalizedRGB:238.0f green:238.0f blue:238.0f alpha:1.0f];
}

+ (UIColor *)ctlMediumGray{
    return [self colorFromUnNormalizedRGB:160.0f green:160.0f blue:160.0f alpha:1.0f];
}

+ (UIColor *)ctlDarkGray{
    return [self colorFromUnNormalizedRGB:48.0f green:48.0f blue:48.0f alpha:1.0f];
}

+ (UIColor *)ctlOrange{
    return [self colorFromUnNormalizedRGB:255.0f green:169.0f blue:71.0f alpha:0.85f];
}

+ (UIColor *)ctlInputErrorBackground{
    return [self colorFromUnNormalizedRGB:249.0f green:235.0f blue:231.0f alpha:1.0f];
}

+ (UIColor *)iOSHighlightedTextColor{
    return [self colorFromUnNormalizedRGB:208 green:220 blue:236 alpha:1.0f];
}

+ (UIColor *)ctlGroupedTableBackgroundColor{
    return [self colorFromUnNormalizedRGB:237.0f green:237.0f blue:237.0f alpha:1.0f];
}

+ (UIColor *)ctlRed
{
    return [self colorFromUnNormalizedRGB:160.0f green:36.0f blue:34.0f alpha:0.90f];
}

+ (UIColor *)ctlErrorPink
{
    return [self colorFromUnNormalizedRGB:237.0f green:221.0f blue:221.0f alpha:0.60f];
}

@end
