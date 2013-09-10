//
//  CTLMessagesListViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 4/30/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "NSDate+CTLDate.h"
#import "CTLAccountManager.h"
#import "CTLCDContact.h"
#import "CTLCDAccount.h"
#import "CTLConversationListViewController.h"
#import "CTLCDConversation.h"
#import "CTLConversationCell.h"
#import "CTLMessageThreadViewController.h"
#import "CTLMessageUpgradeView.h"

@interface CTLConversationListViewController ()
@property (nonatomic, strong) NSArray *conversations;
@property (nonatomic, strong) CTLCDAccount *currentUser;
@property (nonatomic, strong) UIView *emptyMessageView;

@end

@implementation CTLConversationListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(chooseContact:)];
              
    [self.containerView setRightSwipeEnabled:YES];
    [self.containerView renderMenuButton:self];
    [self.navigationItem setHidesBackButton:YES animated:YES];    
    
    self.currentUser = [[CTLAccountManager sharedInstance] currentUser];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"account = %@", self.currentUser];
    self.resultsController = [CTLCDConversation fetchAllSortedBy:@"updated_at" ascending:YES withPredicate:predicate groupBy:nil delegate:self];        
    [self.resultsController performFetch:nil];

    if([self.currentUser.conversations count] == 0){
        [[NSBundle mainBundle] loadNibNamed:@"CTLEmptyMessagesView" owner:self options:nil];
    }

    [self.tableView reloadData]; 
    [self checkForAcceptedInvitations];
}

- (void)checkForAcceptedInvitations
{
    if([self.currentUser.invites count] > 0){
        [[CTLAccountManager sharedInstance] syncInvites:^(NSError *error){
            if(error){
                [self displayAlertMessage:[error localizedDescription]];
            }
        }];
    }
}

- (void)displayAlertMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.resultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"conversationCell";
    CTLConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    CTLCDConversation *conversation = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
    //cell.delegate = self;
    [self configure:cell withConversation:conversation];
    
    return cell;
}

- (void)configure:(CTLConversationCell *)cell withConversation:(CTLCDConversation *)conversation
{
    NSString *contactName = conversation.contact.firstName;
    
    //If top message is me, show a different label
    if([conversation.last_sender_uid isEqualToNumber:self.currentUser.user_id]){
        cell.senderLabel.text = [NSString stringWithFormat:@"%@ > %@", NSLocalizedString(@"ME", nil), contactName];
    }else{
        cell.senderLabel.text = contactName;
    }

    cell.timeLabel.text = [NSDate formatShortTimeOnly:conversation.updated_at];
    cell.messageLabel.text = conversation.preview_message;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CTLCDConversation *conversation = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
//    self.selectedConversation = conversation;
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CTLAppointmentRowHeight;
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        CTLCDConversation *conversation = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            [conversation deleteInContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            //NOTE: Clean up appointments?
        }];
    }
}

#pragma mark NSFetchResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(CTLCDConversation *)conversation atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    CTLConversationCell *cell = (CTLConversationCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configure:cell withConversation:conversation];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([[self.resultsController fetchedObjects] count] == 0){
        return 60.0f;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([[self.resultsController fetchedObjects] count] == 0){
        return self.emptyMessageView;
    }
    
    return nil;
}

- (void)chooseContact:(id)sender
{
    [self performSegueWithIdentifier:@"toChooseContact" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(CTLConversationCell *)cell
{
    if([[segue identifier] isEqualToString:@"toThreadView"]){
        CTLMessageThreadViewController *viewController = [segue destinationViewController];        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        CTLCDConversation *conversation = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
        
        [viewController setConversation:conversation];
    }
}

@end
