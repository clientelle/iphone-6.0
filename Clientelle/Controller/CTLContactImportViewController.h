//
//  CTLContactImportViewController.h
//  Clientelle
//
//  Created by Kevin Liu 9/3/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLABGroup;

@interface CTLContactImportViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>{
    NSArray *_contacts;
    NSMutableArray *_filteredContacts;
    NSMutableDictionary *_selectedPeople;
    ABAddressBookRef _addressBookRef;
    UIColor *_textColor;
    UIColor *_disabledTextColor;
    UIColor *_selectedBackgroundColor;
}

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *busyIndicator;

@property(nonatomic, assign) ABAddressBookRef addressBookRef;

- (IBAction)importContacts:(id)sender;
- (IBAction)cancelImport:(id)sender;

@end
