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

extern NSString *const CTLContactWereImportedNotification;
extern NSString *const CTLContactListReloadNotification;
extern NSString *const CTLTimestampForRowNotification;
extern NSString *const CTLNewContactWasAddedNotification;
extern NSString *const CTLContactRowDidChangeNotification;

@class CTLABGroup;
@class CTLABPerson;
@class CTLContactToolbarView;
@class CTLContactHeaderView;

@interface CTLContactsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CTLSlideMenuDelegate, UISearchDisplayDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>{
    
    ABAddressBookRef _addressBookRef;
    
    BOOL _groupPickerIsVisible;
    UIPickerView *_groupPickerView;
    NSMutableArray *_groupArray;
        
    NSMutableArray *_contacts;
    NSMutableArray *_filteredContacts;
    NSMutableDictionary *_accessedDictionary;
    NSMutableDictionary *_contactsDictionary;
    
    UIView *_emptyView;
    BOOL _inContactMode;
    NSIndexPath *_selectedIndexPath;
    CTLABPerson *_selectedPerson;
    
    BOOL _shouldReorderListOnScroll;
}

@property (nonatomic, weak) CTLSlideMenuController *menuController;
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, strong) CTLContactHeaderView *contactHeader;
@property (nonatomic, strong) CTLContactToolbarView *contactToolbar;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)dismissGroupPickerFromTap:(UITapGestureRecognizer *)recognizer;

@end
