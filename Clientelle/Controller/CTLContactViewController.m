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
#import "CTLCDFormSchema.h"
#import "CTLABPerson.h"
#import "CTLCDContact.h"

NSString *const CTLContactFormEditorSegueIdentifyer = @"toContactFormEditor";

@implementation CTLContactViewController

#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];


    [self buildContactForm];
    
    if(self.contact == nil){
        _isNewContact = YES;
        self.contact = [CTLCDContact MR_createEntity];
        self.navigationItem.title = NSLocalizedString(@"ADD_CONTACT", nil);
    }else{
        _isNewContact = NO;
        self.navigationItem.title = NSLocalizedString(@"EDIT_CONTACT", nil);
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
    _formSchema = [CTLCDFormSchema MR_findFirst];
    
    if(!_formSchema){
        _formSchema = [CTLCDFormSchema MR_createEntity];
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context MR_saveToPersistentStoreAndWait];
    }
    
    NSMutableArray *fieldsList = [[CTLCDFormSchema fieldsFromPlist:CTLContactFormSchemaPlist] mutableCopy];
    NSMutableIndexSet *enabledIndexes = [[NSMutableIndexSet alloc] init];

    for(NSUInteger i=0; i < [fieldsList count]; i++){

        NSMutableDictionary *inputField = [fieldsList[i] mutableCopy];
        BOOL isEnabled = [_formSchema fieldIsVisible:inputField[kCTLFieldName]];
        
        NSString *translatedLabelKey = [NSString stringWithFormat:@"CONTACT_LABEL_%@", [inputField valueForKey:kCTLFieldName]];
        NSString *translatedPlaceholderKey = [NSString stringWithFormat:@"CONTACT_PLACEHOLDER_%@", [inputField valueForKey:kCTLFieldName]];
        [inputField setValue:[inputField valueForKey:kCTLFieldName] forKey:kCTLFieldName];
        [inputField setValue:NSLocalizedString(translatedLabelKey, nil) forKey:kCTLFieldLabel];
        [inputField setValue:NSLocalizedString(translatedPlaceholderKey, nil) forKey:kCTLFieldPlaceholder];
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
    for(NSUInteger i=0; i < [_enabledFields count]; i++){
        NSString *field = _enabledFields[i][kCTLFieldName];
        NSString *value = [[self.contact valueForKey:field] description];

        if([_formSchema fieldIsVisible:field]){
            NSMutableDictionary *inputField = [_enabledFields[i] mutableCopy];
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
