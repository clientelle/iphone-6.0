//
//  CTLMenuItemCell.m
//  Clientelle
//
//  Created by Kevin Liu on 3/10/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "CTLContainerViewController.h"
#import "CTLMenuItemCell.h"

const CGFloat CTLMainMenuCellHeight = 60.0f;

@implementation CTLMenuItemCell

- (void)setActiveBorders:(BOOL)isLastCell
{
    self.contentView.backgroundColor = _activeCellColor;
    [_topBorder setBackgroundColor:_activeCellColor.CGColor];
    
    if(isLastCell){
        [_bottomBorder setBackgroundColor:_topBorderColor.CGColor];
    }else{
        [_bottomBorder setBackgroundColor:_activeBottomBorderColor.CGColor];
    }
}

- (void)resetBorders
{
    self.contentView.backgroundColor = [UIColor clearColor];
    [_topBorder setBackgroundColor:_topBorderColor.CGColor];
    [_bottomBorder setBackgroundColor:_bottomBorderColor.CGColor];
}

- (void)drawRect:(CGRect)rect
{
    _activeCellColor = [UIColor colorFromUnNormalizedRGB:51.0f green:51.0f blue:51.0f alpha:1.0f];
    _activeBottomBorderColor = [UIColor colorFromUnNormalizedRGB:48.0f green:48.0f blue:48.0f alpha:1.0f];
    
    _topBorderColor = [UIColor colorFromUnNormalizedRGB:61.0f green:61.0f blue:61.0f alpha:1.0f];
    _bottomBorderColor = [UIColor colorFromUnNormalizedRGB:20.0f green:20.0f blue:20.0f alpha:1.0f];
    
    _topBorder = [CALayer layer];
    _topBorder.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 1.0f);
    _topBorder.backgroundColor = _topBorderColor.CGColor;
    
    _bottomBorder = [CALayer layer];
    _bottomBorder.frame = CGRectMake(0.0f, CTLMainMenuCellHeight-1, self.frame.size.width, 1.0f);
    _bottomBorder.backgroundColor = _bottomBorderColor.CGColor;
    
    [self.layer addSublayer:_topBorder];
    [self.layer addSublayer:_bottomBorder];
}

@end
