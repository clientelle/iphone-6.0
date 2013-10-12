//
//  CTLConversationListViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 4/30/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLMessageUpgradeView;

@interface CTLConversationListViewController : UITableViewController<NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, CTLContainerViewDelegate>

@property (nonatomic, weak) CTLContainerViewController *containerView;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end
