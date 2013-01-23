//
//  CTLSettingsViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLSettingsViewController : UITableViewController<CTLSlideMenuDelegate>
@property (nonatomic, weak) CTLSlideMenuController *menuController;

@end
