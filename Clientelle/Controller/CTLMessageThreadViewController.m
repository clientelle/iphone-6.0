//
//  CTLThreadViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 4/30/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "SRWebSocket.h"
#import "PrivatePubWebSocketDelegate.h"
#import "AFJSONRequestOperation.h"
#import "NSDate+CTLDate.h"

#import "CTLAccountManager.h"

#import "CTLMessageThreadViewController.h"
#import "CTLMessageComposerViewController.h"
#import "CTLContainerViewController.h"
#import "CTLMessageCell.h"

#import "CTLCDMessage.h"
#import "CTLCDConversation.h"
#import "CTLCDContact.h"
#import "CTLCDAccount.h"

@interface CTLMessageThreadViewController()

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) CTLCDAccount *current_user;

@property (nonatomic, retain) SRWebSocket *websocketClient;
@property (nonatomic, retain) PrivatePubWebSocketDelegate *websocketDelegate;

- (void) fetchPrivatePubConfiguration:(NSString *)channel;
- (void) initializePrivatePubClientWithSubscriptionInformation: (id) JSON;

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
    
    [self fetchPrivatePubConfiguration:@"/messages/2_4"];
    
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];    
    [notifCenter addObserver:self selector:@selector(didReceiveRealtimeMessage:) name:@"didReceiveRealtimeMessage" object:nil];
}

- (void)didReceiveRealtimeMessage:(NSNotification *)notification
{
    id JSON = [[notification.object JSONValue] objectAtIndex:0];
    
    NSDictionary *data = [JSON valueForKeyPath:@"data"];
    NSString *messageText = data[@"data"][@"message"][@"content"];
    NSTimeInterval timestamp = [data[@"data"][@"message"][@"created_at"] doubleValue];
    int sender_uid = data[@"data"][@"message"][@"sender_id"];
    
    CTLCDMessage *message = [CTLCDMessage createEntity];    
    message.created_at = [NSDate dateWithTimeIntervalSince1970:timestamp];    
	message.message_text = messageText;
	message.sender_uid = @(sender_uid);
    message.conversation = self.conversation;
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
        
        NSLog(@"SAVED MSG %i", success);
    }];
    
}

//- (void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    [self.websocketClient close];
//    [self.websocketDelegate disconnect];
//}

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

- (void) initializePrivatePubClientWithSubscriptionInformation: (id) JSON
{
    self.websocketDelegate = [[PrivatePubWebSocketDelegate alloc]
                              initWithPrivatePubTimestamp: [JSON valueForKeyPath:@"timestamp"]
                              andSignature: [JSON valueForKeyPath:@"signature"]
                              andChannel:[JSON valueForKeyPath:@"channel"]];
    
    NSString *server = [JSON valueForKeyPath:@"server"];
    NSURL *url = [NSURL URLWithString:server];
    NSMutableURLRequest *configurationRequest = [NSMutableURLRequest requestWithURL:url];    
    self.websocketClient = [[SRWebSocket alloc] initWithURLRequest:configurationRequest];
    
    [self.websocketClient setDelegate:self.websocketDelegate];
    [self.websocketClient open];
}

- (void)fetchPrivatePubConfiguration:(NSString *)channel
{
    NSString *resourceUrl = [NSString stringWithFormat:CTL_FAYE_CONFIG_URL, channel];
    NSURL *url = [NSURL URLWithString:resourceUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self initializePrivatePubClientWithSubscriptionInformation: JSON];        
    } failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON) {
        NSLog(@"request was failed: %@", error);
    }];
    
    [operation start];
}

@end

