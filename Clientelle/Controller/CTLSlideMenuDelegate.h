//
//  CTLSlideMenuDelegate.h
//  Created by Samuel Goodwin on 1/21/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTLSlideMenuController;

@protocol CTLSlideMenuDelegate <NSObject>
- (void)setMenuController:(CTLSlideMenuController *)controller;
@end
