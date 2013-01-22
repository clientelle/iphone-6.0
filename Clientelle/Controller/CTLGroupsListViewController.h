//
//  CTLGroupsListViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWSDetailPanel.h"

@interface CTLGroupsListViewController : UITableViewController<RWSDetailPanel>
@property (nonatomic, weak) RWSTwoPanelViewController *twoPanelViewController;

- (IBAction)showMenu:(id)sender;

@end
