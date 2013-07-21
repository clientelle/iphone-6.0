//
//  CTLAccountsViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 7/20/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLAccountsViewController : UITableViewController<NSFetchedResultsControllerDelegate, CTLContainerViewDelegate>


@property (nonatomic, weak) CTLContainerViewController *containerView;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end
