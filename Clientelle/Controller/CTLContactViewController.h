//
//  CTLContactFormViewController.h
//  Clientelle
//
//  Created by Kevin on 7/24/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//
#import <AddressBookUI/AddressBookUI.h>

@class CTLABGroup;
@class CTLABPerson;
@class CTLCDFormSchema;

@interface CTLContactViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>{
    BOOL _addressbookChangeDidComeFromApp;
    ABAddressBookRef _addressBookRef;
    CTLCDFormSchema *_cdFormSchema;
     
    NSMutableDictionary *_personDict;
    
    NSArray *_formFields;
    NSMutableArray *_formSchema;
    NSMutableArray *_fieldRows;
    
    BOOL _showAddress;
    NSArray *_addressFields;
    NSMutableArray *_addressRows;
    NSMutableDictionary *_addressDict;
    
    UITextField *_focusedTextField;
}

@property(nonatomic, assign) ABAddressBookRef addressBookRef;
@property(nonatomic, strong) CTLABPerson *abPerson;
@property(nonatomic, strong) CTLABGroup *abGroup;
@property(nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *saveContactButton;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)submit:(id)sender;
- (IBAction)cancel:(id)sender;

- (IBAction)dismissKeyboard:(UITapGestureRecognizer *)recognizer;
- (void)reloadFormViewAfterAddressBookChange;

@end
