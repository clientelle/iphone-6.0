//
//  CTLContactFormViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 6/24/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "CTLPhoneNumberFormatter.h"

#import "CTLContactsListViewController.h"
#import "CTLContactImportViewController.h"
#import "CTLContactFormEditorViewController.h"

#import "CTLContactViewController.h"
#import "CTLCDFormSchema.h"
#import "CTLContactFieldCell.h"

#import "CTLABPerson.h"
#import "CTLABGroup.h"
#import "CTLCDPerson.h"

NSString *const CTLContactFormEditorSegueIdentifyer = @"toContactFormEditor";

int const CTLContactModifiedTag = 1234;
int const CTLContactDeletedTag = 4321;
int const CTLConfirmExternalDeleteIndex = 0;
int const CTLRecreateContactIndex = 1;
int const CTLTakeExternalChangesIndex = 0;
int const CTLOverwriteExternalChangeIndex = 1;

@implementation CTLContactViewController

#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _addressbookChangeDidComeFromApp = NO;
    
    if(self.abPerson){
        self.navigationItem.title = @"Edit Contact";
    }else{
        NSLog(@"add contact");
        self.navigationItem.title = @"Add Contact";
    }
    
    //TODO: how to handle contact form with no group selected
    if(!self.abGroup){
        self.abGroup = [[CTLABGroup alloc] initWithGroupID:[CTLABGroup clientGroupID] addressBook:self.addressBookRef];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formDidChange:) name:CTLFormFieldAddedNotification object: nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookDidChange:) name:CTLAddressBookChanged object:nil];
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:CTLAddressBookChanged object:nil];
   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)buildSchema
{
    if(!_formFields){
        _formFields = [CTLCDFormSchema fieldsFromPlist:CTLABPersonSchemaPlist];
    }
    
    if(!_addressFields){
        _addressFields = [CTLCDFormSchema fieldsFromPlist:CTLAddressSchemaPlist];
    }
    
    _fieldRows = [[NSMutableArray alloc] initWithCapacity:0];
    _formSchema = [[NSMutableArray alloc] initWithCapacity:0];
    _personDict = [[NSMutableDictionary alloc] init];
    _addressDict = [[NSMutableDictionary alloc] init];
    
    _addressRows = [[NSMutableArray alloc] initWithCapacity:0];
    _showAddress = [[_cdFormSchema valueForKey:CTLPersonAddressProperty] isEqualToNumber:[NSNumber numberWithBool:YES]];
    
    BOOL hasPerson = (self.abPerson != nil);

    for(NSUInteger i=0; i < [_formFields count]; i++){
        NSDictionary *field = [_formFields objectAtIndex:i];
        NSString *fieldName = [field objectForKey:kCTLFieldName];
        NSString *value = nil;
        
        if(hasPerson){
            value = [[self.abPerson valueForKey:fieldName] description];
            if(value){
                [_personDict setValue:value forKey:fieldName];
            }
        }
        
        if([[_cdFormSchema valueForKey:fieldName] isEqualToNumber:[NSNumber numberWithBool:YES]]){
            NSMutableDictionary *inputField = [field mutableCopy];
            if(value){
                [inputField setValue:value forKey:kCTLFieldValue];
            }
            [_fieldRows addObject:inputField];
        }
    }
    
    //address fields
    if(_showAddress){
        for(NSUInteger k=0; k < [_addressFields count]; k++){
            NSDictionary *input = [_addressFields objectAtIndex:k];
            NSString *fieldName = [input objectForKey:kCTLFieldName];
            NSString *value = nil;
            
            if(hasPerson){
                value = [[[self.abPerson addressDict] valueForKey:fieldName] description];
            }
            
            NSMutableDictionary *inputField = [input mutableCopy];
            if(value){
                [inputField setValue:value forKey:kCTLFieldValue];
            }
            [_addressRows addObject:inputField];
        }
    }
}

- (void)setPersonDictionary
{
    NSArray *fields = [NSArray arrayWithArray:_fieldRows];
    [fields enumerateObjectsUsingBlock:^(id input, NSUInteger idx, BOOL *stop){
        NSString *value = [input objectForKey:kCTLFieldValue];
        NSString *field = [input objectForKey:kCTLFieldName];
        [_personDict setValue:value forKey:field];
    }];
}

- (void)setAddressDictionary
{
    NSArray *fields = [NSArray arrayWithArray:_addressRows];
    [fields enumerateObjectsUsingBlock:^(id input, NSUInteger idx, BOOL *stop){
        NSString *value = [input objectForKey:kCTLFieldValue];
        NSString *field = [input objectForKey:kCTLFieldName];
        [_addressDict setValue:value forKey:field];
    }];
}

