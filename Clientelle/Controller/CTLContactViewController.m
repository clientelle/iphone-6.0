//
//  CTLContactFormViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 6/24/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "NSString+CTLString.h"

#import "CTLContactsListViewController.h"
#import "CTLContactImportViewController.h"
#import "CTLContactFormEditorViewController.h"

#import "CTLContactViewController.h"
#import "CTLCDFormSchema.h"
#import "CTLFieldCell.h"

#import "CTLABPerson.h"
#import "CTLCDPerson.h"

#import "CTLTooltipView.h"

NSString *const CTLContactFormEditorSegueIdentifyer = @"toContactFormEditor";

@implementation CTLContactViewController

#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _addressbookChangeDidComeFromApp = NO;
    
    if(self.contact){
        self.navigationItem.title = NSLocalizedString(@"EDIT_CONTACT", nil);
    }else{
        self.navigationItem.title = NSLocalizedString(@"ADD_CONTACT", nil);
    }

    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    
    [self buildSchema];
    [self createHeaderView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formDidChange:) name:CTLFormFieldAddedNotification object: nil];
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)]];
}

- (void)buildSchema
{
    if(!_cdFormSchema){
        _cdFormSchema = [CTLCDFormSchema MR_findFirst];
        if(!_cdFormSchema){
            _cdFormSchema = [CTLCDFormSchema MR_createEntity];
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        }
    }
    
    _fieldRows = [NSMutableArray array];
    _formSchema = [NSMutableArray array];
    _textFieldsDict = [NSMutableDictionary dictionary];
    _personDict = [NSMutableDictionary dictionary];
        
    if(!_formFields){
        _formFields = [[CTLCDFormSchema fieldsFromPlist:CTLABPersonSchemaPlist] mutableCopy];
    }

    for(NSUInteger i=0; i < [_formFields count]; i++){
        NSMutableDictionary *inputField = nil;
        NSString *field = _formFields[i][kCTLFieldName];
        NSString *newValue = _personDict[field];
        NSString *value = nil;
        NSString *label = nil;
        
        if(newValue){
            value = newValue;
        }else if(self.contact != nil){
            value = [[self.contact valueForKey:field] description];
            if(value){
                [_personDict setValue:value forKey:field];
            }
        }

        if([self fieldIsVisible:field]){
            inputField = [_formFields[i] mutableCopy];
            label = NSLocalizedString([inputField valueForKey:kCTLFieldName], nil);
            [inputField setValue:label forKey:kCTLFieldLabel];
            [inputField setValue:label forKey:kCTLFieldPlaceHolder];
            
            if(value){
                [inputField setValue:value forKey:kCTLFieldValue];
            }
            [_fieldRows addObject:inputField];
        }
    }
}

- (BOOL)fieldIsVisible:(NSString *)fieldName
{
    return [[_cdFormSchema valueForKey:fieldName] isEqualToNumber:[NSNumber numberWithBool:YES]];
}

- (void)setPersonDictionary
{
    NSArray *fields = [NSArray arrayWithArray:_fieldRows];
    [fields enumerateObjectsUsingBlock:^(id input, NSUInteger idx, BOOL *stop){
        [_personDict setValue:input[kCTLFieldValue] forKey:input[kCTLFieldName]];
    }];
}

