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
#import "CTLFieldCell.h"
#import "CTLABPerson.h"
#import "CTLCDContact.h"
#import "CTLCDContactField.h"

NSString *const CTLContactFormEditorSegueIdentifyer = @"toContactFormEditor";

@implementation CTLContactViewController

#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(self.contact == nil){
        _isNewContact = YES;
        self.navigationItem.title = NSLocalizedString(@"ADD_CONTACT", nil);
        self.contact = [CTLCDContact MR_createEntity];
        [self buildContactForm];
    }else{
        _isNewContact = NO;
        self.navigationItem.title = NSLocalizedString(@"EDIT_CONTACT", nil);
        [self buildContactForm];
        [self populateContactForm];
    }

    [self registerNotificationObservers];
    
    // Configure tableView
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)]];
}

-(void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        /*
         * When user taps "back" before creating new contact,
         * destroy the temporary contact so it doesn't get created
         */
        if(!self.contact.lastAccessed){
            [self.contact deleteEntity];
        }
    }

    [super viewWillDisappear:animated];
}

- (void)buildContactForm
{
    _fields = [NSMutableArray array];
    _textFieldsDict = [NSMutableDictionary dictionary];
    
    NSArray *fieldsArray = [CTLCDContactField fetchSortedFields];
    
    if([fieldsArray count] == 0){
        fieldsArray = [CTLCDContactField generateFieldsFromSchema:[self.contact entity]];
    }
    
    NSMutableIndexSet *enabledIndexes = [[NSMutableIndexSet alloc] init];
    NSArray *fieldKeys = [[[fieldsArray[0] entity] attributesByName] allKeys];
     
    for(NSUInteger i=0; i < [fieldsArray count]; i++){
        CTLCDContactField *row = fieldsArray[i];
        NSMutableDictionary *inputField = [[row dictionaryWithValuesForKeys:fieldKeys] mutableCopy];
        
        NSString *placeholder = [NSString stringWithFormat:@"CONTACT_PLACEHOLDER_%@", row.field];
        [inputField setValue:NSLocalizedString(placeholder, nil) forKey:kCTLFieldPlaceholder];
        
        [_fields addObject:inputField];
        
        if([[row valueForKey:kCTLFieldEnabled] isEqualToNumber:[NSNumber numberWithBool:YES]]){
            [enabledIndexes addIndex:i];
        }
    }
    
    _enabledFields = [[_fields objectsAtIndexes:enabledIndexes] mutableCopy];

}

- (void)populateContactForm
{
    for(NSUInteger i=0; i < [_enabledFields count]; i++){
        NSMutableDictionary *inputField = [_enabledFields[i] mutableCopy];
        NSString *value = [[self.contact valueForKey:_enabledFields[i][kCTLFieldName]] description];

        if([[inputField valueForKey:kCTLFieldEnabled] isEqualToNumber:[NSNumber numberWithBool:YES]]){
            if(value){
                [inputField setValue:value forKey:kCTLFieldValue];
                _enabledFields[i] = inputField;
            }
        }
    }
}

- (void)reloadFormViewAfterAddressBookChange
{
    [self buildContactForm];
    [self.tableView reloadData];
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
    
    cell.textInput.keyboardType = (UIKeyboardType)[field[kCTLFieldKeyboardType] intValue];
    cell.textInput.autocapitalizationType = (UITextAutocapitalizationType)[field[kCTLFieldAutoCapitalizeType] intValue];
    cell.textInput.autocorrectionType = (UITextAutocorrectionType)[field[kCTLFieldAutoCorrectionType] intValue];
        
//    UIKeyboardType keyboardType = (UIKeyboardType)[field[kCTLFieldKeyboardType] intValue];
//    
//    if(keyboardType != UIKeyboardTypeEmailAddress){
//        cell.textInput.autocapitalizationType = UITextAutocapitalizationTypeWords;
//        cell.textInput.autocorrectionType = UITextAutocorrectionTypeYes;
//    }
//
//    if([field[kCTLFieldName] isEqualToString:CTLPersonNoteProperty]){
//        cell.textInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
//    }
//
//    
//    [cell.textInput setKeyboardType:keyboardType];
    [_textFieldsDict setValue:cell.textInput forKey:field[kCTLFieldName]];
    
    return cell;
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submit:(id)sender
{
    self.contact.lastAccessed = [NSDate date];
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL result, NSError *error){
        if(_isNewContact){
            [[NSNotificationCenter defaultCenter] postNotificationName:CTLNewContactWasAddedNotification object:self.contact];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:CTLContactRowDidChangeNotification object:self.contact]; 
        }
    }];
    
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

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = YES;

    if(textField.keyboardType == UIKeyboardTypePhonePad){
        textField.text = [NSString formatPhoneNumber:textField.text];
    }
    
    [self.contact setValue:textField.text forKey:_enabledFields[textField.tag][kCTLFieldName]];
    [_enabledFields[textField.tag] setValue:textField.text forKey:kCTLFieldValue];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTLFormFieldAddedNotification object:nil];
}

@end
