//
//  CTLContactDetailsViewController.h
//  Clientelle
//
//  Created by Kevin on 7/24/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

@class CTLCDContact;

@interface CTLContactDetailsViewController : UITableViewController<UIActionSheetDelegate, UIGestureRecognizerDelegate>{
    NSArray *_fields;
    NSMutableDictionary *_formValues;
    NSMutableArray *_enabledFields;
}

@property(nonatomic, strong) CTLCDContact *contact;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *saveContactButton;
@property(nonatomic, weak) IBOutlet UIView *footerView;
@property(nonatomic, weak) IBOutlet UIButton *editFormButton;

- (IBAction)submit:(id)sender;
- (IBAction)dismissKeyboard:(UITapGestureRecognizer *)recognizer;
- (IBAction)showAddFieldsModal:(id)sender;
- (IBAction)textFieldDidChange:(UITextField *)textField;

@end
