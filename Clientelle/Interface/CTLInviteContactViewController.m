//
//  CTLInviteContactViewController.m
//  Clientelle
//
//  Created by Kevin Liu 9/3/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import "NSString+CTLString.h"
#import "UIColor+CTLColor.h"
#import "CTLMessageComposerViewController.h"
#import "CTLInviteContactViewController.h"
#import "CTLAddressBook.h"
#import "CTLABPerson.h"
#import "CTLCDContact.h"
#import "CTLCDAccount.h"
#import "CTLAccountManager.h"
#import "CTLInviteCell.h"
#import "CTLCDInvite.h"
#import "CTLCDConversation.h"
#import "CTLMessageManager.h"

@interface CTLInviteContactViewController()

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *disabledTextColor;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;

@property (nonatomic, strong) CTLCDAccount *currentUser;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSSet *existingContacts;
@property (nonatomic, strong) NSMutableArray *filteredContacts;

@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, strong) id selectedContact;
@property (nonatomic, strong) NSMutableDictionary *invites;

@end

@implementation CTLInviteContactViewController

- (void)viewDidLoad
{
    self.currentUser = [[CTLAccountManager sharedInstance] currentUser];
    
    self.contacts = [NSArray array];
    self.filteredContacts = [NSMutableArray array];
    self.existingContacts = self.currentUser.contacts;
    
    self.invites = [NSMutableDictionary dictionaryWithCapacity:[self.currentUser.invites count]];
    
    for(CTLCDInvite *invite in self.currentUser.invites){
        [self.invites setValue:invite forKey:[invite.record_id stringValue]];
    }
                
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];    
    self.textColor = [UIColor ctlDarkGray];
    self.selectedBackgroundColor = [UIColor ctlLightGray];
    self.disabledTextColor = [UIColor colorFromUnNormalizedRGB:78.0f green:78.0f blue:78.0f alpha:1.0f];
    
    //Merge existing contacts with addressbook contacts
    [[CTLAddressBook sharedInstance] loadContactsWithCompletionBlock:^(NSDictionary *results){        
        NSMutableDictionary *addressBookContacts = [results mutableCopy];
        for(CTLCDContact *contact in self.existingContacts){
            [addressBookContacts removeObjectForKey:contact.recordID];
            [addressBookContacts setValue:contact forKey:[contact.recordID stringValue]];
        }
        
        self.contacts = [addressBookContacts allValues];
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

- (CTLInviteCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"contactRow";
    CTLInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[CTLInviteCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }    
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        if([[self.filteredContacts objectAtIndex:indexPath.row] isKindOfClass:[CTLABPerson class]]){
            CTLABPerson *contact = [self.filteredContacts objectAtIndex:indexPath.row];
            [self configureCell:cell withAbPerson:contact];
        }else{
            CTLCDContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
            [self configureCell:cell withContact:contact];
        }        
    }else{
        if([[self.contacts objectAtIndex:indexPath.row] isKindOfClass:[CTLABPerson class]]){
            CTLABPerson *contact = [self.contacts objectAtIndex:indexPath.row];
            [self configureCell:cell withAbPerson:contact];
        }else{
            CTLCDContact *contact = [self.contacts objectAtIndex:indexPath.row];
            [self configureCell:cell withContact:contact];
        }
    }
    
    return cell;
}

- (void)configureCell:(CTLInviteCell *)cell withAbPerson:(CTLABPerson *)contact
{    
    cell.textLabel.text = contact.compositeName;
    NSString *key = [NSString stringWithFormat:@"%i", contact.recordID];
    
    if(self.invites[key]){
        cell.detailTextLabel.text = @"Request pending";
        cell.detailTextLabel.textColor = [UIColor ctlRed];
    }else{
        cell.detailTextLabel.text = NSLocalizedString(@"SEND_INVITE", nil);
        cell.detailTextLabel.textColor = [UIColor ctlGreen];
    }    
}

- (void)configureCell:(CTLInviteCell *)cell withContact:(CTLCDContact *)contact
{
    cell.textLabel.text = contact.compositeName;
    
    if(contact.userIdValue == 0){
        cell.detailTextLabel.text = NSLocalizedString(@"SEND_INVITE", nil);
        cell.detailTextLabel.textColor = [UIColor ctlRed];
        
        NSString *key = [NSString stringWithFormat:@"%@", contact.recordID];
        
        if(self.invites[key]){
            cell.detailTextLabel.text = @"Request pending";
            cell.detailTextLabel.textColor = [UIColor ctlRed];
        }else{
            cell.detailTextLabel.text = NSLocalizedString(@"SEND_INVITE", nil);
            cell.detailTextLabel.textColor = [UIColor ctlGreen];
        }        
        
    }else{
        UIImage *icon = [UIImage imageNamed:@"09-chat-grey"];
        cell.accessoryView = [[UIImageView alloc] initWithImage:icon];
        cell.detailTextLabel.text = NSLocalizedString(@"SEND_MESSAGE", nil);
        cell.detailTextLabel.textColor = [UIColor ctlGreen];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.selectedIndex){        
        [self toggleCheckMarkForCell:tableView atIndex:self.selectedIndex];
    }
    
    [self toggleCheckMarkForCell:tableView atIndex:indexPath];    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        [self selectContact:self.filteredContacts forIndexPath:indexPath];
    }else{        
        [self selectContact:self.contacts forIndexPath:indexPath];
    }    
}

