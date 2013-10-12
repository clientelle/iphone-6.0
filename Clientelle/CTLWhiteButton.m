//
//  CTLTableViewFooterButton.m
//  Clientelle
//
//  Created by Kevin Liu on 7/20/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UILabel+CTLLabel.h"
#import "UIColor+CTLColor.h"
#import "CTLWhiteButton.h"

@implementation CTLWhiteButton


- (void)awakeFromNib
{
    UIEdgeInsets insets = UIEdgeInsetsMake(18, 18, 18, 18);
    UIImage *bgImage = [[UIImage imageNamed:@"whiteButton"] resizableImageWithCapInsets:insets];    
    UIImage *bgImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight"] resizableImageWithCapInsets:insets];
    
    // Set the background for any states you plan to use
    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
    [self setBackgroundImage:bgImageHighlight forState:UIControlStateHighlighted];
    
    self.layer.shadowOpacity = 0.2f;
    self.layer.shadowRadius = 1.0f;
    self.layer.shadowOffset = CGSizeMake(0,0);
}

@end