/*
- (void)addressBookDidChange:(NSNotification *)notification
{
    //if changes came from app or user has no pending changes, simply reload the form view
    if(_addressbookChangeDidComeFromApp){
        [self reloadFormViewAfterAddressBookChange];
        return;
    }
    
    ABRecordID personID = [self.contact recordID];
    NSString *personName = [self.contact firstName];
    
    CFErrorRef error;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    self.addressBookRef = addressBookRef;
    CTLABPerson *abPerson = [[CTLABPerson alloc] initWithRecordID:personID withAddressBookRef:addressBookRef];
        
    if(!self.contact){
        [CTLCDPerson deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"recordID=%i", personID]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"CONTACT_WAS_DELETED", nil), personName]
                                                       delegate:self
                                              cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }else{
        [self reloadFormViewAfterAddressBookChange];
    }
}*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CTLContactListReloadNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadFormViewAfterAddressBookChange
{
    [_personDict removeAllObjects];
    [self buildSchema];
    [self.tableView reloadData];
}

#pragma mark - TableViewController Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fieldRows count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"inputRow";
    CTLFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
    if (cell == nil) {
        cell = [[CTLFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    NSMutableDictionary *field = _fieldRows[indexPath.row];
    cell.textInput.tag = indexPath.row;
    cell.textInput.text = field[kCTLFieldValue];
    cell.textInput.placeholder = field[kCTLFieldPlaceHolder];
        
    UIKeyboardType keyboardType = (UIKeyboardType)[field[kCTLFieldKeyboardType] intValue];
    if(keyboardType != UIKeyboardTypeEmailAddress){
        cell.textInput.autocapitalizationType = UITextAutocapitalizationTypeWords;
        cell.textInput.autocorrectionType = UITextAutocorrectionTypeYes;
    }

    if([field[kCTLFieldName] isEqualToString:CTLPersonNoteProperty]){
        cell.textInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    }
    
    if([field[kCTLFieldName] isEqualToString:CTLAddressStateProperty]){
        cell.textInput.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    }
    
    [cell.textInput setKeyboardType:keyboardType];
    //[cell.textInput addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingChanged];
    
    [_textFieldsDict setValue:cell.textInput forKey:field[kCTLFieldName]];
    
    return cell;
}

- (void)createHeaderView
{
    if(self.contact){
        if([self.contact recordID]){ //has addressbook ID
            [self setPrivateButtonInactive:self.privateButton];
        }else{
            [self setPrivateButtonActive:self.privateButton];
        }
    }else{
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"display_private_tooltip_once"]){
            [self setPrivateButtonInactive:self.privateButton];
            [self createPrivateTooltipWithMessage:NSLocalizedString(@"PRIVATE_TOOLTIP_MSG", nil)];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"display_private_tooltip_once"];
        }else{
            [self setPrivateButtonActive:self.privateButton];
        }
    }
}

- (void)createPrivateTooltipWithMessage:(NSString *)message
{
    if(_privateTooltip){
        [_privateTooltip removeFromSuperview];
    }
    _privateTooltip = [[CTLTooltipView alloc] initWithFrame:CGRectMake(138, 35, 175.0f, 40.0f)];
    [_privateTooltip setTipText:message];
    [self.tableView addSubview:_privateTooltip];
}

- (void)setPrivateButtonActive:(UIButton *)button
{
    _isPrivate = YES;
    self.contactsTitleLabel.text = NSLocalizedString(@"PRIVATE_CONTACT", nil);
    
    if(self.contact){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [button setImage:[UIImage imageNamed:@"key-private"] forState:UIControlStateNormal];
    [button removeTarget:self action:@selector(togglePrivateButtonActive:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(togglePrivateButtonInactive:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setPrivateButtonInactive:(UIButton *)button
{
    _isPrivate = NO;
    self.contactsTitleLabel.text = NSLocalizedString(@"CONTACT_INFO", nil);
    
    if(self.contact){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [button setImage:[UIImage imageNamed:@"key-public"] forState:UIControlStateNormal];
    [button removeTarget:self action:@selector(togglePrivateButtonInactive:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(togglePrivateButtonActive:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)togglePrivateButtonActive:(UIButton *)button
{
    [self createPrivateTooltipWithMessage:NSLocalizedString(@"CONTACT_IS_NOW_PRIVATE", nil)];
    [self performSelector:@selector(autoDismissTootlip:) withObject:_privateTooltip afterDelay:2.0];
    [self setPrivateButtonActive:button];
}

- (void)togglePrivateButtonInactive:(UIButton *)button
{
    [self createPrivateTooltipWithMessage:NSLocalizedString(@"CONTACT_IS_NO_LONGER_PRIVATE", nil)];
    [self performSelector:@selector(autoDismissTootlip:) withObject:_privateTooltip afterDelay:2.0];
    [self setPrivateButtonInactive:button];
}

- (void)autoDismissTootlip:(id)sender
{
    UIView *tooltip = (UIView *)sender;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [UIView setAnimationDelegate:self];
    tooltip.alpha = 0.0f;
    [UIView commitAnimations];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:CTLContactFormEditorSegueIdentifyer]){
        CTLContactFormEditorViewController *formEditorViewController = [segue destinationViewController];
        [formEditorViewController setFormSchema:_cdFormSchema];
        [formEditorViewController setFieldsFromPList:_formFields];
    }
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)submit:(id)sender
{
    [self setPersonDictionary];
    
    if(![CTLABPerson validateContactInfo:_personDict]){
        NSArray *fields = [NSArray arrayWithArray:_fieldRows];
        [fields enumerateObjectsUsingBlock:^(id input, NSUInteger idx, BOOL *stop){
            NSString *fieldKey = input[kCTLFieldName];
            //light up required fields
            if([fieldKey isEqualToString:CTLPersonFirstNameProperty] ||
               [fieldKey isEqualToString:CTLPersonLastNameProperty] ||
               [fieldKey isEqualToString:CTLPersonEmailProperty] ||
               [fieldKey isEqualToString:CTLPersonPhoneProperty]){
                
                UITextField *textField = (UITextField *)_textFieldsDict[fieldKey];
                if([textField.text length] == 0){
                    textField.backgroundColor = [UIColor ctlInputErrorBackground];
                }
            }
        }];
        [self.view endEditing:YES];
        return;
    }
    
    /*
    if([self fieldIsVisible:CTLPersonAddressProperty]){
        [self setAddressDictionary];
        [_personDict setValue:_addressDict forKey:CTLPersonAddressProperty];
    }*/
    //TODO: Get AB Person and upate CD

    if(!self.contact){
        self.contact = [CTLCDPerson MR_createEntity];
        [self.contact updatePerson:_personDict];
        
        __block CTLABPerson *abPerson = nil;
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        
        if(_isPrivate == NO){
            abPerson = [[CTLABPerson alloc] initWithDictionary:_personDict withAddressBookRef:self.addressBookRef];
            [self.contact setRecordIDValue:abPerson.recordID];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CTLNewContactWasAddedNotification object:self.contact];
    }else{

        [self.contact updatePerson:_personDict];
        
        __block CTLABPerson *abPerson = nil;
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        
        if(_isPrivate == NO){
            abPerson = [[CTLABPerson alloc] initWithRecordID:self.contact.recordID withAddressBookRef:self.addressBookRef];
            [abPerson updateWithDictionary:_personDict];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:CTLContactRowDidChangeNotification object:self.contact];
    }
    
    //set flag to notifiy that changes came from within the app
    _addressbookChangeDidComeFromApp = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)formDidChange:(NSNotification *)notification{
    _formSchema = [CTLCDFormSchema MR_findFirst];
    [self buildSchema];
    [self.tableView reloadData];
}

