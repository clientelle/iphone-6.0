//
//  CTLGroupsListViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 9/25/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import "CTLContactsListViewController.h"
#import "CTLGroupsListViewController.h"
#import "CTLSlideMenuController.h"

#import "CTLABGroup.h"
#import "CTLABPerson.h"
#import "CTLCDFormSchema.h"
#import "CTLCDPerson.h"

int const CTLNewGroupAlertViewTag    = 1;
int const CTLRenameGroupAlertViewTag = 2;
int const CTLDeleteGroupAlertViewTag = 3;

@implementation CTLGroupsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _addressBookRef = [self.menuController addressBookRef];
    
    _abGroups = [CTLABGroup groupsFromSourceType:kABSourceTypeLocal addressBookRef:_addressBookRef];
    _groupRecipients = [NSMutableArray array];
    
    _groupsDict = [NSMutableDictionary dictionary];
    
    for(NSInteger i=0;i<[_abGroups count];i++){
        ABRecordRef goupRef = (__bridge ABRecordRef)([_abGroups objectAtIndex:i]);
        ABRecordID groupID = ABRecordGetRecordID(goupRef);
        CTLABGroup *abGroup = [[CTLABGroup alloc] initWithGroupID:groupID addressBook:_addressBookRef];
        [_groupsDict setObject:abGroup forKey:@(groupID)];
    }
    
    if([_groupsDict count] > 0){
        _groupIDKeysArray = [_groupsDict allKeys];
    }else{
        _groupIDKeysArray = [NSArray array];
    }
    
    _groupMessageActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SEND_GROUP_MESSAGE", nil)
delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"GROUP_SMS", nil), NSLocalizedString(@"GROUP_EMAIL", nil), nil];
}

- (CTLABGroup *)groupFromIndexPath:(NSIndexPath *)indexPath
{
    id groupID = [_groupIDKeysArray objectAtIndex:indexPath.row];
    CTLABGroup *abGroup = [_groupsDict objectForKey:groupID];
    return abGroup;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_abGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTLABGroup *abGroup = [self groupFromIndexPath:indexPath];
    static NSString *CellIdentifier = @"groupDisplayRow";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = abGroup.name;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToRenameGroup:)];
    [cell addGestureRecognizer:longPressGesture];
    
    
    NSString *imageName = ([abGroup.members count] == 0) ? @"09-chat-gray-disabled.png" : @"09-chat-gray.png";
        
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    _selectedGroup = [self groupFromIndexPath:indexPath];

    if([_selectedGroup.members count] > 0){
        [_groupMessageActionSheet showInView:self.view];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"SEND_GROUP_MESSAGE", nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *instructions = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width-20, 30.0f)];
    [instructions setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
    [instructions setBackgroundColor:[UIColor clearColor]];
    [instructions setTextAlignment:NSTextAlignmentCenter];
    instructions.text = NSLocalizedString(@"GROUP_OPTIONS_INSTRUCTIONS", nil);
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 60.0f)];
    [footerView addSubview:instructions];
    return footerView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        _selectedIndexPath = indexPath;
        [self deleteGroupAtIndexPath:indexPath];
    }
}

#pragma mark - Adding and renaming Groups

- (void)longPressToRenameGroup:(UILongPressGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateBegan) {
		UITableViewCell *cell = (UITableViewCell *)[gesture view];
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        CTLABGroup *abGroup = [self groupFromIndexPath:indexPath];
        _selectedIndexPath = indexPath;
        _selectedGroup = abGroup;
        [self displayRenameGroupPrompt:abGroup.name];
	}
}

- (void)displayRenameGroupPrompt:(NSString *)originalGroupName
{
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"RENAME_GROUP_TO", nil), originalGroupName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                          otherButtonTitles:NSLocalizedString(@"SAVE", nil), nil];
    
    UITextField *textField = [self textFieldForAlertView:alert withTag:CTLRenameGroupAlertViewTag];
    textField.text = originalGroupName;
    [alert show];
}

- (IBAction)newGroupPrompt:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CREATE_NEW_GROUP", nil)
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                          otherButtonTitles:NSLocalizedString(@"CREATE", nil), nil];
    
    [self textFieldForAlertView:alert withTag:CTLNewGroupAlertViewTag];
    [alert show];
}

