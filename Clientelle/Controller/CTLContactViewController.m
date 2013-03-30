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
#import "CTLABGroup.h"
#import "CTLCDPerson.h"

#import "UITableViewCell+CellShadows.h"

NSString *const CTLContactFormEditorSegueIdentifyer = @"toContactFormEditor";

@implementation CTLContactViewController

#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _addressbookChangeDidComeFromApp = NO;
    
    if(self.abPerson){
        self.navigationItem.title = NSLocalizedString(@"EDIT_CONTACT", nil);
    }else{
        self.navigationItem.title = NSLocalizedString(@"ADD_CONTACT", nil);
    }
    
    if([self.abGroup groupID] == CTLAllContactsGroupID){
        ABRecordID defaultGroupID = [CTLABGroup clientGroupID];
        //check to make sure this group isn't nuked
        if([CTLABGroup groupDoesExist:defaultGroupID addressBookRef:_addressBookRef]){
            self.abGroup = [[CTLABGroup alloc] initWithGroupID:defaultGroupID addressBook:self.addressBookRef];
        }else{
            self.abGroup = [CTLABGroup getAnyGroup:self.addressBookRef];
        }
    }
    
    if(!_cdFormSchema){
        _cdFormSchema = [CTLCDFormSchema MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"groupID=%i", [self.abGroup groupID]]];
    }
    
    //if group was added from outside of the app, it needs to have a form schema
    if(!_cdFormSchema.groupID){
        _cdFormSchema = [CTLCDFormSchema MR_createEntity];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }
    
    [self buildSchema];
    _textFieldsDict = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formDidChange:) name:CTLFormFieldAddedNotification object: nil];
    
    
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookDidChange:) name:kAddressBookDidChange object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddressBookDidChange object:nil];
}

