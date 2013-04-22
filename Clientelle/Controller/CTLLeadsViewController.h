//
//  CTLLeadsViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 4/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLLeadsViewController : UITableViewController<CTLSlideMenuDelegate>

@property (nonatomic, weak) CTLSlideMenuController *menuController;

@end
