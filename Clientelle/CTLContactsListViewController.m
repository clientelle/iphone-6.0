#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "NSString+CTLString.h"
#import "NSDate+CTLDate.h"
#import "UILabel+CTLLabel.h"

#import "CTLContactsListViewController.h"
#import "CTLContactDetailsViewController.h"
#import "CTLContactImportViewController.h"
#import "CTLAppointmentFormViewController.h"
#import "CTLContactCell.h"

#import "CTLABPerson.h"
#import "CTLCDContact.h"

#import "CTLPickerView.h"
#import "CTLPickerButton.h"
#import "KBPopupBubbleView.h"

#import "CTLAccountManager.h"
#import "CTLCDAccount.h"

NSString *const CTLContactsWereImportedNotification = @"com.clientelle.notifications.contactsWereImported";
NSString *const CTLContactListReloadNotification = @"com.clientelle.notifications.reloadContacts";
NSString *const CTLTimestampForRowNotification = @"com.clientelle.notifications.updateContactTimestamp";
NSString *const CTLNewContactWasAddedNotification = @"com.clientelle.com.notifications.contactWasAdded";
NSString *const CTLContactRowDidChangeNotification = @"com.clientelle.com.notifications.contactRowDidChange";

NSString *const CTLImporterSegueIdentifier = @"toImporter";
NSString *const CTLContactFormSegueIdentifier = @"toContactForm";
NSString *const CTLAppointmentSegueIdentifier = @"toSetAppointment";

int const CTLShareContactActionSheetTag = 800;
int const CTLAddContactActionSheetTag = 801;
int const CTLMessageActionSheetTag = 802;
int const CTLDialActionSheetTag = 803;

@interface CTLContactsListViewController ()
@property (nonatomic, strong) CTLCDAccount *currentUser;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) CTLCDContact *selectedPerson;
@property (nonatomic, strong) NSMutableArray *filteredContacts;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, assign) BOOL inContactMode;
@property (nonatomic, assign) BOOL shouldReorderListOnScroll;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@end

@implementation CTLContactsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    self.currentUser = [[CTLAccountManager sharedInstance] currentUser];
    
    self.emptyView = [self noContactsView];
    self.inContactMode = NO;
    self.shouldReorderListOnScroll = NO;
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    
    self.navigationItem.title = NSLocalizedString(@"CONTACTS", nil);
    [self rightTitlebarWithAddContactButton];
    [self prepareContactViewMode];
    
    //load users contacts
    [self loadAllContacts];
    
    [self registerNotificationsObservers];
}

#pragma mark - Loading Contact List

- (void)loadAllContacts
{
    self.filteredContacts = [NSMutableArray array];
    
    if([self.currentUser.contacts count] > 0){
        
        [self buildSearchBar];
       
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"account = %@", self.currentUser];
        self.fetchedResultsController = [CTLCDContact fetchAllSortedBy:@"lastAccessed" ascending:NO withPredicate:predicate groupBy:nil delegate:self];
        [self.fetchedResultsController performFetch:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView setContentOffset:CGPointMake(0.0f, CGRectGetHeight(self.searchBar.bounds))];
        });
    }
    
    [self.tableView reloadData];
}

#pragma mark NSFetchResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            // do nothing
        }
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

- (void)reloadContactListAfterImport:(NSNotification *)notification
{
    [self loadAllContacts];
}

- (void)reloadContactList:(NSNotification *)notification
{
    [self loadAllContacts];
}

#pragma mark - Sort Contacts Picker

- (void)buildSearchBar
{
    if(!self.tableView.tableHeaderView){
        self.tableView.tableHeaderView = self.searchBar;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView setContentOffset:CGPointMake(0.0f, CGRectGetHeight(self.searchBar.bounds))];
    });
}


- (void)rightTitlebarWithEditContactButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"14-gear"] style:UIBarButtonItemStyleDone target:self action:@selector(editContact:)];
}

- (void)rightTitlebarWithAddContactButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:@selector(displayAddContactActionSheet:)];
}

- (void)rightTitlebarWithDoneButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort"] style:UIBarButtonItemStyleDone target:self action:@selector(selectSortFilter:)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - Sort Picker Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)displayAddContactActionSheet:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ADD_NEW_CONTACT", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"NEW_CONTACT", nil), NSLocalizedString(@"IMPORT_CONTACTS", nil), nil];
    actionSheet.tag = CTLAddContactActionSheetTag;
    [actionSheet showInView:self.view];
}