- (void)buildSchema
{
    _fieldRows = [NSMutableArray array];
    _formSchema = [NSMutableArray array];
    _addressRows = [NSMutableArray array];
    
    if(!_personDict){
        _personDict = [NSMutableDictionary dictionary];
    }
    
    if(!_addressDict){
        _addressDict = [NSMutableDictionary dictionary];
    }
    
    if(!_formFields){
        _formFields = [[CTLCDFormSchema fieldsFromPlist:CTLABPersonSchemaPlist] mutableCopy];
    }
    
    if(!_addressFields){
        _addressFields = [[CTLCDFormSchema fieldsFromPlist:CTLAddressSchemaPlist] mutableCopy];
    }
        
    _showAddress = [self fieldIsVisible:CTLPersonAddressProperty];
     
    for(NSUInteger i=0; i < [_formFields count]; i++){
        NSMutableDictionary *inputField = nil;
        NSString *field = _formFields[i][kCTLFieldName];
        NSString *newValue = _personDict[field];
        NSString *value = nil;
        NSString *label = nil;
        
        if(newValue){
            value = newValue;
        }else if(self.abPerson != nil){
            value = [[self.abPerson valueForKey:field] description];
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

    if(_showAddress){
        for(NSInteger k=0; k < [_addressFields count]; k++){
            NSMutableDictionary *inputField = [_addressFields[k] mutableCopy];
            NSString *field = _addressFields[k][kCTLFieldName];
            NSString *newValue = _addressDict[field];
            NSString *value = nil;
            NSString *label = NSLocalizedString([inputField valueForKey:kCTLFieldName], nil);
            
            [inputField setValue:label forKey:kCTLFieldLabel];
            [inputField setValue:label forKey:kCTLFieldPlaceHolder];
            
            if(newValue){
                value = newValue;
            }else if(self.abPerson != nil){
                value = [[[self.abPerson addressDict] valueForKey:field] description];
                if(value){
                    [inputField setValue:value forKey:kCTLFieldValue];
                }
            }
            [_addressRows addObject:inputField];
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

- (void)setAddressDictionary
{
    NSArray *fields = [NSArray arrayWithArray:_addressRows];
    [fields enumerateObjectsUsingBlock:^(id input, NSUInteger idx, BOOL *stop){
        [_addressDict setValue:input[kCTLFieldValue] forKey:input[kCTLFieldName]];
    }];
}

- (void)addressBookDidChange:(NSNotification *)notification
{
    //if changes came from app or user has no pending changes, simply reload the form view
    if(_addressbookChangeDidComeFromApp){
        [self reloadFormViewAfterAddressBookChange];
        return;
    }
    
    ABRecordID personID = [self.abPerson recordID];
    NSString *personName = [self.abPerson compositeName];
    
    CFErrorRef error;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    self.addressBookRef = addressBookRef;
    self.abPerson = [[CTLABPerson alloc] initWithRecordID:personID withAddressBookRef:addressBookRef];
        
    if(!self.abPerson){
        [CTLCDPerson deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"recordID=%i", personID]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"CONTACT_WAS_DELETED", nil), personName]
                                                       delegate:self
                                              cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }else{
        [self reloadFormViewAfterAddressBookChange];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CTLContactListReloadNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadFormViewAfterAddressBookChange
{
    [_personDict removeAllObjects];
    [_addressDict removeAllObjects];
    [self buildSchema];
    [self.tableView reloadData];
}

#pragma mark - TableViewController Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_showAddress){
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 1 && _showAddress){
        return [_addressRows count];
    }
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
    
    [cell addShadowToCellInTableView:tableView atIndexPath:indexPath];

    NSMutableDictionary *field = [NSMutableDictionary dictionary];
    if(indexPath.section == 0){
        field = _fieldRows[indexPath.row];
        cell.textInput.tag = indexPath.row;
    }else{
        field = _addressRows[indexPath.row];
        cell.textInput.tag = indexPath.row + [_fieldRows count];
    }
    
    cell.textInput.placeholder = field[kCTLFieldPlaceHolder];
    cell.textInput.text = field[kCTLFieldValue];
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 45.0f;
    }
    
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = nil;
    UILabel *headerLabel = nil;
    CGFloat width = self.tableView.bounds.size.width - 20.0f;
    
    if(section == 0){
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10.0f, width, 40.0f)];
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 15.0f, width, 20.0f)];
        [headerLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
        headerLabel.text = NSLocalizedString(@"CONTACT_INFO", nil);
        
        /** Private Button **/
        
        UIButton *gearButton = [self makeFooterButton];
        
        CGRect buttonFrame = gearButton.frame;
        buttonFrame.size.height = 30.0f;
        buttonFrame.size.width = 40.0f;
        buttonFrame.origin.y += 10.0f;
        buttonFrame.origin.x = self.tableView.bounds.size.width - (buttonFrame.size.width + 10);
        
        [gearButton setFrame:buttonFrame];
        [gearButton addTarget:self action:@selector(showAddFieldsModal:) forControlEvents:UIControlEventTouchUpInside];
        [gearButton setImage:[UIImage imageNamed:@"sm-wrench-gray.png"] forState:UIControlStateNormal];

        [headerView addSubview:gearButton];
        [headerView setBackgroundColor:[UIColor clearColor]];
    }
    
    if(section == 1){
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10.0f, width, 30.0f)];
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0, width, 20.0f)];
        headerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        headerLabel.text = NSLocalizedString(@"address", nil);
    }
    
    headerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor darkGrayColor];
    
    headerView.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(_showAddress && section == 0){
        return 0;
    }
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if((section == 0 && !_showAddress) || (section == 1 && _showAddress)){
        CGFloat buttonHeight = 30.0f;
        CGFloat buttonWidth = 60.0f;
        CGFloat labelWidth = 100.0f;
        CGFloat buttonPositionX = self.view.bounds.size.width/2 - buttonWidth/2;
        CGFloat labelPositionX = self.view.bounds.size.width/2 - labelWidth/2;
        
        UILabel *dashesLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelPositionX, 5, labelWidth, buttonHeight)];
        dashesLabel.backgroundColor = [UIColor clearColor];
        dashesLabel.textAlignment = NSTextAlignmentCenter;
        dashesLabel.text = @"-       -";
        
        UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonPositionX, 5, buttonWidth, buttonHeight)];
        [settingsButton setImage:[UIImage imageNamed:@"trash-grey.png"] forState:UIControlStateNormal];
        [settingsButton addTarget:self action:@selector(showAddFieldsModal:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30.0f)];
        [footerView addSubview:dashesLabel];
        [footerView addSubview:settingsButton];
        [footerView setBackgroundColor:[UIColor clearColor]];
        [footerView setAlpha:0.75];
        
        return footerView;
    }
    return nil;
}