- (void)addressBookDidChange:(NSNotification *)notification
{
    
    CTLABPerson *person = [[CTLABPerson alloc] initWithRecordRef:[self.abPerson recordRef] withAddressBookRef:self.addressBookRef];
    
    //if changes came from app or user has no pending changes, simply reload the form view
    if(_addressbookChangeDidComeFromApp){
        [self reloadFormViewAfterAddressBookChange];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"External Changes Detected"];
    [alert setDelegate:self];
    
    if(person.recordID == kABRecordInvalidID){
        NSString *deletedMsg = [NSString stringWithFormat:@"%@ contact was deleted", [self.abPerson firstName]];
        alert.tag = CTLContactDeletedTag;
        [alert setMessage:deletedMsg];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Create Again"];
    }else{
        alert.tag = CTLContactModifiedTag;
        [alert setTitle:@"External Changes Detected"];
        [alert setMessage:@"Would you like to take the changes or overwrite it?"];
        [alert addButtonWithTitle:@"Take New"];
        [alert addButtonWithTitle:@"Overwrite"];
    }
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == CTLContactDeletedTag){
        if(buttonIndex == CTLConfirmExternalDeleteIndex){
            //accept the fact that contact was deleted
            [self dismissViewControllerAnimated:YES completion:^{
                //[[NSNotificationCenter defaultCenter] postNotificationName:CTLContactDeletedNotification object:nil];
            }];
        }
        if(buttonIndex == CTLRecreateContactIndex){
            //recreate the contact by setting the recordID is invalid
            [self.abPerson setRecordID:kABRecordInvalidID];
            [self saveContactInfo];
        }
    }
    
    if(alertView.tag == CTLContactModifiedTag){
        if(buttonIndex == CTLTakeExternalChangesIndex){
            //revert changes to take address book data
            [self reloadFormViewAfterAddressBookChange];
        }
        
        if(buttonIndex == CTLOverwriteExternalChangeIndex){
            //overwrite addressbook changes
            [self saveContactInfo];
        }
    }
}

- (void)reloadFormViewAfterAddressBookChange {
    
    self.abPerson = [[CTLABPerson alloc] initWithRecordRef:[self.abPerson recordRef] withAddressBookRef:self.addressBookRef];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"groupID=%i", [self.abGroup groupID]];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    _formSchema = [CTLCDFormSchema MR_findFirstWithPredicate:predicate inContext:context];
    [self buildSchema];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return NO;
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
    return 45.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = @"inputRow";
    CTLContactFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[CTLContactFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSMutableDictionary *field = [[NSMutableDictionary alloc] init];
    if(indexPath.section == 0){
        field = [_fieldRows objectAtIndex:indexPath.row];
        cell.textInput.tag = indexPath.row;
    }else{
        field = [_addressRows objectAtIndex:indexPath.row];
        cell.textInput.tag = indexPath.row + [_fieldRows count];
    }
    
    cell.fieldLabel.text = [field objectForKey:kCTLFieldLabel];
    cell.textInput.placeholder = [field objectForKey:kCTLFieldPlaceHolder];
    cell.textInput.text = [field objectForKey:kCTLFieldValue];
        
    UIKeyboardType keyboardType = (UIKeyboardType)[[field objectForKey:kCTLFieldKeyboardType] intValue];
    if(keyboardType != UIKeyboardTypeEmailAddress){
        cell.textInput.autocapitalizationType = UITextAutocapitalizationTypeWords;
        cell.textInput.autocorrectionType = UITextAutocorrectionTypeYes;
    }

    if([[field objectForKey:kCTLFieldName] isEqualToString:CTLPersonNoteProperty]){
        cell.textInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    }
    
    [cell.textInput setKeyboardType:keyboardType];
    [cell.textInput addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingChanged];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 1){
        return @"Contact Address";
    }
    
    return @"Contact Info";
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
        [settingsButton setImage:[UIImage imageNamed:@"sm-wrench-gray.png"] forState:UIControlStateNormal];
        [settingsButton addTarget:self action:@selector(showAddFieldsModal:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30.0f)];
        [footerView addSubview:dashesLabel];
        [footerView addSubview:settingsButton];
        [footerView setBackgroundColor:[UIColor clearColor]];
        
        return footerView;
    }
    return nil;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:CTLContactFormEditorSegueIdentifyer]){
        CTLContactFormEditorViewController *formEditorViewController = [segue destinationViewController];
        [formEditorViewController setAbGroup:self.abGroup];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submit:(id)sender {
    [self saveContactInfo];
}

- (void)saveContactInfo
{
    [self setPersonDictionary];
    if(![CTLABPerson validateContactInfo:_personDict]){
        UIAlertView *formAlert = [[UIAlertView alloc] initWithTitle:@"Contact is Incomplete" message:@"Name and contact type is required (email or phone number)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [formAlert show];
        return;
    }
    
    if(_showAddress){
        [self setAddressDictionary];
        [_personDict setValue:_addressDict forKey:CTLPersonAddressProperty];
    }

    if([self.abPerson recordID]){
        
        CTLABPerson *updatedPerson = [self.abPerson updateWithDictionary:_personDict];
        self.abPerson = updatedPerson;
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:CTLContactRowDidChangeNotification object:self.abPerson];
     }else{
        ABRecordID recordID = kABRecordInvalidID;
        NSDictionary *newContactDict = [[NSMutableDictionary alloc] initWithCapacity:2];
        

        self.abPerson = [[CTLABPerson alloc] initWithDictionary:_personDict withAddressBookRef:self.addressBookRef];
        recordID = [self.abPerson recordID];
        if(recordID != kABRecordInvalidID){
            [self.abGroup addMember:recordID];
            CTLCDPerson *person = [self updateTimestamp:recordID];
            [self.abPerson setAccessDate:person.lastAccessed];
            [newContactDict setValue:self.abPerson forKey:@"person"];
            [newContactDict setValue:person forKey:@"accessed"];
        }
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:CTLNewContactWasAddedNotification object:newContactDict];
    }
    
    //set flag to notifiy that changes came from within the app
    _addressbookChangeDidComeFromApp = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (CTLCDPerson *)updateTimestamp:(ABRecordID)recordID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordID=%i", recordID];
    CTLCDPerson *person = [CTLCDPerson MR_findFirstWithPredicate:predicate];
    if(!person){
        person = [CTLCDPerson MR_createEntity];
        person.recordIDValue = recordID;
    }
    person.lastAccessed = [NSDate date];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    return person;
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
    [_focusedTextField setBackgroundColor:[UIColor clearColor]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.keyboardType == UIKeyboardTypePhonePad){
        CTLPhoneNumberFormatter *formatter = [[CTLPhoneNumberFormatter alloc] init];
        textField.text = [formatter formatPhone:textField.text];
    }
    
    NSInteger fieldCount = [_fieldRows count];
    NSInteger inputIndex = textField.tag;
    if(textField.tag > (fieldCount -1)){
        inputIndex -= fieldCount;
        [[_addressRows objectAtIndex:inputIndex] setValue:textField.text forKey:kCTLFieldValue];
        [self setAddressDictionary];
    }else{
        [[_fieldRows objectAtIndex:inputIndex] setValue:textField.text forKey:kCTLFieldValue];
        [self setPersonDictionary];
    }
}

