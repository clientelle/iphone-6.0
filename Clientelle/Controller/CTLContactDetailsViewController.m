//
//  CTLContactDetailsViewController.m
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

#import "CTLContactDetailsViewController.h"
#import "CTLFieldCell.h"
#import "CTLABPerson.h"
#import "CTLCDContact.h"
#import "CTLCDContactField.h"

NSString *const CTLContactFormEditorSegueIdentifyer = @"toContactFormEditor";

@implementation CTLContactDetailsViewController

#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([CTLCDContactField countOfEntities] == 0){
        [CTLCDContactField createFields];
    }
    
    [self buildContactForm];
    
    if(self.contact == nil){
        self.navigationItem.title = NSLocalizedString(@"ADD_CONTACT", nil);
    }else{
        self.navigationItem.title = NSLocalizedString(@"EDIT_CONTACT", nil);
    }
 
    [self registerNotificationObservers];
    
    // Configure tableView
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)]];
}

- (void)buildContactForm
{
    _formValues = [NSMutableDictionary dictionary];
    _enabledFields = [NSMutableArray array];
    _fields = [CTLCDContactField fetchAllFields];
     
    for(NSUInteger i=0; i < [_fields count]; i++){
        CTLCDContactField *field = _fields[i];
        NSMutableDictionary *fieldDict = [self createField:field];
        [_formValues setValue:@"" forKey:field.field];
        if(self.contact){
            NSString *value = [[self.contact valueForKey:field.field] description];
            if(value){
                [_formValues setValue:value forKey:field.field];
                [fieldDict setValue:value forKey:kCTLFieldValue];
            }
        }
        
        if(field.enabledValue){
            [_enabledFields addObject:fieldDict];
        }
    }
}

- (void)reloadContactForm
{
    _enabledFields = [NSMutableArray array];
    for(NSUInteger i=0; i < [_fields count]; i++){
        CTLCDContactField *field = _fields[i];
        NSMutableDictionary *fieldDict = [self createField:field];
        [fieldDict setValue:_formValues[field.field] forKey:kCTLFieldValue];
        if(field.enabledValue){
            [_enabledFields addObject:fieldDict];
        }
    }
}

- (NSMutableDictionary *)createField:(CTLCDContactField *)field
{
    static NSArray *properties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        properties = [[[field entity] attributesByName] allKeys];
    });
    
    NSMutableDictionary *fieldDict = [[field dictionaryWithValuesForKeys:properties] mutableCopy];
    NSString *placeholder = [NSString stringWithFormat:@"CONTACT_PLACEHOLDER_%@", field.field];
    [fieldDict setValue:NSLocalizedString(placeholder, nil) forKey:kCTLFieldPlaceholder];
    [fieldDict setValue:@"" forKey:kCTLFieldValue];
    return fieldDict;
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
    
    return cell;
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submit:(id)sender
{
    __block BOOL isNew = NO;
    
    if(!self.contact){
        isNew = YES;
        self.contact = [CTLCDContact MR_createEntity];
    }
    
    for(NSString *field in _formValues){
        [self.contact setValue:_formValues[field] forKey:field];
    }
    
    self.contact.lastAccessed = [NSDate date];
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL result, NSError *error){
        if(isNew){
            [[NSNotificationCenter defaultCenter] postNotificationName:CTLNewContactWasAddedNotification object:self.contact];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:CTLContactRowDidChangeNotification object:self.contact]; 
        }
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)formDidChange:(NSNotification *)notification
{
    [self reloadContactForm];
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
    
    [_formValues setValue:textField.text forKey:_enabledFields[textField.tag][kCTLFieldName]];
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
