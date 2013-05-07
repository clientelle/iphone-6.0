//
//  CTLContactFormViewController.h
//  Clientelle
//
//  Created by Kevin on 7/24/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

@class CTLCDContact;
@class CTLABPerson;
@class CTLCDFormSchema;

@interface CTLContactViewController : UITableViewController<UIActionSheetDelegate, UIGestureRecognizerDelegate>{
    CTLCDFormSchema *_formSchema;
    NSMutableArray *_fields;
    NSMutableArray *_enabledFields;
    NSDictionary *_textFieldsDict;
    BOOL _isNewContact;
}

@property(nonatomic, weak) IBOutlet UIBarButtonItem *saveContactButton;

@property(nonatomic, assign) ABAddressBookRef addressBookRef;
@property(nonatomic, strong) CTLCDContact *contact;
@property(nonatomic, strong) CTLABPerson *person;
@property(nonatomic, strong) CTLCDFormSchema *formSchema;

@property(nonatomic, weak) IBOutlet UIView *footerView;
@property(nonatomic, weak) IBOutlet UIButton *editFormButton;

- (IBAction)submit:(id)sender;
- (IBAction)dismissKeyboard:(UITapGestureRecognizer *)recognizer;
- (IBAction)showAddFieldsModal:(id)sender;
- (IBAction)textFieldDidChange:(UITextField *)textField;

@end
