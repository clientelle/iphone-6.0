//
//  CTLProspectFormViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 8/10/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLFiveStarRater;

@interface CTLProspectFormViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>{
    NSArray *_fields;
    NSMutableDictionary *_prospectDict;
    CTLFiveStarRater *_rater;
    NSString *_countryCode;
    ABAddressBookRef _addressBookRef;
}

@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
