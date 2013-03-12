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

+ (UIColor *)textInputHighlightBackgroundColor{
    return [self colorFromUnNormalizedRGB:240.0f green:240.0f blue:240.0f alpha:1.0f];
}

+ (UIColor *)ctlGreen{
   return [UIColor colorFromUnNormalizedRGB:232.0f green:237.0f blue:228.0f alpha:1.0f];
}

+ (UIColor *)ctlLightGreen{
    return [UIColor colorFromUnNormalizedRGB:115.0f green:168.0f blue:83.0f alpha:1.0f];
}

+ (UIColor *)ctlTorquoise{
    return [UIColor colorFromUnNormalizedRGB:177.0f green:204.0f blue:187.0f alpha:1.0f];
}

+ (UIColor *)ctlLightGray{
    return [UIColor colorFromUnNormalizedRGB:238.0f green:238.0f blue:238.0f alpha:1.0f];
}

+ (UIColor *)ctlMediumGray{
    return [UIColor colorFromUnNormalizedRGB:180.0f green:180.0f blue:180.0f alpha:1.0f];
}

+ (UIColor *)ctlDarkGray{
    return [UIColor colorFromUnNormalizedRGB:48.0f green:48.0f blue:48.0f alpha:1.0f];
}


+ (UIColor *)ctlOrange{
    return [UIColor colorFromUnNormalizedRGB:255.0f green:169.0f blue:71.0f alpha:0.85f];
}

@end
