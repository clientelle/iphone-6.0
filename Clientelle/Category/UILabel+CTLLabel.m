//
//  UILabel+CTLLabel.m
//  Clientelle
//
//  Created by Kevin Liu on 3/25/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "UILabel+CTLLabel.h"

@implementation UILabel (CTLLabel)

+ (void)autoWidth:(UILabel *)label
{
    CGRect nameLabelFrame = label.frame;
    CGSize nameLabelSize = [label.text sizeWithFont:label.font];
    nameLabelFrame.size.width = nameLabelSize.width;
    label.frame = nameLabelFrame;
}

@end
