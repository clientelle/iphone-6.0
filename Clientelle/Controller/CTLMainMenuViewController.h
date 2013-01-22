//
//  CTLMainMenuViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWSPanelController.h"

@interface CTLMainMenuViewController : UITableViewController<RWSPanelController>{
    NSArray *_menuItems;
}

@property (nonatomic, weak) RWSTwoPanelViewController *twoPanelViewController;

@end
