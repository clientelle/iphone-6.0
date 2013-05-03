#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "NSString+CTLString.h"
#import "NSDate+CTLDate.h"
#import "UILabel+CTLLabel.h"

#import "CTLSlideMenuController.h"

#import "CTLContactsListViewController.h"

#import "CTLContactViewController.h"
#import "CTLContactImportViewController.h"

#import "CTLAppointmentFormViewController.h"

#import "CTLContactCell.h"
#import "CTLContactHeaderView.h"
#import "CTLContactToolbarView.h"

#import "CTLABPerson.h"
#import "CTLCDPerson.h"
#import "CTLCDFormSchema.h"

#import "CTLPickerView.h"
#import "CTLPickerButton.h"
#import "KBPopupBubbleView.h"

NSString *const CTLContactsWereImportedNotification = @"com.clientelle.notifications.contactsWereImported";
NSString *const CTLContactListReloadNotification = @"com.clientelle.notifications.reloadContacts";
NSString *const CTLTimestampForRowNotification = @"com.clientelle.notifications.updateContactTimestamp";
NSString *const CTLNewContactWasAddedNotification = @"com.clientelle.com.notifications.contactWasAdded";
NSString *const CTLContactRowDidChangeNotification = @"com.clientelle.com.notifications.contactRowDidChange";
NSString *const CTLSortOrderSelectedIndex = @"com.clientelle.notifcations.selectedSortOrder";

NSString *const CTLImporterSegueIdentifyer = @"toImporter";
NSString *const CTLContactListSegueIdentifyer = @"toContacts";
NSString *const CTLContactFormSegueIdentifyer = @"toContactForm";
NSString *const CTLAppointmentSegueIdentifyer = @"toSetAppointment";

int const CTLAllContactsGroupID = 0;
int const CTLShareContactActionSheetTag = 234;
int const CTLAddContactActionSheetTag = 424;

@implementation CTLContactsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _inContactMode = NO;
    _shouldReorderListOnScroll = NO;
    _emptyView = [self noContactsView];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];

    [self rightTitlebarWithAddContactButton];
    
    [self prepareContactViewMode];
    
    [self buildSortPicker];
    
    //[self checkAddressbookPermission];
    [self loadAllContacts];
    [self registerNotificationsObservers];
    
    if([_contacts count] > 0){
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"display_sort_tooltip_once"]){
            [self displaySortTooltip:nil];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"display_sort_tooltip_once"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_sortTooltip removeFromSuperview];
}

- (void)displaySortTooltip:(id)userInfo
{
    CGFloat bubbleWidth = 248.0f;
    CGFloat bubbleHeight = 100.0f;
    
    _sortTooltip = [[KBPopupBubbleView alloc] initWithFrame:CGRectMake((320.0f/2.0f)-(bubbleWidth/2), 0, bubbleWidth, bubbleHeight) text:NSLocalizedString(@"SORT_TOOTLIP", nil)];
    [_sortTooltip setPosition:0.5f animated:NO];
    [_sortTooltip setSide:kKBPopupPointerSideTop];
    [_sortTooltip showInView:self.view animated:YES];
}

- (void)removeSortTooltip
{
    if(_sortTooltip){
        [_sortTooltip removeFromSuperview];
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
                [self loadAllContacts];
            }else{
                [self displayPermissionPrompt];
            }
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access.
        self.addressBookRef = addressBookRef;
        [self loadAllContacts];
        
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

#pragma mark - Loading Contact List

- (int)savedSortOrderIndex
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:CTLSortOrderSelectedIndex];
}

- (void)saveSortOrder:(NSInteger)filterIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:filterIndex forKey:CTLSortOrderSelectedIndex];
    [defaults synchronize];
}

- (void)loadAllContacts
{
    _contacts = [CTLCDPerson findAll];
    _filteredContacts = [NSMutableArray array];
    
    if([_contacts count] > 0){
        
        [self buildSearchBar];
       
        NSInteger row = [_sortPickerView selectedRowInComponent:0];
        
        NSString *field = _sortArray[row][@"field"];
        BOOL asc = [_sortArray[row][@"asc"] boolValue];
        
        NSSortDescriptor *sortByAccessDate = [NSSortDescriptor sortDescriptorWithKey:field ascending:asc];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByAccessDate];
         
        _contacts = [_contacts sortedArrayUsingDescriptors:sortDescriptors];
     
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView setContentOffset:CGPointMake(0.0f, CGRectGetHeight(self.searchBar.bounds))];
        });
    }
    
    [self.tableView reloadData];
}

