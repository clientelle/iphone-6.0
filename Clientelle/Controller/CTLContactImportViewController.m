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
#import "CTLABGroup.h"

@interface CTLContactImportViewController ()
- (void)loadAddressBookContacts;
@end

@implementation CTLContactImportViewController

- (void)viewDidLoad
{
    self.busyIndicator.hidden = YES;
    
    _contacts = [NSArray array];
    _selectedPeople = [[NSMutableDictionary alloc] init];
    _filteredContacts = [NSMutableArray arrayWithCapacity:[_contacts count]];
        									
    _textColor = [UIColor ctlDarkGray];
    _selectedBackgroundColor = [UIColor ctlLightGray];
    _disabledTextColor = [UIColor colorFromUnNormalizedRGB:78.0f green:78.0f blue:78.0f alpha:1.0f];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self loadAddressBookContacts];
    });
}

- (void)loadAddressBookContacts
{
    [CTLABPerson peopleFromAddressBook:self.addressBookRef withBlock:^(NSDictionary *results){
        NSMutableDictionary *people = [results mutableCopy];
        for(NSNumber *recordID in _selectedGroup.members){
            [people removeObjectForKey:recordID];
        }
        
        _contacts = [people allValues];
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
        return [_filteredContacts count];
    }
    return [_contacts count];
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
        person = [_filteredContacts objectAtIndex:indexPath.row];
    }else{
        person = [_contacts objectAtIndex:indexPath.row];
    }

    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0f]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    
    cell.textLabel.text = person.compositeName;
    if([person.phone length] > 0){
        cell.detailTextLabel.text = person.phone;
    }else if([person.email length] > 0){
        cell.detailTextLabel.text = person.email;
    }
    
    //if person has been selected to be imported
    if([_selectedPeople objectForKey:@(person.recordID)]){
        [self styleEnabledField:cell];
    }else{
        [self styleDisabledField:cell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CTLABPerson *person = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        person = [_filteredContacts objectAtIndex:indexPath.row];
    }else{
        person = [_contacts objectAtIndex:indexPath.row];
    }
    
    //if person has been selected to be imported
    if([_selectedPeople objectForKey:@(person.recordID)]){
        [self styleEnabledField:cell];
    }else{
        [self styleDisabledField:cell];
    }
}

- (void)styleEnabledField:(UITableViewCell *)cell {
    [cell setAccessoryView:nil];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.textColor = _textColor;
    cell.detailTextLabel.textColor = _textColor;
    cell.backgroundColor = _selectedBackgroundColor;
}

- (void)styleDisabledField:(UITableViewCell *)cell {
    UIButton *accessory = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [accessory setUserInteractionEnabled:NO];
    [cell setAccessoryView:accessory];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.textColor = _disabledTextColor;
    cell.textLabel.textColor = _disabledTextColor;
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
        person = [_filteredContacts objectAtIndex:indexPath.row];
    }else{
        person = [_contacts objectAtIndex:indexPath.row];
    }
    
    if(cell.accessoryType == UITableViewCellAccessoryNone){
        [self styleEnabledField:cell];
        [person setAccessDate:[NSDate date]];
        [_selectedPeople setObject:person forKey:@(person.recordID)];
        [self.doneButton setStyle:UIBarButtonItemStyleDone];
        [self.doneButton setEnabled:YES];
    }else{
        [self styleDisabledField:cell];
        [_selectedPeople removeObjectForKey:@(person.recordID)];
        if([_selectedPeople count] == 0){
            [self.doneButton setStyle:UIBarButtonItemStyleBordered];
            [self.doneButton setEnabled:NO];
        }
    }
}

#pragma mark -
#pragma mark Contact Filtering

- (void)filterContactListForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[_filteredContacts removeAllObjects];
	for (CTLABPerson *person in _contacts){
        NSComparisonResult result = [person.compositeName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        if (result == NSOrderedSame){
            [_filteredContacts addObject:person];
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
    [self.selectedGroup addMembers:_selectedPeople];
        
    [[NSNotificationCenter defaultCenter] postNotificationName:CTLContactListReloadNotification object:_selectedPeople];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelImport:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