- (UITextField *)textFieldForAlertView:(UIAlertView *)alertView withTag:(int)tag
{
    alertView.tag = tag;
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = NSLocalizedString(@"ENTER_GROUP_NAME", nil);
    textField.clearButtonMode = YES;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
    return textField;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(alertView.tag){
        case CTLNewGroupAlertViewTag: //add new group
            if (buttonIndex == 1){
                [self createNewGroupFromPrompt:[[alertView textFieldAtIndex:0] text]];
            }
            break;
        case CTLRenameGroupAlertViewTag:
            if(buttonIndex == 1){
                [self renameGroup:[[alertView textFieldAtIndex:0] text]];
            }
            break;
        case CTLDeleteGroupAlertViewTag:
            if (buttonIndex == 1){
                [self deleteGroup];
                
            }
            break;
    }
}

- (void)createNewGroupFromPrompt:(NSString *)newGroupName
{
    ABRecordRef  existingGroupRef = [CTLABGroup findByName:newGroupName addressBookRef:_addressBookRef];

    if(existingGroupRef){
        NSString *dupMessage = [NSString stringWithFormat:NSLocalizedString(@"GROUP_EXISTS", nil), newGroupName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:dupMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        return;
    }
                
    ABRecordID groupID = [CTLABGroup createGroup:newGroupName addressBookRef:_addressBookRef];
    if(groupID != kABRecordInvalidID){
        CTLCDFormSchema *formSchema = [CTLCDFormSchema MR_createEntity];
        formSchema.groupIDValue = groupID;
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        //set the selected group to new group and transition back to contact list
        [CTLABGroup saveDefaultGroupID:groupID];
        [self.menuController setMainView:@"contactsNavigationController"];
    }
}


- (void)deleteGroupAtIndexPath:(NSIndexPath *)indexPath
{
    CTLABGroup *abGroup = [self groupFromIndexPath:indexPath];
    
    //User cannot delete client or prospect groups
    if(abGroup.groupID == [CTLABGroup clientGroupID]){
        NSString *permissionErrorStr = [NSString stringWithFormat:NSLocalizedString(@"CANNOT_DELETE_SYSTEM_GROUP", nil), abGroup.name];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:permissionErrorStr delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    NSString *message = nil;
    NSInteger memberCount = [abGroup.members count];
    if(memberCount > 0){
        //Warn the user that group has members
        message = [NSString stringWithFormat:NSLocalizedString(@"GROUP_HAS_CONTACTS", nil), abGroup.name, memberCount];
    }else{
        //Confirm delete
        message = [NSString stringWithFormat:NSLocalizedString(@"CONFIRM_DELETE", nil), abGroup.name];
    }
    
    UIAlertView *confirmView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"DELETE", nil), nil];
    confirmView.tag = CTLDeleteGroupAlertViewTag;
    [confirmView show];
}

- (void)deleteGroup
{
    CTLABGroup *abGroup = [self groupFromIndexPath:_selectedIndexPath];
    ABRecordID deletedGroupID = abGroup.groupID;
    
    if([abGroup.members count] > 0){
        [abGroup removeMembers];
    }

    if([abGroup deleteGroup:abGroup.groupRef]){
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_groupsDict removeObjectForKey:@(abGroup.groupID)];
        _groupIDKeysArray = [_groupsDict allKeys];
        NSMutableArray *tempGroupArray = [NSMutableArray arrayWithArray:_abGroups];
        [tempGroupArray removeObjectAtIndex:_selectedIndexPath.row];
        _abGroups = tempGroupArray;
        _selectedIndexPath = nil;
        [self.tableView endUpdates];
    }
    
    /*
     * if the active contact list (group) was deleted.
     * reset the contact list to"clients" (default)
     */
    if(deletedGroupID == [CTLABGroup defaultGroupID]){
        ABRecordID clientGroupID = [CTLABGroup clientGroupID];
        if([CTLABGroup groupDoesExist:clientGroupID addressBookRef:_addressBookRef]){
            [CTLABGroup saveDefaultGroupID:clientGroupID];
        }else{
            //Client group was removed :(
            [CTLABGroup saveDefaultGroupID:CTLAllContactsGroupID];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCTLClientGroupID];
        }
    }
}

