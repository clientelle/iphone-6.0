//
//  CTLContactsListViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

extern NSString *const CTLContactsWereImportedNotification;
extern NSString *const CTLTimestampForRowNotification;
extern NSString *const CTLNewContactWasAddedNotification;
extern NSString *const CTLContactRowDidChangeNotification;
extern NSString *const CTLImporterSegueIdentifier;
extern NSString *const CTLContactFormSegueIdentifier;

@class CTLCDContact;
@class CTLContactToolbarView;
@class CTLContactHeaderView;
@class CTLPickerView;
@class KBPopupBubbleView;

@interface CTLContactsListViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CTLSlideMenuDelegate, UISearchDisplayDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>{
    
    NSIndexPath *_selectedIndexPath;
    CTLCDContact *_selectedPerson;
    
    CTLPickerView *_sortPickerView;
    NSArray *_sortArray;
    NSMutableArray *_filteredContacts;
    
    UIView *_emptyView;
    BOOL _inContactMode;
    BOOL _shouldReorderListOnScroll;
    
    UISearchDisplayController *_searchController;
    
    KBPopupBubbleView *_sortTooltip;
}

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) CTLSlideMenuController *menuController;
@property (nonatomic, strong) CTLContactHeaderView *contactHeader;
@property (nonatomic, strong) CTLContactToolbarView *contactToolbar;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)dismissSortPickerFromTap:(UITapGestureRecognizer *)recognizer;

@end
