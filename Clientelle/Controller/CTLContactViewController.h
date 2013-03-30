//
//  CTLContactFormViewController.h
//  Clientelle
//
//  Created by Kevin on 7/24/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//
#import <AddressBookUI/AddressBookUI.h>
#import "CTLFieldCell.h"

@class CTLABGroup;
@class CTLABPerson;
@class CTLCDFormSchema;

@interface CTLContactViewController : UITableViewController<CTLFieldCellDelegate>{
    BOOL _addressbookChangeDidComeFromApp;
    ABAddressBookRef _addressBookRef;
    CTLCDFormSchema *_cdFormSchema;
    NSMutableDictionary *_personDict;
    NSArray *_formFields;
    NSMutableArray *_formSchema;
    NSMutableArray *_fieldRows;
    NSDictionary *_textFieldsDict;
    BOOL _showAddress;
    NSArray *_addressFields;
    NSMutableArray *_addressRows;
    NSMutableDictionary *_addressDict;
}

/* CTLFieldCellDelegate */
@property (nonatomic, weak) UITextField *focusedTextField;
- (IBAction)highlightTextField:(UITextField *)textField;
- (IBAction)textFieldDidChange:(UITextField *)textField;

@property(nonatomic, weak) IBOutlet UIBarButtonItem *saveContactButton;

@property(nonatomic, assign) ABAddressBookRef addressBookRef;
@property(nonatomic, strong) CTLABPerson *abPerson;
@property(nonatomic, strong) CTLABGroup *abGroup;

- (IBAction)submit:(id)sender;
- (IBAction)dismissKeyboard:(UITapGestureRecognizer *)recognizer;

- (void)reloadFormViewAfterAddressBookChange;

@end