- (void)renameGroup:(NSString *)newGroupName
{
    UITableViewCell *groupCell = [self.tableView cellForRowAtIndexPath:_selectedIndexPath];
    NSString *oldGroupName = groupCell.textLabel.text;
    
    if([oldGroupName isEqualToString:newGroupName]){
        return;
    }
    
    CTLCDFormSchema *formSchema = [CTLCDFormSchema MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"groupID=%i", _selectedGroup.groupID]];
    
    //some groups may exist before or created outside the app so lets create a schema for it
    if(!formSchema){
        formSchema = [CTLCDFormSchema MR_createEntity];
        formSchema.groupID = @(_selectedGroup.groupID);
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context MR_saveToPersistentStoreAndWait];
    }
        
    if([CTLABGroup findByName:newGroupName addressBookRef:_addressBookRef]){
        NSString *dupMessage = [NSString stringWithFormat:NSLocalizedString(@"GROUP_EXISTS", nil), newGroupName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CANNOT_RENAME_GROUP", nil) message:dupMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }else{
        if([_selectedGroup renameTo:newGroupName]){
            groupCell.textLabel.text = newGroupName;
            _selectedGroup.name = newGroupName;
        }
    }
}

#pragma mark - Group Messaging

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch(buttonIndex){
        case 0:
            [self displayMessageComposer];
            break;
        case 1:
            [self displayMailComposer];
            break;
    }
}

- (void)displayMailComposer
{
    if(![MFMailComposeViewController canSendMail]){
        [self displayAlertMessage: NSLocalizedString(@"DEVICE_NOT_CONFIGURED_TO_SEND_EMAIL", nil)];
        return;
    }
    
    NSArray *recipientEmails = [self recipientArrayForKey:CTLPersonEmailProperty];
    if([recipientEmails count] > 0){
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        mailController.toRecipients = recipientEmails;
        [self presentViewController:mailController animated:YES completion:nil];
    }
}

- (void)displayMessageComposer
{
    if(![MFMessageComposeViewController canSendText]){
        [self displayAlertMessage:NSLocalizedString(@"DEVICE_NOT_CONFIGURED_TO_SEND_SMS", nil)];
        return;
    }
    
    NSArray *recipientNumbers = [self recipientArrayForKey:CTLPersonPhoneProperty];
    if([recipientNumbers count] > 0){
        MFMessageComposeViewController *smsController = [[MFMessageComposeViewController alloc] init];
        smsController.messageComposeDelegate = self;
        smsController.recipients = recipientNumbers;
        [self presentViewController:smsController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if(result == MFMailComposeResultSent){
        [self updateTimestampsForRecipients];
    }
    [_groupRecipients removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if(result == MessageComposeResultSent){
        [self updateTimestampsForRecipients];
    }
    [_groupRecipients removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)recipientArrayForKey:(NSString *)field
{
    NSMutableArray *contactDataArray = [NSMutableArray array];
    for(NSNumber *recordID in _selectedGroup.members){
        CTLABPerson *contact = [_selectedGroup.members objectForKey:recordID];
        NSString *contactStr = [contact valueForKey:field];
        if([contactStr length] > 0){
            [contactDataArray addObject:contactStr];
            [_groupRecipients addObject:@(contact.recordID)];
        }
    }
    return contactDataArray;
}

- (void)updateTimestampsForRecipients
{
    NSInteger recipientCount = [_groupRecipients count];
    if(recipientCount > 0){
        for(NSInteger i=0;i<recipientCount; i++){
            ABRecordID recordID = [[_groupRecipients objectAtIndex:i] intValue];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordID=%i", recordID];
            CTLCDPerson *person = [CTLCDPerson MR_findFirstWithPredicate:predicate];
            if(!person.recordID){
                person = [CTLCDPerson MR_createEntity];
                person.recordIDValue = recordID;
            }
            person.lastAccessed = [NSDate date];
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
            //[[NSNotificationCenter defaultCenter] postNotificationName:CTLContactListReloadNotification object:@(_selectedGroup.groupID)];
        }];
    }
}

- (void)displayAlertMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Cleanup

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
