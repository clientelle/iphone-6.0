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

#import "KBPopupBubbleView.h"

NSString *const CTLContactFormEditorSegueIdentifyer = @"toContactFormEditor";

@implementation CTLContactViewController

#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createHeaderView];
    [self buildContactForm];
    
    if(self.contact){
        self.navigationItem.title = NSLocalizedString(@"EDIT_CONTACT", nil);
        [self populateContactForm];
    }else{
        self.navigationItem.title = NSLocalizedString(@"ADD_CONTACT", nil);
        //if(![[NSUserDefaults standardUserDefaults] boolForKey:@"display_private_tooltip_once"]){
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(displayInitialTooltip:) userInfo:nil repeats:NO];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"display_private_tooltip_once"];
        //}
    }
 
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)]];
    
    [self registerNotificationObservers];
}

- (void)buildContactForm
{
    _formSchema = [CTLCDFormSchema MR_findFirst];
    if(!_formSchema){
        _formSchema = [CTLCDFormSchema MR_createEntity];
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context MR_saveToPersistentStoreAndWait];
    }
    
    _fields = [NSMutableArray array];
    _textFieldsDict = [NSMutableDictionary dictionary];
    
    NSMutableArray *fieldsList = [[CTLCDFormSchema fieldsFromPlist:CTLContactFormSchema] mutableCopy];
    NSMutableIndexSet *enabledIndexes = [[NSMutableIndexSet alloc] init];

    for(NSUInteger i=0; i < [fieldsList count]; i++){

        NSMutableDictionary *inputField = [fieldsList[i] mutableCopy];
        BOOL isEnabled = [_formSchema fieldIsVisible:inputField[kCTLFieldName]];
    
        NSString *translatedLabelKey = [NSString stringWithFormat:@"CONTACT_LABEL_%@", [inputField valueForKey:kCTLFieldName]];
        [inputField setValue:[inputField valueForKey:kCTLFieldName] forKey:kCTLFieldName];
        [inputField setValue:NSLocalizedString(translatedLabelKey, nil) forKey:kCTLFieldPlaceholder];
        [inputField setValue:@(isEnabled) forKey:kCTLFieldEnabled];
        
        fieldsList[i] = inputField;
        [_fields addObject:inputField];
        
        if(isEnabled){
            [enabledIndexes addIndex:i];
        }
    }

    _enabledFields = [[_fields objectsAtIndexes:enabledIndexes] mutableCopy];
}

- (void)populateContactForm
{
    _personDict = [NSMutableDictionary dictionary];
    
    for(NSUInteger i=0; i < [_enabledFields count]; i++){
        NSString *field = _enabledFields[i][kCTLFieldName];
        NSString *value = [[self.contact valueForKey:field] description];
        
        if(value){
            [_personDict setValue:value forKey:field];
        }
        
        if([self fieldIsVisible:field]){
            NSMutableDictionary *inputField = [_enabledFields[i] mutableCopy];
            if(value){
                [inputField setValue:value forKey:kCTLFieldValue];
                _enabledFields[i] = inputField;
            }
         }
    }
}

- (BOOL)fieldIsVisible:(NSString *)fieldName
{
    return [[_formSchema valueForKey:fieldName] isEqualToNumber:[NSNumber numberWithBool:YES]];
}

- (void)setPersonDictionary
{
    for(NSUInteger i=0; i < [_enabledFields count]; i++){
       [_personDict setValue:_enabledFields[i][kCTLFieldValue] forKey:_enabledFields[i][kCTLFieldName]];
    }
}

- (void)reloadFormViewAfterAddressBookChange
{
    [_personDict removeAllObjects];
    [self buildContactForm];
    [self.tableView reloadData];
}

#pragma mark - Something
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:CTLContactFormEditorSegueIdentifyer]){
        CTLContactFormEditorViewController *viewController = [segue destinationViewController];
        if(_fields){
            [viewController setFormSchema:_formSchema];
            [viewController setFields:_fields];
        }
    }
}