- (IBAction)dismissKeyboard:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

- (IBAction)highlightTextField:(UITextField *)textField
{
    [self.focusedTextField setBackgroundColor:[UIColor clearColor]];
    [textField setBackgroundColor:[UIColor ctlFadedGray]];
    self.focusedTextField = textField;
    [self performSelector:@selector(autoDismissTootlip:) withObject:_privateTooltip afterDelay:0.25];
}

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    //clear all inputs of error background
    NSArray *fields = [NSArray arrayWithArray:_fieldRows];
    [fields enumerateObjectsUsingBlock:^(id input, NSUInteger idx, BOOL *stop){
        UITextField *textField = (UITextField *)_textFieldsDict[input[kCTLFieldName]];
        textField.backgroundColor = [UIColor clearColor];
    }];
    
    if(textField.keyboardType == UIKeyboardTypePhonePad){
        textField.text = [NSString formatPhoneNumber:textField.text];
    }

    [_fieldRows[textField.tag] setValue:textField.text forKey:kCTLFieldValue];
    [self setPersonDictionary];
}

- (IBAction)showAddFieldsModal:(id)sender
{
    [self performSegueWithIdentifier:CTLContactFormEditorSegueIdentifyer sender:sender];
}

- (void)registerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookDidChange:) name:kAddressBookDidChange object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTLFormFieldAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddressBookDidChange object:nil];
}

@end