- (void)reloadContactListAfterImport:(NSNotification *)notification
{
    _contacts = [CTLCDPerson findAll];
    [self loadAllContacts];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"display_sort_tooltip_once"]){
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(displaySortTooltip:) userInfo:nil repeats:NO];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"display_sort_tooltip_once"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)reloadContactList:(NSNotification *)notification
{
    _contacts = nil;
    CFErrorRef error;
    self.addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
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

- (void)updateSortPickerButtonWithTitle:(NSString *)sortLabel
{
    CTLPickerButton *uiButton = (CTLPickerButton *)self.navigationItem.titleView;
    [uiButton updateTitle:sortLabel];
    self.navigationItem.titleView = uiButton;
}

- (void)buildSortPicker
{
    _sortPickerView = [[CTLPickerView alloc] initWithWidth:self.view.bounds.size.width];
    _sortPickerView.delegate = self;
    _sortPickerView.dataSource = self;
    [self.view addSubview:_sortPickerView];
    
    NSDictionary *activity   = @{@"title":NSLocalizedString(@"ACTIVITY", nil),   @"field":@"lastAccessed", @"asc": @(0)};
    NSDictionary *first_name = @{@"title":NSLocalizedString(@"FIRST_NAME", nil), @"field":@"firstName", @"asc": @(1)};
    NSDictionary *last_name  = @{@"title":NSLocalizedString(@"LAST_NAME", nil),  @"field":@"lastName", @"asc": @(1)};
    
    NSInteger selectedRow = [self savedSortOrderIndex];
    
    _sortArray = @[activity, first_name, last_name];
    [_sortPickerView selectRow:selectedRow inComponent:0 animated:NO];
    
    CTLPickerButton *filterButton = [[CTLPickerButton alloc] initWithTitle:NSLocalizedString(@"CLIENTS", nil)];
    [filterButton addTarget:self action:@selector(toggleSortPicker:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = filterButton;
}

- (void)toggleSortPicker:(id)sender
{
    if(_inContactMode){
        [self exitContactMode];
    }
    
    if(_sortPickerView.isVisible){
        [self hideSortPicker];
    }else{
        [self showSortPicker];
    }
}

- (void)hideSortPicker
{
    [_sortPickerView hidePicker];
    [self rightTitlebarWithAddContactButton];
    [self updateSortPickerButtonWithTitle:NSLocalizedString(@"CLIENTS", nil)];
    
    NSInteger selectedRow = [_sortPickerView selectedRowInComponent:0];
    NSInteger savedSelectedRow = [[NSUserDefaults standardUserDefaults] integerForKey:CTLSortOrderSelectedIndex];
    
    if(selectedRow != savedSelectedRow){
        [_sortPickerView selectRow:savedSelectedRow inComponent:0 animated:NO];
    }
}

- (void)showSortPicker
{
    [self removeSortTooltip];
    [_sortPickerView showPicker];
    [self rightTitlebarWithDoneButton];
    [self updateSortPickerButtonWithTitle:NSLocalizedString(@"SORT_BY", nil)];
}

- (void)rightTitlebarWithEditContactButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"40-forward"] style:UIBarButtonItemStyleDone target:self action:@selector(editContact:)];
    
    //[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
    
    //[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"14-gear"] style:UIBarButtonItemStyleDone target:self action:@selector(editContact:)];
}

- (void)rightTitlebarWithAddContactButton
{
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:@selector(displayAddContactActionSheet:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(displayAddContactActionSheet:)];
}

- (void)rightTitlebarWithDoneButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort"] style:UIBarButtonItemStyleDone target:self action:@selector(selectSortFilter:)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)selectSortFilter:(id)sender
{
    NSInteger selectedFilterRow = [_sortPickerView selectedRowInComponent:0];
    [self updateSortPickerButtonWithTitle:_sortArray[selectedFilterRow][@"title"]];
    [self loadAllContacts];
    [self saveSortOrder:selectedFilterRow];
    [self hideSortPicker];
}


- (IBAction)dismissSortPickerFromTap:(UITapGestureRecognizer *)recognizer
{
    [self hideSortPicker];
}

- (CTLABGroup *)selectedGroup
{
    NSInteger selectedRow = [_sortPickerView selectedRowInComponent:0];
    CTLABGroup *selectedGroup = [_sortArray objectAtIndex:selectedRow];
    return selectedGroup;
}

#pragma mark - Group Picker Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _sortArray[row][@"title"];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [_sortArray count];
}