- (IBAction)highlightTextField:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    [_focusedTextField setBackgroundColor:[UIColor clearColor]];
    [textField setBackgroundColor:[UIColor textInputHighlightBackgroundColor]];
    _focusedTextField = textField;
}

#pragma mark - Resize view in keyboard mode

CGRect CTLSubtractRect(CGRect viewFrame, CGRect keyboardFrame){
    CGFloat width1 = CGRectGetWidth(viewFrame);
    CGFloat width2 = CGRectGetWidth(keyboardFrame);
    if(width1 != width2){
        NSLog(@"%@", @"This doesn't work if the rectangles aren't the same width!");
    }
    
    CGFloat viewHeight = CGRectGetHeight(viewFrame);
    CGFloat keyboardHeight = CGRectGetHeight(keyboardFrame);
    CGFloat x1 = CGRectGetMinX(viewFrame);
    CGFloat x2 = CGRectGetMinX(keyboardFrame);
    CGFloat y1 = CGRectGetMinY(viewFrame);
    CGFloat y2 = CGRectGetMinY(keyboardFrame);
    
    return CGRectMake(fminf(x1, x2), fminf(y1, y2), width1, fabsf(viewHeight-keyboardHeight));
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    UIViewAnimationOptions options = [userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    CGRect viewFrame = [self.view frame];
    viewFrame.origin.y = self.navigationBar.frame.size.height;
    viewFrame.size.height -= self.navigationBar.frame.size.height;
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect resizedFrame = CTLSubtractRect(viewFrame, keyboardFrame);
    
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        [self.tableView setFrame:resizedFrame];
    } completion:nil];
}

- (void)keyboardWillDisappear:(NSNotification *)notification {
    CGRect viewFrame = [self.view frame];
    viewFrame.origin.y = self.navigationBar.frame.size.height;
    viewFrame.size.height += self.navigationBar.frame.size.height;
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        [self.tableView setFrame:viewFrame];
    } completion:nil];
}

- (void)showAddFieldsModal:(id)sender {
    [self performSegueWithIdentifier:CTLContactFormEditorSegueIdentifyer sender:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTLFormFieldAddedNotification object:nil];
}

@end