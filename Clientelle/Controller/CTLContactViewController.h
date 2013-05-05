//
//  CTLContactFormViewController.h
//  Clientelle
//
//  Created by Kevin on 7/24/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import "CTLFieldCell.h"

@class CTLCDPerson;
@class CTLCDFormSchema;
@class KBPopupBubbleView;

@interface CTLContactViewController : UITableViewController<UIActionSheetDelegate, UIGestureRecognizerDelegate>{
    ABAddressBookRef _addressBookRef;
    CTLCDFormSchema *_formSchema;
    NSMutableArray *_fields;
    NSMutableArray *_enabledFields;
    NSMutableDictionary *_personDict;
    NSDictionary *_textFieldsDict;
    KBPopupBubbleView *_privateTooltip;
    
    BOOL _isPrivate;
}

/* CTLFieldCellDelegate */
@property (nonatomic, weak) UITextField *focusedTextField;
- (IBAction)highlightTextField:(UITextField *)textField;
- (IBAction)textFieldDidChange:(UITextField *)textField;

@property(nonatomic, weak) IBOutlet UIBarButtonItem *saveContactButton;

@property(nonatomic, assign) ABAddressBookRef addressBookRef;
@property(nonatomic, strong) CTLCDPerson *contact;
@property(nonatomic, strong) CTLCDFormSchema *formSchema;

@property(nonatomic, weak) IBOutlet UIView *headerView;
@property(nonatomic, weak) IBOutlet UIView *footerView;
@property(nonatomic, weak) IBOutlet UILabel *contactsTitleLabel;
@property(nonatomic, weak) IBOutlet UIButton *privateButton;
@property(nonatomic, weak) IBOutlet UIButton *editFormButton;


- (IBAction)togglePrivateButtonActive:(UIButton *)button;

- (IBAction)submit:(id)sender;
- (IBAction)dismissKeyboard:(UITapGestureRecognizer *)recognizer;
- (IBAction)showAddFieldsModal:(id)sender;
- (void)reloadFormViewAfterAddressBookChange;

@end