#pragma mark - Titlebar Helper

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
    NSString *contactName = [NSString stringWithFormat:NSLocalizedString(@"FORWARD_CONTACT", nil), _selectedPerson.firstName];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:contactName
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"SEND_VIA_SMS", nil), NSLocalizedString(@"SEND_VIA_EMAIL", nil), nil];
    
    actionSheet.tag = CTLShareContactActionSheetTag;
    [actionSheet showInView:self.view];
}

#pragma mark - Prompt Delegate Methods

- (void)displayAddGroupPrompt:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CREATE_NEW_GROUP", nil)
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"CREATE", nil), nil];
    
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = NSLocalizedString(@"ENTER_GROUP_NAME", nil);
    textField.clearButtonMode = YES;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
    
    [alertView show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
     switch(actionSheet.tag){
        case CTLAddContactActionSheetTag:
            switch(buttonIndex){
                case 0:
                    _selectedPerson = nil;
                    [self performSegueWithIdentifier:CTLContactFormSegueIdentifyer sender:self];
                    break;
                case 1:
                    //if group selector is set to "all contacts" the import button is hidden because it doesnt make sense
                    [self performSegueWithIdentifier:CTLImporterSegueIdentifyer sender:self];
                    break;
            }
            break;
        case CTLShareContactActionSheetTag:
            switch(buttonIndex){
                case 0:
                    [self shareContactViaSMS:self];
                    break;
                case 1:
                    [self shareContactViaEmail:self];
                    break;
                case 2:
                    [self.contactHeader reset];
                    break;
            }
            break;
            
    }
}

#pragma mark - Segue Actions

- (void)editContact:(id)sender
{
    [self performSegueWithIdentifier:CTLContactFormSegueIdentifyer sender:self];
}

- (void)showImporter:(id)sender
{
    if(!self.addressBookRef){
        [self displayPermissionPrompt];
    }else{
        [self hideSortPicker];
        [self performSegueWithIdentifier:CTLImporterSegueIdentifyer sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:CTLImporterSegueIdentifyer]){
        CTLContactImportViewController *importer = [segue destinationViewController];
        [importer setAddressBookRef:self.addressBookRef];
        return;
    }
    
    if ([[segue identifier] isEqualToString:CTLContactFormSegueIdentifyer]) {
        CTLContactViewController *contactFormViewController = [segue destinationViewController];
        [contactFormViewController setAddressBookRef:self.addressBookRef];
        if(_selectedPerson){
            [contactFormViewController setContact:_selectedPerson];
        }
        return;
    }
    
    if([[segue identifier] isEqualToString:CTLAppointmentSegueIdentifyer]){
        UINavigationController *navigationController = [segue destinationViewController];
        CTLAppointmentFormViewController *appointmentViewController = (CTLAppointmentFormViewController *)navigationController.topViewController;
        [appointmentViewController setPresentedAsModal:YES];
        [appointmentViewController setContact:_selectedPerson];
        return;
    }
}


#pragma mark - Contact View

- (void)prepareContactViewMode
{
    CGSize viewSize = self.view.bounds.size;
    CGFloat shadowOffset = 5.0f;
    
    CGRect headerFrame = CGRectMake(0, -CTLContactViewHeaderHeight - shadowOffset, viewSize.width, CTLContactViewHeaderHeight);
    self.contactHeader = [[CTLContactHeaderView alloc] initWithFrame:headerFrame];
    [self.contactHeader.editButton addTarget:self action:@selector(editContact:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect toolbarFrame = CGRectMake(0, viewSize.height + CTLContactModeToolbarViewHeight + shadowOffset, viewSize.width, CTLContactModeToolbarViewHeight);
    self.contactToolbar = [[CTLContactToolbarView alloc] initWithFrame:toolbarFrame];
    [self.contactToolbar.appointmentButton addTarget:self action:@selector(showAppointmentScheduler:) forControlEvents:UIControlEventTouchUpInside];
    [self.contactToolbar.emailButton addTarget:self action:@selector(showEmailForPerson:) forControlEvents:UIControlEventTouchUpInside];
    [self.contactToolbar.callButton addTarget:self action:@selector(showDialPerson:) forControlEvents:UIControlEventTouchUpInside];
    [self.contactToolbar.smsButton addTarget:self action:@selector(showSMSForPerson:) forControlEvents:UIControlEventTouchUpInside];
    
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
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0f]];
    [titleLabel setTextColor:textColor];
    [titleLabel setText:NSLocalizedString(@"NO_CLIENTS", nil)];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120.0f, viewFrame.size.width, 25.0f)];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    [messageLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
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
    
    UIFont *buttonFont = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
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

- (void)enterContactMode
{
    [self rightTitlebarWithEditContactButton];
    [self.contactHeader populateViewData:_selectedPerson];
    
    if(_inContactMode){
        return;
    }
    
    _inContactMode = true;
    
    CGRect headerFrame = self.contactHeader.frame;
    CGRect toolbarFrame = self.contactToolbar.frame;
     
    headerFrame.origin.y = 0;
    toolbarFrame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(toolbarFrame) + 5;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.contactHeader.frame = headerFrame;
        self.contactToolbar.frame = toolbarFrame;
    }];
}