- (void)displayShareContactActionSheet:(id)sender
{
    NSString *contactName = [NSString stringWithFormat:NSLocalizedString(@"FORWARD_CONTACT", nil), self.selectedPerson.firstName];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:contactName
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"SEND_VIA_SMS", nil), NSLocalizedString(@"SEND_VIA_EMAIL", nil), nil];
    
    actionSheet.tag = CTLShareContactActionSheetTag;
    [actionSheet showInView:self.view];
}

- (void)displayMessageActionSheet:(NSArray *)buttons
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil, nil];
    for(NSInteger i=0;i<[buttons count];i++){
        [actionSheet addButtonWithTitle:buttons[i]];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
    [actionSheet setCancelButtonIndex:[buttons count]];
    
    actionSheet.tag = CTLMessageActionSheetTag;
    [actionSheet showInView:self.view];
}

- (void)displayDialActionSheet:(NSArray *)phoneNumbers
{
    NSString *callMobile = [NSString stringWithFormat:NSLocalizedString(@"CALL_MOBILE", nil), phoneNumbers[0]];
    NSString *callPhone = [NSString stringWithFormat:NSLocalizedString(@"CALL_PHONE", nil), phoneNumbers[1]];
  
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:callMobile, callPhone, nil];
    actionSheet.tag = CTLDialActionSheetTag;
    [actionSheet showInView:self.view];
}

#pragma mark - Prompt Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
     switch(actionSheet.tag){
        case CTLAddContactActionSheetTag:
            switch(buttonIndex){
                case 0:
                    self.selectedPerson = nil;
                    [self performSegueWithIdentifier:CTLContactFormSegueIdentifier sender:actionSheet];
                    break;
                case 1:
                    [self performSegueWithIdentifier:CTLImporterSegueIdentifier sender:actionSheet];
                    break;
            }
            break;
        case CTLShareContactActionSheetTag:
            switch(buttonIndex){
                case 0:
                    [self shareContactViaSMS:actionSheet];
                    break;
                case 1:
                    [self shareContactViaEmail:actionSheet];
                    break;
                case 2:
                    [self.contactHeader removeHighlight];
                    break;
            }
            break;
         case CTLMessageActionSheetTag:
             switch(buttonIndex){
                 case 0:
                     [self showSMSForPerson:actionSheet];
                     break;
                 case 1:
                     [self showEmailForPerson:actionSheet];
                     break;
                 case 2:
                     [self showCtlMessengerForPerson:actionSheet];
                     break;
             }
             break;
         case CTLDialActionSheetTag:
             switch(buttonIndex){
                 case 0:
                     [self dialContact:self.selectedPerson.mobile];
                     break;
                 case 1:
                     [self dialContact:self.selectedPerson.phone];
                     break;
                     break;
             }
             break;
    }
}

#pragma mark - Segue Actions

- (void)editContact:(id)sender
{
    [self performSegueWithIdentifier:CTLContactFormSegueIdentifier sender:sender];
}

- (void)showImporter:(id)sender
{
    [self performSegueWithIdentifier:CTLImporterSegueIdentifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:CTLContactFormSegueIdentifier]) {
        CTLContactDetailsViewController *contactFormViewController = [segue destinationViewController];
        if(self.selectedPerson){
            [contactFormViewController setContact:self.selectedPerson];
        }
        return;
    }
    
    if([[segue identifier] isEqualToString:CTLAppointmentSegueIdentifier]){
        UINavigationController *navigationController = [segue destinationViewController];
        CTLAppointmentFormViewController *appointmentViewController = (CTLAppointmentFormViewController *)navigationController.topViewController;
        [appointmentViewController setPresentedAsModal:YES];
        [appointmentViewController setContact:self.selectedPerson];
        return;
    }
}


#pragma mark - Contact View

- (void)prepareContactViewMode
{
    CGFloat shadowOffset = 5.0f;
    CGSize viewSize = self.view.bounds.size;
    
    self.contactHeader = [[CTLContactHeaderView alloc] initWithFrame:CGRectMake(0, -CTLContactViewHeaderHeight - shadowOffset, viewSize.width, CTLContactViewHeaderHeight)];
    self.contactHeader.delegate = self;
    
    self.contactToolbar = [[CTLContactToolbarView alloc] initWithFrame:CGRectMake(0, viewSize.height + CTLContactModeToolbarViewHeight + shadowOffset, viewSize.width, CTLContactModeToolbarViewHeight)];
    self.contactToolbar.delegate = self;

    [self.view addSubview:self.contactHeader];
    [self.view addSubview:self.contactToolbar];
}

