//
//  UITableViewCell+CellShadows.m
//  Clientelle
//
//  Created by Kevin Liu on 3/17/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "UITableViewCell+CellShadows.h"
#import "CTLCellBackground.h"
#import "CTLTopRoundedCorners.h"
#import "CTLBottomRoundedCorners.h"

@implementation UITableViewCell (CellShadows)

- (void)addShadowToCellInGroupedTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    CGRect cellFrame = [tableView rectForRowAtIndexPath:indexPath];
    
    //top row
    if(indexPath.row == 0){
        self.backgroundView = [[CTLTopRoundedCorners alloc] initWithFrame:cellFrame];
        [self addBottomBorder:cellFrame];
        return;
    }
    
    //last row
    if(indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1){
        self.backgroundView = [[CTLBottomRoundedCorners alloc] initWithFrame:cellFrame];
        [self addTopBorder:cellFrame];
        return;
    }
    
    //all other rows
    self.backgroundView = [[UIView alloc] initWithFrame:cellFrame];
    self.backgroundView.backgroundColor =[UIColor ctlGroupedTableBackgroundColor];
    [self addTopBorder:cellFrame];
    [self addBottomBorder:cellFrame];
    
    CGRect maskRect = CGRectInset(self.backgroundView.bounds, -10, 0);
    CGRect shadowRect = CGRectInset(self.backgroundView.bounds, 9, -10);
    shadowRect.origin.x -= 9;
    
    [self addShadow:shadowRect maskRect:maskRect];
}

- (void)addTopBorder:(CGRect)frame
{
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(9.0f, 0.0f, frame.size.width-18, 1.0f);
    [topBorder setBackgroundColor:[UIColor whiteColor].CGColor];
    [self.layer addSublayer:topBorder];
}

- (void)addBottomBorder:(CGRect)frame
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(9.0f, frame.size.height-1, frame.size.width-18, 1.0f);
    [bottomBorder setBackgroundColor:[UIColor colorFromUnNormalizedRGB:195.0f green:195.0f blue:195.0f alpha:1.0f].CGColor];
    [self.layer addSublayer:bottomBorder];
}

- (void)addShadowToCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    CGRect cellFrame = [tableView rectForRowAtIndexPath:indexPath];
    self.backgroundView = [[CTLCellBackground alloc] initWithFrame:cellFrame];
    
    CGRect maskRect = CGRectInset(self.backgroundView.bounds, -10, 0);
    CGRect shadowRect = CGRectInset(self.backgroundView.bounds, 9, -10);
    shadowRect.origin.x -= 9;
    
    if(indexPath.row == 0){
        shadowRect.origin.y += 10;
        maskRect.origin.y -= 10;
        maskRect.size.height += 10;
    } else if(indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1){
        shadowRect.size.height -= 10;
        maskRect.size.height += 10;
    }
    
    [self addShadow:shadowRect maskRect:maskRect];
}

- (void)addShadow:(CGRect)shadowRect maskRect:(CGRect)maskRect
{
    CALayer *layer = self.backgroundView.layer;
    CAShapeLayer *mask = [CAShapeLayer layer];
    
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 1.5f;
    layer.shadowOpacity = 0.75f;
    layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
    layer.masksToBounds = NO;
    mask.path = [UIBezierPath bezierPathWithRect:maskRect].CGPath;
    layer.mask = mask;
}

@end
