//
//  CTLProspectFormViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 8/10/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CTLPhoneNumberFormatter.h"

#import "CTLContactsListViewController.h"
#import "CTLProspectFormViewController.h"
#import "CTLABPerson.h"
#import "CTLABGroup.h"
#import "CTLCDPerson.h"

int const CTLNameFieldTag = 1;
int const CTLPhoneFieldTag = 2;
int const CTLNotesFieldTag = 4;

@implementation CTLProspectFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLocale *locale = [NSLocale currentLocale];
    _countryCode = [locale objectForKey: NSLocaleCountryCode];
   
    _fields = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ProspectForm" ofType:@"plist"]];
    _prospectDict = [[NSMutableDictionary alloc] initWithCapacity:[_fields count]];
    
    for(NSUInteger i=0; i < [_fields count];i++){
        NSMutableDictionary *field = [[_fields objectAtIndex:i] mutableCopy];
        [field setValue:@"" forKey:@"value"];
        [_prospectDict setValue:field forKey:[field objectForKey:@"tag"]];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    
    UITextField *textField = (UITextField *)[self.view viewWithTag:CTLNameFieldTag];
    [textField becomeFirstResponder];
}

#pragma mark - TableViewController Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_fields count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = [[_fields objectAtIndex:indexPath.row] objectForKey:@"cellIdentifyer"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

- (void)alertFormError:(int)tag withMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    UITextField *field = (UITextField *)[self.view viewWithTag:tag];
    
    [field becomeFirstResponder];
    [alert show];
}

- (IBAction)save:(id)sender {
   
    [self populateFormValues];
    
    if([self validateForm]){
        [self createProspect];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)validateForm {
    
    if([[[_prospectDict objectForKey:@(CTLNameFieldTag)] objectForKey:@"value"] length] == 0){
        [self alertFormError:CTLNameFieldTag withMessage:@"Contact Name cannot be blank"];
        return NO;
    }
    
    if([[[_prospectDict objectForKey:@(CTLPhoneFieldTag)] objectForKey:@"value"] length] == 0){
        [self alertFormError:CTLPhoneFieldTag withMessage:@"Phone or Email cannot be blank"];
        return NO;
    }
    
    if([[[_prospectDict objectForKey:@(CTLNotesFieldTag)] objectForKey:@"value"] length] == 0){
        [self alertFormError:CTLNotesFieldTag withMessage:@"Add a note about this lead"];
        return NO;
    }
    
    return YES;
}

- (void)populateFormValues {
    
    [self setValueForInputTag:CTLNameFieldTag];
    [self setValueForInputTag:CTLPhoneFieldTag];
    [self setValueForInputTag:CTLNotesFieldTag];
    
   // _rater = (CTLFiveStarRater *)[self.tableView viewWithTag:CTLRaterViewTag];
   // [[_prospectDict objectForKey:@(CTLRaterViewTag)] setValue:[_rater starValue] forKey:@"value"];
}

- (void)setValueForInputTag:(int)tag {
    UITextField *textField = (UITextField *)[self.view viewWithTag:tag];
    [[_prospectDict objectForKey:@(tag)] setValue:textField.text forKey:@"value"];
}

- (void)createProspect
{
    [self.view endEditing:YES];
    
    NSMutableDictionary *fields = [[NSMutableDictionary alloc] init];

    NSString *nameStr = [[_prospectDict objectForKey:@(CTLNameFieldTag)] objectForKey:@"value"];
    NSString *contactStr = [[_prospectDict objectForKey:@(CTLPhoneFieldTag)] objectForKey:@"value"];
    NSString *noteStr = [[_prospectDict objectForKey:@(CTLNotesFieldTag)] objectForKey:@"value"];
    
    //try to determine first and last name from name field
    NSMutableArray *nameParts = [[NSMutableArray alloc] initWithArray:[nameStr componentsSeparatedByString:@" "]];
    
    if([nameParts count] == 1){
        [fields setValue:[nameParts objectAtIndex:0] forKey:CTLPersonFirstNameProperty];
    }else if([nameParts count] == 2){
        [fields setValue:[nameParts objectAtIndex:0] forKey:CTLPersonFirstNameProperty];
        [fields setValue:[nameParts objectAtIndex:1] forKey:CTLPersonLastNameProperty];
    }else {
        [fields setValue:[nameParts lastObject] forKey:CTLPersonLastNameProperty];
        [nameParts removeLastObject];
        [fields setValue:[nameParts componentsJoinedByString:@" "] forKey:CTLPersonFirstNameProperty];
    }
    
    if([contactStr length] >= 1){
        NSString *contactField = ([contactStr rangeOfString:@"@"].location == NSNotFound) ? CTLPersonPhoneProperty : CTLPersonEmailProperty;
        [fields setValue:contactStr forKey:contactField];
    }
    
    [fields setValue:noteStr forKey:CTLPersonNoteProperty];
    
    ABRecordID recordID = kABRecordInvalidID;
        
    CTLABPerson *abPerson = [[CTLABPerson alloc] initWithDictionary:fields withAddressBookRef:self.addressBookRef];
    recordID = abPerson.recordID;
    if(recordID != kABRecordInvalidID){
        CTLABGroup *prospectGroup = [[CTLABGroup alloc] initWithGroupID:[CTLABGroup prospectGroupID] addressBook:self.addressBookRef];
        [prospectGroup addMember:abPerson];
    }
    
    
    //Add accessed date to new prospect to float them up the list
    /*
    CTLCDPerson *person = [CTLCDPerson MR_createEntity];
    person.recordIDValue = recordID;
    person.lastAccessed = [NSDate date];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    [context MR_save];
*/
    //reload contact list view with prospects selected
    ABRecordID prospectGroupID = [CTLABGroup prospectGroupID];
    [[NSUserDefaults standardUserDefaults] setInteger:prospectGroupID forKey:CTLDefaultSelectedGroupIDKey];
    //[[NSNotificationCenter defaultCenter] postNotificationName:CTLContactListReloadNotification object:@(prospectGroupID)];
    
}

- (IBAction)cancel:(id)sender{
   [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)textFieldDidEndEditing:(UITextField *)textField {
- (IBAction)formatPhoneNumber:(id)sender {
    UITextField *textField = sender;
    if([textField.text rangeOfString:@"@"].location == NSNotFound){
        //CTLPhoneNumberFormatter *formatter = [[CTLPhoneNumberFormatter alloc] init];
        //textField.text = [formatter format:textField.text withLocale:_countryCode];
    }
}


@end