- (UIView *)noContactsView
{
    CGRect viewFrame = self.view.frame;
    
    UIView *emptyView = [[UIView alloc] initWithFrame:viewFrame];
    UIColor *textColor = [UIColor colorFromUnNormalizedRGB:76.0f green:91.0f blue:130.0f alpha:1.0f];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90.0f, viewFrame.size.width, 25.0f)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont fontWithName:kCTLAppFontMedium size:20.0f]];
    [titleLabel setTextColor:textColor];
    [titleLabel setText:NSLocalizedString(@"NO_CLIENTS", nil)];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120.0f, viewFrame.size.width, 25.0f)];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    [messageLabel setFont:[UIFont fontWithName:kCTLAppFont size:14.0f]];
    [messageLabel setTextColor:textColor];
    [messageLabel setText:NSLocalizedString(@"EMPTY_CONTACTS_MSG", nil)];
        
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [[UIImage imageNamed:@"whiteButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // Set the background for any states you plan to use
    [addButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor colorFromUnNormalizedRGB:81.0f green:91.0f blue:130.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [addButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [addButton setTitleColor:[UIColor colorFromUnNormalizedRGB:61.0f green:71.0f blue:110.0f alpha:1.0f] forState:UIControlStateHighlighted];
    
    UIFont *buttonFont = [UIFont fontWithName:kCTLAppFontMedium size:14.0f];
    NSString *buttonString = NSLocalizedString(@"ADD_CONTACTS", nil);
    CGSize buttonSize = [buttonString sizeWithFont:buttonFont];
    CGFloat buttonWidth = buttonSize.width + 20.0f;
    CGFloat buttonCenter = (viewFrame.size.width/2) - (buttonWidth/2);
    
    [addButton setFrame:CGRectMake(buttonCenter, 175.0f, buttonWidth, 38.0f)];
    [addButton.titleLabel setFont:buttonFont];
    [addButton addTarget:self action:@selector(displayAddContactActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTitle:buttonString forState:UIControlStateNormal];
    
    addButton.layer.shadowOpacity = 0.2f;
    addButton.layer.shadowRadius = 1.0f;
    addButton.layer.shadowOffset = CGSizeMake(0,0);
    
    [emptyView addSubview:titleLabel];
    [emptyView addSubview:messageLabel];
    [emptyView addSubview:addButton];
        
    return emptyView;
}

- (void)enterContactMode:(CTLCDContact *)contact
{
    self.selectedPerson = contact;
    [self rightTitlebarWithEditContactButton];
    [self populateViewData:self.contactHeader withContact:contact];
    [self configureContactToolbar:self.contactToolbar forContact:contact];
    
    if(self.inContactMode){
        return;
    }
    
    self.inContactMode = true;
    
    CGRect headerFrame = self.contactHeader.frame;
    CGRect toolbarFrame = self.contactToolbar.frame;
     
    headerFrame.origin.y = 0;
    toolbarFrame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(toolbarFrame) + 5;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.contactHeader.frame = headerFrame;
        self.contactToolbar.frame = toolbarFrame;
    }];
}

- (void)populateViewData:(CTLContactHeaderView *)headerView withContact:(CTLCDContact *)contact
{
    [headerView removeHighlight];
    headerView.nameLabel.text = contact.compositeName;
    headerView.phoneLabel.text = [contact displayContactStr];
    
    if(contact.picture){
        headerView.pictureView.image = [[UIImage alloc] initWithData:contact.picture];
    }else{
        headerView.pictureView.image = [UIImage imageNamed:@"default-pic"];
    }
    
    [UILabel autoWidth:headerView.nameLabel];
    [UILabel autoWidth:headerView.phoneLabel];
}

- (void)configureContactToolbar:(CTLContactToolbarView *)toolbar forContact:(CTLCDContact *)contact
{    
    BOOL hasEmail = [contact.email length] > 0;
    BOOL hasMobile = [contact.mobile length] > 0;

    if(hasMobile && hasEmail){
        [self updateMessageButton:CTLMessagePreferenceTypeAsk];
    }else if(hasMobile){
        [self updateMessageButton:CTLMessagePreferenceTypeSms];
    }else if(hasEmail){
        [self updateMessageButton:CTLMessagePreferenceTypeEmail];
    }
}

- (void)updateMessageButton:(CTLMessagePreferenceType)messagePreference
{
    NSString *icon = [NSString stringWithFormat:@"message-button-type-%u", messagePreference];
        
    [self.contactToolbar.messageButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    
    switch(messagePreference){
        case CTLMessagePreferenceTypeUndetermined:
            [self.contactToolbar.messageButton addTarget:self action:@selector(showMessagePreferencePrompt:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case CTLMessagePreferenceTypeAsk:
            [self.contactToolbar.messageButton addTarget:self action:@selector(showMessageActionSheet:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case CTLMessagePreferenceTypeEmail:
            self.contactToolbar.messageButton.enabled = [MFMailComposeViewController canSendMail];
            [self.contactToolbar.messageButton addTarget:self action:@selector(showEmailForPerson:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case CTLMessagePreferenceTypeSms:
            self.contactToolbar.messageButton.enabled = [MFMessageComposeViewController canSendText];
            [self.contactToolbar.messageButton addTarget:self action:@selector(showSMSForPerson:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case CTLMessagePreferenceTypeCtl:
            [self.contactToolbar.messageButton addTarget:self action:@selector(showCtlMessengerForPerson:) forControlEvents:UIControlEventTouchUpInside];
            break;
    }

    [self.contactToolbar.messageButton setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
}

- (void)exitContactMode:(NSNotification *)notification
{
    [self exitContactMode];
}

- (void)exitContactMode
{
    [self rightTitlebarWithAddContactButton];
    [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    CTLContactCell *cell = (CTLContactCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [cell.indicatorLayer removeFromSuperlayer];
    
    CGRect headerFrame = self.contactHeader.frame;
    CGRect footerFrame = self.contactToolbar.frame;
    
    headerFrame.origin.y = -100;
    footerFrame.origin.y = CGRectGetHeight(self.view.bounds) + 5;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.contactHeader.frame = headerFrame;
        self.contactToolbar.frame = footerFrame;
        [self.view setBackgroundColor:[UIColor whiteColor]];
    } completion:^(BOOL finished){
        self.inContactMode = NO;
        self.selectedPerson = nil;
        self.selectedIndexPath = nil;
        if(self.shouldReorderListOnScroll){
            [self loadAllContacts];
            self.shouldReorderListOnScroll = NO;
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    if(self.inContactMode){
        [self rightTitlebarWithAddContactButton];
        [self exitContactMode];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
    UIView *touchedView = [self.view hitTest:touchPoint withEvent:nil];
    return (touchedView == self.tableView || touchedView == self.emptyView);
}

#pragma mark - TableViewController Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return [self.filteredContacts count];
    }
    
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"contactRow";
    CTLContactCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[CTLContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    CTLCDContact *contact = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        contact = [self.filteredContacts objectAtIndex:indexPath.row];
    }else{
        contact = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
    }
     
    cell.nameLabel.text = [self generatePersonName:contact];
    cell.detailsLabel.text = [contact displayContactStr];
    
    if(contact.lastAccessed){
        cell.timestampLabel.text = [self generateDateStamp:contact.lastAccessed];
    }
    
    [cell showingDeleteConfirmation];
    
    return cell;
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
        CTLCDContact *contact = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            [contact deleteInContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            //NOTE: Clean up appointments?
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([[self.fetchedResultsController fetchedObjects] count] == 0){
        return self.view.bounds.size.height;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([[self.fetchedResultsController fetchedObjects] count] == 0){
        return self.emptyView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if there is a previously selected cell, clear that indicator
    if(self.selectedIndexPath != nil){
        CTLContactCell *selectedCell = (CTLContactCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        [selectedCell.indicatorLayer removeFromSuperlayer];
    }
    
    //mark selected cell with indicator
    CTLContactCell *cell = (CTLContactCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setIndicator];
    
    if(tableView == self.searchDisplayController.searchResultsTableView){
        self.selectedPerson = [self.filteredContacts objectAtIndex:indexPath.row];
        [self.searchDisplayController setActive:NO animated:YES];
    }else{
        self.selectedPerson = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
    }

    self.selectedIndexPath = indexPath;
    [self enterContactMode:self.selectedPerson];
}

- (void)deleteContact:(CTLCDContact *)contact
{
    [contact MR_deleteEntity];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

- (NSString *)generatePersonName:(CTLCDContact *)person
{
    NSMutableString *compositeName = [NSMutableString stringWithString:@""];

    if([person.firstName length] > 0){
        [compositeName appendString:person.firstName];
    }
    
    if([person.lastName length] > 0){
        [compositeName appendFormat:@" %@", person.lastName];
    }
    
    return compositeName;
}

#pragma mark - Toolbar Actions

- (void)showAppointmentScheduler:(id)sender
{
    [self performSegueWithIdentifier:CTLAppointmentSegueIdentifier sender:sender];
}

- (void)showDialPerson:(id)sender
{
    BOOL hasPhone = [self.selectedPerson.phone length] > 0;
    BOOL hasMobile = [self.selectedPerson.mobile length] > 0;
    
    //contact has phone and mobile display actionsheet for them to choose
    if(hasPhone && hasMobile){
        NSArray *phoneNumbers = @[self.selectedPerson.mobile, self.selectedPerson.phone];
        [self displayDialActionSheet:phoneNumbers];
    }else{
        if(hasPhone){
            [self dialContact:self.selectedPerson.phone];
        }else if(hasMobile){
            [self dialContact:self.selectedPerson.mobile];
        }
    }
}

- (void)dialContact:(NSString *)phoneNumber
{
    NSString *cleanPhoneNumber = [NSString cleanPhoneNumber:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", cleanPhoneNumber]]];
    [self saveTimestampForContact];
}

- (void)showEmailForPerson:(id)sender
{
    if(self.selectedPerson.email){
        if([MFMailComposeViewController canSendMail]){
            MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
            [mailController setMailComposeDelegate:self];
            [mailController setToRecipients:@[self.selectedPerson.email]];
            [self presentViewController:mailController animated:YES completion:nil];
        }else{
            [self displayAlertMessage: NSLocalizedString(@"DEVICE_NOT_CONFIGURED_TO_SEND_EMAIL", nil)];
        }
    }
}

- (void)showSMSForPerson:(id)sender
{
    if(self.selectedPerson.mobile){
        if([MFMessageComposeViewController canSendText]){
            NSString *sms = [NSString stringWithFormat:@"sms: %@", [NSString cleanPhoneNumber:self.selectedPerson.mobile]];
            NSString *smsEncoded = [sms stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:smsEncoded]];
            [self saveTimestampForContact];
        }else{
            [self displayAlertMessage: NSLocalizedString(@"DEVICE_NOT_CONFIGURED_TO_SEND_SMS", nil)];
        }
    }
}

- (void)showCtlMessengerForPerson:(id)sender
{
    NSLog(@"showCtlMessengerForPerson");
    return;
}

- (void)showMessageActionSheet:(id)sender
{
    NSMutableArray *messageTypes = [NSMutableArray array];

    if([self.selectedPerson.mobile length] > 0){
        [messageTypes addObject:NSLocalizedString(@"SEND_SMS", nil)];
    }
    
    if([self.selectedPerson.email length] > 0){
        [messageTypes addObject:NSLocalizedString(@"SEND_EMAIL", nil)];
    }
    
    if(self.selectedPerson.hasMessengerValue == 1){
        [messageTypes addObject:NSLocalizedString(@"SEND_PRIVATE_MESSAGE", nil)];
    }
    
    [self displayMessageActionSheet:messageTypes];
}

#pragma mark - Updating Timestamp for Contact Row

- (NSString *)generateDateStamp:(NSDate *)date
{
    NSString *timestampDate = [NSDate formatShortDateOnly:date];
    NSString *currentDate = [NSDate formatShortDateOnly:[NSDate date]];
    
    if([timestampDate isEqualToString:currentDate]){
        timestampDate = [NSDate formatShortTimeOnly:date];
    }
    
    return timestampDate;
}

- (void)saveTimestampForContact
{
    self.selectedPerson.lastAccessed = [NSDate date];
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
        CTLContactCell *cell = (CTLContactCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.timestampLabel.text = [NSDate formatShortTimeOnly:[NSDate date]];
        self.shouldReorderListOnScroll = YES;
    }];
}

- (void)timestampForRowDidChange:(NSNotification *)notification
{
    [self saveTimestampForContact];
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)filterContactListForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[self.filteredContacts removeAllObjects];
    
    NSArray *contacts = [self.fetchedResultsController fetchedObjects];
    
	for (NSInteger i=0;i<[contacts count]; i++){
        CTLCDContact *person = contacts[i];
        NSComparisonResult result = [person.compositeName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        if (result == NSOrderedSame){
            [self.filteredContacts addObject:person];
        }
	}
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    UITableView *tableView = controller.searchResultsTableView;
    tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContactListForSearchText:searchString scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSArray *buttonTitles = [self.searchDisplayController.searchBar scopeButtonTitles];
    NSString *scope = [buttonTitles objectAtIndex:searchOption];
    NSString *text = [self.searchDisplayController.searchBar text];
    [self filterContactListForSearchText:text scope:scope];
    return YES;
}

#pragma mark - Share Contact

- (void)shareContactViaSMS:(id)sender
{
    if(![MFMessageComposeViewController canSendText]){
        [self displayAlertMessage: NSLocalizedString(@"DEVICE_NOT_CONFIGURED_TO_SEND_SMS", nil)];
        return;
    }
    
    MFMessageComposeViewController *smsController = [[MFMessageComposeViewController alloc] init];
    smsController.messageComposeDelegate = self;
    smsController.body = [self generateShareContactMessageString];
    [self presentViewController:smsController animated:YES completion:nil];
}

- (void)shareContactViaEmail:(id)sender
{
    if(![MFMailComposeViewController canSendMail]){
        [self displayAlertMessage:NSLocalizedString(@"DEVICE_NOT_CONFIGURED_TO_SEND_EMAIL", nil)];
        return;
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setMessageBody:[self generateShareContactMessageString] isHTML:NO];
    [self presentViewController:mailController animated:YES completion:nil];
}

- (NSString *)generateShareContactMessageString
{
    NSString *body = [NSString stringWithFormat:NSLocalizedString(@"SHARE_CONTACT_MSG", nil), self.selectedPerson.firstName];
    
    if([self.selectedPerson.phone length] > 0){
        body = [body stringByAppendingFormat:NSLocalizedString(@"PHONE_COLON", nil), self.selectedPerson.phone];
        if([self.selectedPerson.email length] > 0){
            body = [body stringByAppendingString:@", "];
        }
    }
    
    if([self.selectedPerson.email length] > 0){
        body = [body stringByAppendingFormat:NSLocalizedString(@"EMAIL_COLON", nil), self.selectedPerson.email];
    }
    
    return body;
}

- (void)displayAlertMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Handle Notifications
- (void)newContactWasAdded:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[CTLCDContact class]]){
        self.selectedPerson = notification.object;
        self.shouldReorderListOnScroll = YES;
        [self loadAllContacts];
        [self enterContactMode:notification.object];
    }
}

- (void)contactRowDidChange:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[CTLCDContact class]]){
        self.selectedPerson = notification.object;
        self.shouldReorderListOnScroll = YES;
        [self loadAllContacts];
        [self populateViewData:self.contactHeader withContact:self.selectedPerson];
    }
}

#pragma mark - Message Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if(result == MFMailComposeResultSent){
        [self saveTimestampForContact];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if(result == MessageComposeResultSent){
        [self saveTimestampForContact];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)registerNotificationsObservers
{
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    
    [notifCenter addObserver:self selector:@selector(displayShareContactActionSheet:) name:CTLShareContactNotification object:nil];
    [notifCenter addObserver:self selector:@selector(reloadContactListAfterImport:) name:CTLContactsWereImportedNotification object:nil];
    [notifCenter addObserver:self selector:@selector(reloadContactList:) name:CTLContactListReloadNotification object:nil];
    [notifCenter addObserver:self selector:@selector(timestampForRowDidChange:) name:CTLTimestampForRowNotification object:nil];
    [notifCenter addObserver:self selector:@selector(newContactWasAdded:) name:CTLNewContactWasAddedNotification object:nil];
    [notifCenter addObserver:self selector:@selector(contactRowDidChange:) name:CTLContactRowDidChangeNotification object:nil];
}

- (void)dealloc
{
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter removeObserver:self name:CTLShareContactNotification object:nil];
    [notifCenter removeObserver:self name:CTLContactsWereImportedNotification object:nil];
    [notifCenter removeObserver:self name:CTLContactListReloadNotification object:nil];
    [notifCenter removeObserver:self name:CTLTimestampForRowNotification object:nil];
    [notifCenter removeObserver:self name:CTLNewContactWasAddedNotification object:nil];
    [notifCenter removeObserver:self name:CTLContactRowDidChangeNotification object:nil];
}

@end
