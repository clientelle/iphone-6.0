//
//  CTLContactImportViewController.m
//  Clientelle
//
//  Created by Kevin Liu 9/3/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//
#import "UIColor+CTLColor.h"
#import "CTLContactsListViewController.h"
#import "CTLContactImportViewController.h"
#import "CTLABPerson.h"
#import "CTLCDContact.h"
#import "CTLCDAccount.h"
#import "CTLAccountManager.h"

@interface CTLContactImportViewController()
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *filteredContacts;
@property (nonatomic, strong) NSMutableDictionary *selectedPeople;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *disabledTextColor;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, strong) CTLCDAccount *currentUser;
@property (nonatomic, strong) NSSet *existingContacts;
@end

@implementation CTLContactImportViewController

- (void)viewDidLoad
{
    self.busyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.busyIndicator.hidden = YES;    
    
    self.currentUser = [[CTLAccountManager sharedInstance] currentUser];
    self.existingContacts = self.currentUser.contacts;
    
    self.contacts = [NSArray array];
    self.selectedPeople = [[NSMutableDictionary alloc] init];
    self.filteredContacts = [NSMutableArray arrayWithCapacity:[self.contacts count]];
        									
    self.textColor = [UIColor ctlDarkGray];
    self.selectedBackgroundColor = [UIColor ctlLightGray];
    self.disabledTextColor = [UIColor colorFromUnNormalizedRGB:78.0f green:78.0f blue:78.0f alpha:1.0f];

    if(!self.addressBookRef){
        [self checkAddressbookPermission];
    }else{
        [self loadAddressBookContacts];
    }
}

- (void)checkAddressbookPermission
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            // First time access has been granted
            if(granted){
                self.addressBookRef = addressBookRef;
                [self loadAddressBookContacts];
            }else{
                [self displayPermissionPrompt];
            }
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access.
        self.addressBookRef = addressBookRef;
        [self loadAddressBookContacts];
        
    } else {
        // The user has previously denied access
        [self displayPermissionPrompt];
    }
}

- (void)displayPermissionPrompt
{
    UIAlertView *requirePermission = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REQUIRES_ACCESS_TO_CONTACTS", nil)
                                                                message:NSLocalizedString(@"GO_TO_SETTINGS_CONTACTS", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
    
    [requirePermission show];
}

- (void)loadAddressBookContacts
{
    [CTLABPerson peopleFromAddressBook:self.addressBookRef withBlock:^(NSDictionary *results){
        NSMutableDictionary *people = [results mutableCopy];
        for(CTLCDContact *contact in self.existingContacts){
            [people removeObjectForKey:contact.recordID];
        }        
        self.contacts = [people allValues];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

#pragma mark -
#pragma mark TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return [self.filteredContacts count];
    }
    return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"contactRow";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    CTLABPerson *person = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        person = [self.filteredContacts objectAtIndex:indexPath.row];
    }else{
        person = [self.contacts objectAtIndex:indexPath.row];
    }

    [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    
    cell.textLabel.text = person.compositeName;
    if([person.phone length] > 0){
        cell.detailTextLabel.text = person.phone;
    }else if([person.email length] > 0){
        cell.detailTextLabel.text = person.email;
    }
    
    //if person has been selected to be imported
    if([self.selectedPeople objectForKey:@(person.recordID)]){
        [self styleEnabledField:cell];
    }else{
        [self styleDisabledField:cell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CTLABPerson *person = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        person = [self.filteredContacts objectAtIndex:indexPath.row];
    }else{
        person = [self.contacts objectAtIndex:indexPath.row];
    }
    
    //if person has been selected to be imported
    if([self.selectedPeople objectForKey:@(person.recordID)]){
        [self styleEnabledField:cell];
    }else{
        [self styleDisabledField:cell];
    }
}

- (void)styleEnabledField:(UITableViewCell *)cell {
    [cell setAccessoryView:nil];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.textColor = self.textColor;
    cell.detailTextLabel.textColor = self.textColor;
    cell.backgroundColor = self.selectedBackgroundColor;
}

- (void)styleDisabledField:(UITableViewCell *)cell {
    UIButton *accessory = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [accessory setUserInteractionEnabled:NO];
    [cell setAccessoryView:accessory];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.textColor = self.disabledTextColor;
    cell.textLabel.textColor = self.disabledTextColor;
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self didSelectPerson:tableView atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self didSelectPerson:tableView atIndexPath:indexPath];
}

- (void)didSelectPerson:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(!cell){
        return;
    }
    
    CTLABPerson *person = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView){
        person = [self.filteredContacts objectAtIndex:indexPath.row];
    }else{
        person = [self.contacts objectAtIndex:indexPath.row];
    }
    
    if(cell.accessoryType == UITableViewCellAccessoryNone){
        [self styleEnabledField:cell];
        [self.selectedPeople setObject:person forKey:@(person.recordID)];
        [self.doneButton setStyle:UIBarButtonItemStyleDone];
        [self.doneButton setEnabled:YES];
    }else{
        [self styleDisabledField:cell];
        [self.selectedPeople removeObjectForKey:@(person.recordID)];
        if([self.selectedPeople count] == 0){
            [self.doneButton setStyle:UIBarButtonItemStyleBordered];
            [self.doneButton setEnabled:NO];
        }
    }
}

#pragma mark -
#pragma mark Contact Filtering

- (void)filterContactListForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[self.filteredContacts removeAllObjects];
	for (CTLABPerson *person in self.contacts){
        NSComparisonResult result = [person.compositeName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        if (result == NSOrderedSame){
            [self.filteredContacts addObject:person];
        }
	}
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContactListForSearchText:searchString scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContactListForSearchText:[self.searchDisplayController.searchBar text] scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Import Contacts Methods

- (IBAction)importContacts:(id)sender
{
    self.doneButton.enabled = NO;
    self.busyIndicator.hidden = NO;
    [self.busyIndicator startAnimating];
        
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    __block NSMutableSet *cdPeople = [NSMutableArray array];
    
    [self.selectedPeople enumerateKeysAndObjectsUsingBlock:^(NSNumber *recordID, CTLABPerson *person, BOOL *stop){
        CTLCDContact *contact = [CTLCDContact MR_createEntity];
        contact.recordID = @(person.recordID);
        [contact createFromABPerson:person];
        contact.account = self.currentUser;
        [cdPeople addObject:contact];
    }];
    
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL result, NSError *error){
        if(result){
            [[NSNotificationCenter defaultCenter] postNotificationName:CTLContactsWereImportedNotification object:cdPeople];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            NSString *message = NSLocalizedString(@"IMPORT_FAILED", nil);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelImport:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