- (UIButton *)makeFooterButton
{
    UIEdgeInsets insets = UIEdgeInsetsMake(18, 18, 18, 18);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonBGInactive = [[UIImage imageNamed:@"whiteButton.png"] resizableImageWithCapInsets:insets];
    UIImage *buttonBGActive = [[UIImage imageNamed:@"whiteButtonHighlight.png"] resizableImageWithCapInsets:insets];
    [button setBackgroundImage:buttonBGInactive forState:UIControlStateNormal];
    [button setBackgroundImage:buttonBGActive forState:UIControlStateHighlighted];
    
    return button;
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:CTLContactFormEditorSegueIdentifyer]){
        CTLContactFormEditorViewController *formEditorViewController = [segue destinationViewController];
        [formEditorViewController setFormSchema:_cdFormSchema];
        [formEditorViewController setFieldsFromPList:_formFields];
        [formEditorViewController setAbGroup:self.abGroup];
    }
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submit:(id)sender
{
    [self saveContactInfo];
}

- (void)saveContactInfo
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
    
    if(_showAddress){
        [self setAddressDictionary];
        [_personDict setValue:_addressDict forKey:CTLPersonAddressProperty];
    }

    if([self.abPerson recordID]){
        self.abPerson = [self.abPerson updateWithDictionary:_personDict];
        [self.abPerson setAccessDate:[NSDate date]];
        [[NSNotificationCenter defaultCenter] postNotificationName:CTLContactRowDidChangeNotification object:self.abPerson];
     }else{
        ABRecordID recordID = kABRecordInvalidID;
        self.abPerson = [[CTLABPerson alloc] initWithDictionary:_personDict withAddressBookRef:self.addressBookRef];
        recordID = [self.abPerson recordID];
        if(recordID != kABRecordInvalidID){
            [self.abPerson setAccessDate:[NSDate date]];
            [self.abGroup addMember:self.abPerson];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CTLNewContactWasAddedNotification object:self.abPerson];
    }
         
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordID=%i", [self.abPerson recordID]];
    CTLCDPerson *person = [CTLCDPerson MR_findFirstWithPredicate:predicate];
    if(!person){
        [CTLCDPerson createFromABPerson:self.abPerson];
    }else{
        [person updatePerson:_personDict];
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    
    //set flag to notifiy that changes came from within the app
    _addressbookChangeDidComeFromApp = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)formDidChange:(NSNotification *)notification{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"groupID=%i", [self.abGroup groupID]];
    _formSchema = [CTLCDFormSchema MR_findFirstWithPredicate:predicate inContext:localContext];
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
}

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    //clear all inputs of error background
    NSArray *fields = [NSArray arrayWithArray:_fieldRows];
    [fields enumerateObjectsUsingBlock:^(id input, NSUInteger idx, BOOL *stop){
        UITextField *textField = (UITextField *)_textFieldsDict[input[kCTLFieldName]];
        textField.backgroundColor = [UIColor clearColor];
    }];
    
    if(textField.keyboardType == UIKeyboardTypePhonePad){
        textField.text = [NSString formatPhoneNumber:textField.text];
    }
    
    NSInteger fieldCount = [_fieldRows count];
    NSInteger inputIndex = textField.tag;
    if(textField.tag > (fieldCount -1)){
        inputIndex -= fieldCount;
        [_addressRows[inputIndex] setValue:textField.text forKey:kCTLFieldValue];
        [self setAddressDictionary];
    }else{
        [_fieldRows[inputIndex] setValue:textField.text forKey:kCTLFieldValue];
        [self setPersonDictionary];
    }
}

- (void)showAddFieldsModal:(id)sender
{
    [self performSegueWithIdentifier:CTLContactFormEditorSegueIdentifyer sender:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTLFormFieldAddedNotification object:nil];
}

@end
