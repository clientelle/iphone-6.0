//
//  CTLMenuItemCell.m
//  Clientelle
//
//  Created by Kevin Liu on 3/10/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "CTLSlideMenuController.h"
#import "CTLMenuItemCell.h"

@implementation CTLMenuItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 1.0f);
        
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height-5, self.frame.size.width, 1.0f);
         
        [self.layer addSublayer:topBorder];
        [self.layer addSublayer:bottomBorder];
        
        _topBorder = topBorder;
        _bottomBorder = bottomBorder;
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        [self.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]];
        [self.textLabel setTextColor:[UIColor whiteColor]];
        
        UIImageView *indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white-indicator-right.png"]];
        CGRect frame = indicator.frame;
        frame.origin.x = CTLMainMenuWidth - (indicator.image.size.width + 10.0f);
        frame.origin.y = 18.0f;
        indicator.frame = frame;
        
        [self addSubview:indicator];
        
        [self resetBorders];
    }
    
    return self;
}

- (void)setActiveBorders:(BOOL)isLast
{
    self.contentView.backgroundColor = [UIColor colorFromUnNormalizedRGB:51.0f green:51.0f blue:51.0f alpha:1.0f];
    [_topBorder setBackgroundColor:[UIColor colorFromUnNormalizedRGB:51.0f green:51.0f blue:51.0f alpha:1.0f].CGColor];
    
    if(isLast){
        [_bottomBorder setBackgroundColor:[UIColor colorFromUnNormalizedRGB:61.0f green:61.0f blue:61.0f alpha:1.0f].CGColor];
    }else{
        [_bottomBorder setBackgroundColor:[UIColor colorFromUnNormalizedRGB:48.0f green:48.0f blue:48.0f alpha:1.0f].CGColor];
    }
}

- (void)resetBorders
{
    self.contentView.backgroundColor = [UIColor clearColor];
    [_topBorder setBackgroundColor:[UIColor colorFromUnNormalizedRGB:61.0f green:61.0f blue:61.0f alpha:1.0f].CGColor];
    [_bottomBorder setBackgroundColor:[UIColor colorFromUnNormalizedRGB:15.0f green:15.0f blue:15.0f alpha:1.0f].CGColor];
}

- (void)lastBorder
{
    [_bottomBorder setBackgroundColor:[UIColor clearColor].CGColor];
}

@end
