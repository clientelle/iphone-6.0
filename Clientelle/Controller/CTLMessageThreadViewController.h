//
//  CTLThreadViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 4/30/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLCDConversation;

@interface CTLMessageThreadViewController : UITableViewController<NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, CTLContainerViewDelegate>

@property (nonatomic, weak) CTLContainerViewController *containerView;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) CTLCDConversation *conversation;

- (IBAction)composeMessage:(id)sender;

@end