#pragma mark - TableViewController Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_enabledFields count];
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

    NSMutableDictionary *field = _enabledFields[indexPath.row];
    
    cell.textInput.tag = indexPath.row;
    cell.textInput.text = field[kCTLFieldValue];
    cell.textInput.placeholder = field[kCTLFieldPlaceholder];
        
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
        if([self.contact isPrivateValue]){
            [self togglePrivateButtonActive:self.privateButton];
        }else{
            [self togglePrivateButtonInactive:self.privateButton];
        }
    }else{
        [self togglePrivateButtonActive:self.privateButton];
    }
}

- (void)displayInitialTooltip:(id)userInfo
{
    if(_privateTooltip){
        [_privateTooltip removeFromSuperview];
    }
    _privateTooltip = [[KBPopupBubbleView alloc] initWithFrame:CGRectMake(158.0f, 35.0f, 162.0f, 40.0f) text:NSLocalizedString(@"PRIVATE_TOOLTIP", nil)];
    
    [_privateTooltip setPosition:1 animated:NO];
    [_privateTooltip setSide:kKBPopupPointerSideTop];
    [_privateTooltip showInView:self.tableView animated:YES];
}

- (IBAction)togglePrivateButtonActive:(UIButton *)button
{
    _isPrivate = YES;
    self.contactsTitleLabel.text = NSLocalizedString(@"PRIVATE_CONTACT", nil);
    
    if(self.contact){
        [self.contact setIsPrivate:@(1)];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [button setImage:[UIImage imageNamed:@"key-private"] forState:UIControlStateNormal];
    [button removeTarget:self action:@selector(togglePrivateButtonActive:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(togglePrivateButtonInactive:) forControlEvents:UIControlEventTouchUpInside];
    
    if(_privateTooltip){
        [_privateTooltip removeFromSuperview];
    }
}

- (void)togglePrivateButtonInactive:(UIButton *)button
{
    _isPrivate = NO;
    self.contactsTitleLabel.text = NSLocalizedString(@"CONTACT_INFO", nil);
    
    if(self.contact){
        [self.contact setIsPrivate:@(0)];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [button setImage:[UIImage imageNamed:@"key-public"] forState:UIControlStateNormal];
    [button removeTarget:self action:@selector(togglePrivateButtonInactive:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(togglePrivateButtonActive:) forControlEvents:UIControlEventTouchUpInside];
    
    if(_privateTooltip){
        [_privateTooltip removeFromSuperview];
    }
}

#pragma mark - Segue

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)submit:(id)sender
{
    [self setPersonDictionary];
    
    if(![CTLABPerson validateContactInfo:_personDict]){
        NSArray *fields = [NSArray arrayWithArray:_enabledFields];
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
        
        CTLABPerson *abPerson = nil;
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        
        if(_isPrivate == NO){
            abPerson = [[CTLABPerson alloc] initWithRecordID:self.contact.recordID withAddressBookRef:self.addressBookRef];
            [abPerson updateWithDictionary:_personDict];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:CTLContactRowDidChangeNotification object:self.contact];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)formDidChange:(NSNotification *)notification
{
    [self buildContactForm];
    
    if(self.contact){
        [self populateContactForm];
    }
    
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
}

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    //clear all inputs of error background
    NSArray *fields = [NSArray arrayWithArray:_enabledFields];
    [fields enumerateObjectsUsingBlock:^(id input, NSUInteger idx, BOOL *stop){
        UITextField *textField = (UITextField *)_textFieldsDict[input[kCTLFieldName]];
        textField.backgroundColor = [UIColor clearColor];
    }];
    
    if(textField.keyboardType == UIKeyboardTypePhonePad){
        textField.text = [NSString formatPhoneNumber:textField.text];
    }

    [_enabledFields[textField.tag] setValue:textField.text forKey:kCTLFieldValue];
    [self setPersonDictionary];
}

- (IBAction)showAddFieldsModal:(id)sender
{
    [self performSegueWithIdentifier:CTLContactFormEditorSegueIdentifyer sender:sender];
}

- (void)registerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formDidChange:) name:CTLFormFieldAddedNotification object: nil];
}

- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:CTLFormFieldAddedNotification object:nil];
}

@end