- (void)exitContactMode:(NSNotification *)notification
{
    [self exitContactMode];
}

- (void)exitContactMode
{
    [self rightTitlebarWithAddContactButton];
    [self.tableView deselectRowAtIndexPath:_selectedIndexPath animated:YES];
    CTLContactCell *cell = (CTLContactCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
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
        _inContactMode = NO;
        _selectedPerson = nil;
        _selectedIndexPath = nil;
        if(_shouldReorderListOnScroll){
            [self loadAllContacts];
            _shouldReorderListOnScroll = NO;
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    if(_inContactMode){
        [self rightTitlebarWithAddContactButton];
        [self exitContactMode];
    }
    
    if(_sortPickerView.isVisible){
        [self hideSortPicker];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
    UIView *touchedView = [self.view hitTest:touchPoint withEvent:nil];
    return (touchedView == self.tableView || touchedView == _emptyView);
}


#pragma mark - TableViewController Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63.0;
}

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
    CTLContactCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[CTLContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    CTLCDPerson *person = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        person = [_filteredContacts objectAtIndex:indexPath.row];
    }else{
        person = [_contacts objectAtIndex:indexPath.row];
    }
     
    cell.nameLabel.text = [self generatePersonName:person];
    cell.detailsLabel.text = [self generateContactString:person];
        
    if(person.lastAccessed){
        cell.timestampLabel.text = [self generateDateStamp:person.lastAccessed];
    }
    
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
        CTLCDPerson *person = [_contacts objectAtIndex:indexPath.row];
        [self deleteContact:person];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([_contacts count] == 0){
        return self.view.bounds.size.height;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([_contacts count] == 0){
        return _emptyView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if groupPicker is open dismiss it and do nothing else.
    if(_sortPickerView.isVisible){
        [self hideSortPicker];
        return;
    }
    
    //if there is a previously selected cell, clear that indicator
    if(_selectedIndexPath != nil){
        CTLContactCell *selectedCell = (CTLContactCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
        [selectedCell.indicatorLayer removeFromSuperlayer];
    }
    
    //mark selected cell with indicator
    CTLContactCell *cell = (CTLContactCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setIndicator];
    
    if(tableView == self.searchDisplayController.searchResultsTableView){
        _selectedPerson = [_filteredContacts objectAtIndex:indexPath.row];
        [self.searchDisplayController setActive:NO animated:YES];
    }else{
        _selectedPerson = [_contacts objectAtIndex:indexPath.row];
    }

    _selectedIndexPath = indexPath;
    [self enterContactMode];
}

- (void)deleteContact:(CTLCDPerson *)contact
{
    [contact MR_deleteEntity];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    [self loadAllContacts];
}

- (NSString *)generateContactString:(CTLCDPerson *)person
{
    NSString *contactStr = @"";
    
    if([[person phone] length] > 0){
        contactStr = person.phone;
    }else if([[person email] length] > 0){
        contactStr = person.email;
    }
    return contactStr;
}

- (NSString *)generatePersonName:(CTLCDPerson *)person
{
    NSString *compositeName = @"";
    
    if([_sortPickerView selectedRowInComponent:0] == 2){
        if([person.lastName length] > 0){
            compositeName = [compositeName stringByAppendingString:person.lastName];
        }
        
        if([person.firstName length] > 0){
            if([person.lastName length] > 0){
                compositeName = [compositeName stringByAppendingFormat:@", %@", person.firstName];
            }else{
                compositeName = [compositeName stringByAppendingFormat:@" %@", person.firstName];
            }
        }
    }else{
        if([person.firstName length] > 0){
            compositeName = [compositeName stringByAppendingString:person.firstName];
        }
        
        if([person.lastName length] > 0){
            compositeName = [compositeName stringByAppendingFormat:@" %@", person.lastName];
        }
    }
    
    return compositeName;
}

#pragma mark - Toolbar Actions

- (void)showAppointmentScheduler:(id)sender
{
    [self performSegueWithIdentifier:CTLAppointmentSegueIdentifyer sender:sender];
}

- (void)showDialPerson:(id)sender
{
    NSString *cleanPhoneNumber = [NSString cleanPhoneNumber:[_selectedPerson phone]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", cleanPhoneNumber]]];
    [self updateContactTimestampInPlace];
}

- (void)showEmailForPerson:(id)sender
{
    if(![MFMailComposeViewController canSendMail]){
        [self displayAlertMessage: NSLocalizedString(@"DEVICE_NOT_CONFIGURED_TO_SEND_EMAIL", nil)];
        return;
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setMailComposeDelegate:self];
    [mailController setToRecipients:@[[_selectedPerson email]]];
    [self presentViewController:mailController animated:YES completion:nil];
}

- (void)showSMSForPerson:(id)sender
{
    NSString *cleanNumber = [NSString cleanPhoneNumber:[_selectedPerson phone]];
    NSString *phoneToCall = [NSString stringWithFormat:@"sms: %@", cleanNumber];
    NSString *phoneToCallEncoded = [phoneToCall stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURL *smsURL = [[NSURL alloc] initWithString:phoneToCallEncoded];
    [[UIApplication sharedApplication] openURL:smsURL];
    [self updateContactTimestampInPlace];
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

- (void)updateContactTimestampInPlace
{
    [self saveTimestampForContact];
    [self updateTimestampForActiveCell];
}

- (void)updateTimestampForActiveCell
{
    CTLContactCell *cell = (CTLContactCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
    cell.timestampLabel.text = [NSDate formatShortTimeOnly:[NSDate date]];
    _shouldReorderListOnScroll = YES;
}

- (void)saveTimestampForContact
{
    _selectedPerson.lastAccessed = [NSDate date];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

- (void)timestampForRowDidChange:(NSNotification *)notification
{
    [self updateContactTimestampInPlace];
}

#pragma mark - UISearchDisplayController Delegate Methods

/*
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"SEARCH %@", searchText);
    [self filterContactListForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[searchBar scopeButtonTitles] objectAtIndex:0]];
}*/

- (void)filterContactListForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[_filteredContacts removeAllObjects];
    
	for (NSInteger i=0;i<[_contacts count]; i++){
        CTLCDPerson *person = _contacts[i];
        //TODO: composite name
        NSComparisonResult result = [person.firstName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        if (result == NSOrderedSame){
            [_filteredContacts addObject:person];
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
    [self filterContactListForSearchText:[self.searchDisplayController.searchBar text] scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
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
    NSString *body = [NSString stringWithFormat:NSLocalizedString(@"SHARE_CONTACT_MSG", nil), _selectedPerson.firstName];
    
    if([_selectedPerson.phone length] > 0){
        body = [body stringByAppendingFormat:NSLocalizedString(@"PHONE_COLON", nil), _selectedPerson.phone];
        if([_selectedPerson.email length] > 0){
            body = [body stringByAppendingString:@", "];
        }
    }
    
    if([_selectedPerson.email length] > 0){
        body = [body stringByAppendingFormat:NSLocalizedString(@"EMAIL_COLON", nil), _selectedPerson.email];
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
    if([notification.object isKindOfClass:[CTLCDPerson class]]){
        _selectedPerson = notification.object;
        _shouldReorderListOnScroll = YES;
        [self loadAllContacts];
        [self enterContactMode];
    }
}

- (void)contactRowDidChange:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[CTLCDPerson class]]){
        _selectedPerson = notification.object;
        _shouldReorderListOnScroll = YES;
        [self loadAllContacts];
        [self.contactHeader populateViewData:_selectedPerson];
    }
}

#pragma mark - Message Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if(result == MFMailComposeResultSent){
        [self updateContactTimestampInPlace];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if(result == MessageComposeResultSent){
        [self updateContactTimestampInPlace];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)registerNotificationsObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayShareContactActionSheet:) name:CTLShareContactNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContactListAfterImport:) name:CTLContactsWereImportedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContactList:) name:CTLContactListReloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timestampForRowDidChange:) name:CTLTimestampForRowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newContactWasAdded:) name:CTLNewContactWasAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactRowDidChange:) name:CTLContactRowDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTLShareContactNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTLContactsWereImportedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTLContactListReloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTLTimestampForRowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTLNewContactWasAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTLContactRowDidChangeNotification object:nil];
}

@end
