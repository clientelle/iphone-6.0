//
//  CTLContactsListViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "CTLContactHeaderView.h"
#import "CTLContactToolbarView.h"

extern NSString *const CTLContactsWereImportedNotification;
extern NSString *const CTLTimestampForRowNotification;
extern NSString *const CTLNewContactWasAddedNotification;
extern NSString *const CTLContactRowDidChangeNotification;
extern NSString *const CTLImporterSegueIdentifier;
extern NSString *const CTLContactFormSegueIdentifier;

@class CTLContactToolbarView;

@interface CTLContactsListViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, CTLContainerViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, CTLContactHeaderDelegate, CTLContactToolbarDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) CTLContainerViewController *containerView;
@property (nonatomic, strong) CTLContactHeaderView *contactHeader;
@property (nonatomic, strong) CTLContactToolbarView *contactToolbar;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
