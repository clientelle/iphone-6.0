//
//  CTLMainMenuViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWSSlideMenuViewDelegate.h"

extern NSString *const CTLMenuPlistName;

@interface CTLMainMenuViewController : UITableViewController<RWSSlideMenuViewDelegate>{
    NSArray *_menuItems;
}

@property (nonatomic, weak) RWSSliderMenuViewController *twoPanelViewController;

@end
