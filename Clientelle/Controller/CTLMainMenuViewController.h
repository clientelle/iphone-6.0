//
//  CTLMainMenuViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLCDAccount;

@interface CTLMainMenuViewController : UITableViewController{
    NSIndexPath *_selectedIndexPath;
    CTLCDAccount *_account;
}

- (void)styleActiveCell:(NSIndexPath *)indexPath;

@property (nonatomic, strong) CTLSlideMenuController *menuController;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;


@end