- (void)selectContact:(NSArray *)contacts forIndexPath:(NSIndexPath *)indexPath
{
    if([[contacts objectAtIndex:indexPath.row] isKindOfClass:[CTLCDContact class]]){
        CTLCDContact *contact = [contacts objectAtIndex:indexPath.row];
        
        if(contact.userIdValue == 0){
            self.selectedContact = contact;
            [self showInviteActionSheet];            
        }else{
            __block CTLCDContact *selectedContact = contact;            
            selectedContact.account = self.currentUser;
            
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL result, NSError *error){
                if(result){            
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:CTLChooseContactToMessageNotification object:selectedContact];
                    }];
                }else{                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:[error localizedDescription]
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"OK", nil];
                    [alertView show];
                }
            }];
        }
    }else{
        //Invite addressbook contact
        self.selectedContact = [contacts objectAtIndex:indexPath.row];
        [self showInviteActionSheet];        
    }
}

- (void)showInviteActionSheet
{
    NSString *contactName = [self.selectedContact valueForKey:@"compositeName"];
    NSString *inviteStr = [NSString stringWithFormat:NSLocalizedString(@"INVITE_CONTACT", nil), contactName];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:inviteStr
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil, nil];

    NSMutableArray *inviteTypes = [NSMutableArray array];    
    if([[self.selectedContact valueForKey:@"mobile"] length] > 0){
        [inviteTypes addObject:NSLocalizedString(@"SEND_INVITE_VIA_SMS", nil)];
    }
    
    if([[self.selectedContact valueForKey:@"email"] length] > 0){
        [inviteTypes addObject:NSLocalizedString(@"SEND_INVITE_VIA_EMAIL", nil)];
    }
    
    
    [inviteTypes addObject:NSLocalizedString(@"COPY_INVITE_LINK", nil)];
   
    
    for(NSInteger i=0;i<[inviteTypes count];i++){
        [actionSheet addButtonWithTitle:inviteTypes[i]];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
    [actionSheet setCancelButtonIndex:[inviteTypes count]]; 
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([[self.selectedContact valueForKey:@"email"] length] > 0 && [[self.selectedContact valueForKey:@"mobile"] length] > 0){
        switch(buttonIndex){
            case 0:
                [self inviteViaSms];
                break;
            case 1:
                [self inviteViaEmail];
                break;
            case 2:                
                [self copyInviteLink];
                break;
        }
    }else{        
        if([[self.selectedContact valueForKey:@"email"] length] > 0){
            [self inviteViaEmail];
        }else{
            [self inviteViaSms];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self toggleCheckMarkForCell:tableView atIndex:indexPath];
}

- (void)toggleCheckMarkForCell:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedIndex = indexPath;
    }else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.selectedIndex = nil;
    }
}

