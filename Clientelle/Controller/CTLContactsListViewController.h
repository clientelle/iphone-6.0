//
//  CTLContactsListViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

extern int const CTLAllContactsGroupID;

extern NSString *const CTLContactsWereImportedNotification;
extern NSString *const CTLContactListReloadNotification;
extern NSString *const CTLTimestampForRowNotification;
extern NSString *const CTLNewContactWasAddedNotification;
extern NSString *const CTLContactRowDidChangeNotification;

@class CTLCDPerson;
@class CTLContactToolbarView;
@class CTLContactHeaderView;
@class CTLPickerView;

@interface CTLContactsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CTLSlideMenuDelegate, UISearchDisplayDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>{
    ABAddressBookRef _addressBookRef;
    CTLPickerView *_sortPickerView;
    NSArray *_sortArray;
        
    NSArray *_contacts;
    NSMutableArray *_filteredContacts;

    UISearchDisplayController *_searchController;
    
    UIView *_emptyView;
    BOOL _inContactMode;
    NSIndexPath *_selectedIndexPath;
    CTLCDPerson *_selectedPerson;
    
    BOOL _shouldReorderListOnScroll;
}

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) CTLSlideMenuController *menuController;
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, strong) CTLContactHeaderView *contactHeader;
@property (nonatomic, strong) CTLContactToolbarView *contactToolbar;

- (IBAction)dismissSortPickerFromTap:(UITapGestureRecognizer *)recognizer;

@end
