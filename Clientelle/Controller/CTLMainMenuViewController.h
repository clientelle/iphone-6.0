//
//  CTLMainMenuViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const CTLMenuPlistName;

@interface CTLMainMenuViewController : UITableViewController<CTLSlideMenuDelegate>{
    NSArray *_menuItems;
    NSIndexPath *_selectedIndexPath;
}

- (void)styleActiveCell:(NSIndexPath *)indexPath;

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, weak) CTLSlideMenuController *menuController;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end
