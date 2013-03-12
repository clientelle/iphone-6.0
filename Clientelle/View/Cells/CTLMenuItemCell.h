//
//  CTLMenuItemCell.h
//  Clientelle
//
//  Created by Kevin Liu on 3/10/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLMenuItemCell : UITableViewCell{
    CALayer *_topBorder;
    CALayer *_bottomBorder;
}

- (void)setActiveBorders:(BOOL)isLast;
- (void)resetBorders;
- (void)lastBorder;

@end
