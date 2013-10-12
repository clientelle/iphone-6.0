//
//  CTLAccountsViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 7/20/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "UITableViewCell+CellShadows.h"
#import "CTLAccountsViewController.h"
#import "CTLAccountViewController.h"
#import "CTLAccountManager.h"
#import "CTLCDAccount.h"
#import "CTLCDContact.h"

@interface CTLAccountsViewController ()

@property (nonatomic, strong) CTLCDAccount *currentUser;
@property (nonatomic, assign) int loggedInUserId;

@end

@implementation CTLAccountsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"ACCOUNTS", nil);    
    self.currentUser = [[CTLAccountManager sharedInstance] currentUser];
    self.loggedInUserId = self.currentUser.user_idValue;
    
    self.resultsController = [CTLCDAccount fetchAllSortedBy:@"created_at" ascending:YES withPredicate:nil groupBy:nil delegate:self];
    [self.resultsController performFetch:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAccountsTable:) name:CTLReloadAccountsNotification object:nil];
}

- (void)reloadAccountsTable:(NSNotification *)notification
{
    self.loggedInUserId = [[CTLAccountManager sharedInstance] getLoggedInUserId];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.resultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTLCDAccount *account = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"accountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell withAccount:account];
    [cell addShadowToCellInGroupedTableView:self.tableView atIndexPath:indexPath];
    
    if(account.user_idValue == self.loggedInUserId){
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTLCDAccount *account = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
    return account.user_idValue != self.loggedInUserId;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CTLCDAccount *account = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            [account deleteInContext:localContext];
        } completion:nil];
    }   
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTLCDAccount *account = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"toAccountView" sender:account];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell withAccount:(CTLCDAccount *)account
{
    cell.textLabel.text = account.email;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d contacts",[account.contacts count]];
}

#pragma mark NSFetchResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(CTLCDAccount *)account atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
               
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:cell withAccount:account];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"toAccountView"]){
        if([sender isKindOfClass:[CTLCDAccount class]]){
            CTLCDAccount *account = (CTLCDAccount *)sender;
            CTLAccountViewController *viewController = [segue destinationViewController];           
            [viewController setAccount:account];
            return;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
