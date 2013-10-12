//
//  CTLMenuItemCell.h
//  Clientelle
//
//  Created by Kevin Liu on 3/10/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const CTLMainMenuCellHeight;

@interface CTLMenuItemCell : UITableViewCell{
    CALayer *_topBorder;
    CALayer *_bottomBorder;
    UIColor *_topBorderColor;
    UIColor *_bottomBorderColor;
    UIColor *_activeCellColor;
    UIColor *_activeBottomBorderColor;
}

@property(nonatomic, strong) IBOutlet UIImageView *icon;

- (void)setActiveBorders:(BOOL)isLastCell;
- (void)resetBorders;

@end