- (void)inviteViaSms
{
    [self saveInvitedRecipientToContacts:^(CTLCDContact *invitedContact){
        self.selectedContact = invitedContact;
        [[CTLAccountManager sharedInstance] createInviteLinkWithContact:self.selectedContact onComplete:^(NSString *invitationMessage){
            if([MFMessageComposeViewController canSendText]){
                MFMessageComposeViewController *smsController = [[MFMessageComposeViewController alloc] init];
                smsController.messageComposeDelegate = self;
                smsController.body = invitationMessage;
                [self createInviteMessage:invitationMessage];
                [self presentViewController:smsController animated:YES completion:nil];
            }else{
                [self displayAlertMessage: NSLocalizedString(@"DEVICE_NOT_CONFIGURED_TO_SEND_SMS", nil)];
            }
        } onError:^(NSError *error){
            [self displayAlertMessage:[error localizedDescription]];
        }];
    }];
}

- (void)inviteViaEmail
{    
    [self saveInvitedRecipientToContacts:^(CTLCDContact *invitedContact){        
        self.selectedContact = invitedContact;        
        [[CTLAccountManager sharedInstance] createInviteLinkWithContact:self.selectedContact onComplete:^(NSString *invitationMessage){
            if([MFMailComposeViewController canSendMail]){
                MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
                [mailController setMailComposeDelegate:self];
                [mailController setToRecipients:@[[self.selectedContact valueForKey:@"email"]]];
                [mailController setMessageBody:invitationMessage isHTML:NO];
                [self presentViewController:mailController animated:YES completion:nil];
            }else{
                [self displayAlertMessage: NSLocalizedString(@"DEVICE_NOT_CONFIGURED_TO_SEND_EMAIL", nil)];
            }            
        } onError:^(NSError *error){
            [self displayAlertMessage:[error localizedDescription]];            
        }];
    }];
}

-(void)copyInviteLink
{
    [self saveInvitedRecipientToContacts:^(CTLCDContact *invitedContact){
        self.selectedContact = invitedContact;
        [[CTLAccountManager sharedInstance] createInviteLinkOnlyWithContact:self.selectedContact onComplete:^(NSString *invitationLink){
            NSLog(@"INVITE LINK %@", invitationLink);
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = invitationLink;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"INVITE_LINK_COPIED", nil)
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            
            [alert show];
            
            
        } onError:^(NSError *error){
            [self displayAlertMessage:[error localizedDescription]];
        }];
    }];    
}

- (void)saveInvitedRecipientToContacts:(CTLCompletionWithInvitedContactBlock)completionBlock
{
    if([self.selectedContact isKindOfClass:[CTLABPerson class]]){        
        __block CTLCDContact *contact = [CTLCDContact MR_createEntity];
        [contact createFromABPerson:(CTLABPerson *)self.selectedContact];
        contact.account = self.currentUser;        
        completionBlock(contact);        
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL result, NSError *error){
            if(result){
                completionBlock(contact);
            }
        }];
    }else{
        completionBlock(self.selectedContact);
    }
}

#pragma mark - Message Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if(result == MFMailComposeResultSent){
        //invite sent
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if(result == MessageComposeResultSent){
        //invite sent        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)createInviteMessage:(NSString *)inviteMessage
{
    NSString *messageText = @"Invitation sent";
    
    CTLCDConversation *conversation = [CTLCDConversation MR_createEntity];       
    conversation.contact = self.selectedContact;
    conversation.account = self.currentUser;
    
    [[CTLMessageManager sharedInstance] sendInviteMessage:messageText withConversation:conversation completionBlock:^(CTLCDMessage *message, id responseObject){
        
        CTLInviteCell *cell = (CTLInviteCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndex];
        cell.detailTextLabel.text = @"Request pending";
        cell.detailTextLabel.textColor = [UIColor ctlRed];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } errorBlock:^(NSError *error){
        
    }];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didSelectPerson:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{        
    CTLABPerson *person = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView){
        person = [self.filteredContacts objectAtIndex:indexPath.row];
    }else{
        person = [self.contacts objectAtIndex:indexPath.row];
    }   
}

- (void)displayAlertMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
