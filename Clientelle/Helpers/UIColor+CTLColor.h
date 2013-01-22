//
//  CTLColor.h
//  Clientelle
//
//  Created by Kevin Liu on 8/19/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.

#import <Foundation/Foundation.h>

@interface UIColor(CTLColor)

+(UIColor *)colorFromUnNormalizedRGB:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

+ (UIColor *)textInputHighlightBackgroundColor;

+ (UIColor *)ctlTorquoise;

@end