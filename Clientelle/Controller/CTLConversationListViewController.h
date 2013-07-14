//
//  CTLConversationListViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 4/30/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CTLConversationListViewController : UITableViewController<NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, CTLContainerViewDelegate>{
}

@property (nonatomic, weak) CTLContainerViewController *containerView;
@property (nonatomic, strong) IBOutlet UIView *emptyMessageView;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;

- (IBAction)composeMessage:(id)sender;

@end
