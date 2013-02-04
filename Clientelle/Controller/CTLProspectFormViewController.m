//
//  CTLProspectFormViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 8/10/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NSString+CTLString.h"
#import "CTLFiveStarRater.h"
#import "CTLContactsListViewController.h"
#import "CTLProspectFormViewController.h"
#import "CTLABPerson.h"
#import "CTLABGroup.h"
#import "CTLCDPerson.h"

int const CTLNameFieldTag = 1;
int const CTLPhoneFieldTag = 2;
int const CTLPotentialLabelTag = 3;
int const CTLNotesFieldTag = 4;
int const CTLFiveStarTag = 5;

@implementation CTLProspectFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.topItem.title = NSLocalizedString(@"QUICK_LEAD", nil);
    
    _formSchema = @[@{@"tag":@(CTLNameFieldTag),        @"labelKey":@"CONTACT_NAME"},
                    @{@"tag":@(CTLPhoneFieldTag),       @"labelKey":@"PHONE_OR_EMAIL"},
                    @{@"tag":@(CTLPotentialLabelTag),   @"labelKey":@"POTENTIAL"},
                    @{@"tag":@(CTLNotesFieldTag),       @"labelKey":@"NOTES"}];
    
    _prospectDict = [[NSMutableDictionary alloc] initWithCapacity:[_formSchema count]];
    
    _rater = (CTLFiveStarRater *)[self.view viewWithTag:CTLFiveStarTag];
    [[self.view viewWithTag:CTLNameFieldTag] becomeFirstResponder];
}

#pragma mark - TableViewController Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_formSchema count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = _formSchema[indexPath.row][@"labelKey"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    int tag = [_formSchema[indexPath.row][@"tag"] intValue];
    NSString *localizedLabel = NSLocalizedString(cellIdentifier, nil);
    
    if([[cell viewWithTag:tag] isKindOfClass:[UITextField class]]){
        UITextField *textfield = (UITextField *)[cell viewWithTag:tag];
        textfield.placeholder = localizedLabel;
    }else{
        UILabel *potentialLabel = (UILabel *)[cell viewWithTag:tag];
        potentialLabel.text = localizedLabel;
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

#pragma mark - Form Handler

- (IBAction)save:(id)sender
{
    [self populateFormValues];
    
    if([self validateForm]){
        [self createProspect];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)validateForm
{
    if([[_prospectDict objectForKey:[@(CTLNameFieldTag) stringValue]] length] == 0){
        [self alertFormError:CTLNameFieldTag withMessage:NSLocalizedString(@"CONTACT_IS_BLANK", nil)];
        return NO;
    }

    if([[_prospectDict objectForKey:[@(CTLPhoneFieldTag) stringValue]] length] == 0){
        [self alertFormError:CTLPhoneFieldTag withMessage:NSLocalizedString(@"PHONE_EMAIL_IS_BLANK", nil)];
        return NO;
    }
    
    if([[_prospectDict objectForKey:[@(CTLNotesFieldTag) stringValue]] length] == 0){
        [self alertFormError:CTLNotesFieldTag withMessage:NSLocalizedString(@"ADD_NOTE", nil)];
        return NO;
    }
    
    return YES;
}

- (void)alertFormError:(int)tag withMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    UITextField *field = (UITextField *)[self.view viewWithTag:tag];
    
    [field becomeFirstResponder];
    [alert show];
}

- (void)populateFormValues
{
    [self setValueForInputTag:CTLNameFieldTag];
    [self setValueForInputTag:CTLPhoneFieldTag];
    [self setValueForInputTag:CTLNotesFieldTag];
}

- (void)setValueForInputTag:(int)tag {
    UITextField *textField = (UITextField *)[self.view viewWithTag:tag];
    [_prospectDict setValue:textField.text forKey:[@(tag) stringValue]];
}

- (void)ratingDidChange:(CTLFiveStarRater *)rater
{
    [_prospectDict setValue:[rater starValue] forKey:[@(CTLFiveStarTag) stringValue]];
}

- (void)createProspect
{
    [self.view endEditing:YES];
    
    NSMutableDictionary *fields = [[NSMutableDictionary alloc] init];
    NSString *nameStr = [_prospectDict objectForKey:[@(CTLNameFieldTag) stringValue]];
    NSString *contactStr = [_prospectDict objectForKey:[@(CTLPhoneFieldTag) stringValue]];
    NSString *noteStr = [_prospectDict objectForKey:[@(CTLNotesFieldTag) stringValue]];
        
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
    
    NSNumber *rate = [_prospectDict objectForKey:[@(CTLFiveStarTag) stringValue]];
    if(rate){
        [fields setValue:rate forKey:CTLPersonRatingProperty];
    }
    
    CTLCDPerson *person = [CTLCDPerson MR_createEntity];
    [person safeSetValuesForKeysWithDictionary:fields];

    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];

    //reload contact list view with prospects selected
    ABRecordID prospectGroupID = [CTLABGroup prospectGroupID];
    [CTLABGroup saveDefaultGroupID:prospectGroupID];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CTLNewContactWasAddedNotification object:abPerson];
}

- (IBAction)cancel:(id)sender{
   [self dismissViewControllerAnimated:YES completion:nil];
}


@end
