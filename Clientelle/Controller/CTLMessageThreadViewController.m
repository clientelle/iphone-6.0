//
//  CTLThreadViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 4/30/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "NSDate+CTLDate.h"

#import "CTLCDContact.h"
#import "CTLMessageThreadViewController.h"
#import "CTLContainerViewController.h"
#import "CTLMessageComposerViewController.h"
#import "CTLCDMessage.h"
#import "CTLMessageCell.h"
#import "CTLCDConversation.h"

#import "CTLAccountManager.h"
#import "CTLCDAccount.h"

@interface CTLMessageThreadViewController()
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) CTLCDAccount *current_user;

@end

@implementation CTLMessageThreadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.conversation.contact.compositeName;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];


    self.current_user = [CTLAccountManager currentUser];
        
    [self.containerView setRightSwipeEnabled:YES];
    [self.containerView renderMenuButton:self];
    
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversation = %@", self.conversation];
	self.resultsController = [CTLCDMessage fetchAllSortedBy:@"created_at" ascending:YES withPredicate:predicate groupBy:nil delegate:self];
        
    [self.resultsController performFetch:nil];
    [self.tableView reloadData];
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
    CTLCDMessage *message = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
    NSString *cellIdentifier = ([message.sender_uid isEqualToNumber:self.current_user.user_id]) ? @"youCell" : @"themCell";
    
    CTLMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    //cell.delegate = self;
    [self configure:cell withMessage:message];
    
    return cell;
}

- (void)configure:(CTLMessageCell *)cell withMessage:(CTLCDMessage *)message
{
//    NSString *contactName = self.conversation.contact.compositeName;
//    if([message.sender_uid isEqualToNumber:self.current_user.user_id]){
//        cell.senderLabel.text = NSLocalizedString(@"ME", nil);
//    }else{
//        cell.senderLabel.text = contactName;
//    }

    cell.timeLabel.text = [NSDate formatShortTimeOnly:message.created_at];
    cell.messageTextView.text = message.message_text;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTLCDMessage *message = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
    NSLog(@"TAPPED ON MESSAGE ROW %@", message);
    //[self performSegueWithIdentifier:@"toMessages" sender:conversation];
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

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
        CTLCDMessage *message = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            [message deleteInContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            //NOTE: Clean up appointments?
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    CTLCDMessage *message = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
    return [CTLMessageCell heightForCellWithMessage:message];
}

#pragma mark NSFetchResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(CTLCDMessage *)message atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    CTLMessageCell *cell = (CTLMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configure:cell withMessage:message];
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

- (IBAction)composeMessage:(id)sender
{
    [self performSegueWithIdentifier:@"toMessageComposerView" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toMessageComposerView"]){        
        CTLMessageComposerViewController *viewController = [segue destinationViewController];
        [viewController setConversation:self.conversation];       
        return;
    }
}

@end
