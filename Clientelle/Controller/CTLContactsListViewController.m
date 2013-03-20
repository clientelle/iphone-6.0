//
//  CTLContactListController.m
//  Clientelle
//
//  Created by Samuel Goodwin on 3/17/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "NSString+CTLString.h"
#import "NSDate+CTLDate.h"

#import "CTLSlideMenuController.h"
#import "CTLGroupsListViewController.h"
#import "CTLContactsListViewController.h"

#import "CTLContactViewController.h"
#import "CTLContactImportViewController.h"
#import "CTLGroupsListViewController.h"
#import "CTLAddEventViewController.h"

#import "CTLContactCell.h"
#import "CTLContactHeaderView.h"
#import "CTLContactToolbarView.h"

#import "CTLABGroup.h"
#import "CTLABPerson.h"
#import "CTLCDPerson.h"
#import "CTLCDFormSchema.h"

#import "CTLPickerView.h"
#import "CTLPickerButton.h"

NSString *const CTLContactWereImportedNotification = @"com.clientelle.notifications.contactsWereImported";
NSString *const CTLContactListReloadNotification = @"com.clientelle.notifications.reloadContacts";
NSString *const CTLTimestampForRowNotification = @"com.clientelle.notifications.updateContactTimestamp";
NSString *const CTLNewContactWasAddedNotification = @"com.clientelle.com.notifications.contactWasAdded";
NSString *const CTLContactRowDidChangeNotification = @"com.clientelle.com.notifications.contactRowDidChange";

NSString *const CTLImporterSegueIdentifyer = @"toImporter";
NSString *const CTLContactListSegueIdentifyer = @"toContacts";
NSString *const CTLContactFormSegueIdentifyer = @"toContactForm";
NSString *const CTLGroupListSegueIdentifyer = @"toGroupList";
NSString *const CTLAppointmentSegueIdentifyer = @"toSetAppointment";

int const CTLAllContactsGroupID = 0;
int const CTLShareContactActionSheetTag = 234;
int const CTLAddContactActionSheetTag = 424;
int const CTLEmptyContactsTitleTag = 792;

@implementation CTLContactsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _inContactMode = NO;
    _shouldReorderListOnScroll = NO;
    
    [self rightTitlebarWithAddContactButton];
    
    _addressBookRef = [self.menuController addressBookRef];
    int defaultGroupID = [CTLABGroup defaultGroupID];
    
    [self buildGroupSelector:defaultGroupID];
    
    _contacts = [NSArray array];
    _filteredContacts = [NSMutableArray array];
    
    if(defaultGroupID == CTLAllContactsGroupID){
        self.navigationItem.titleView = [self groupPickerButtonWithTitle: NSLocalizedString(@"ALL_CONTACTS", nil)];
        [self loadAllContacts];
    }else{
        CTLABGroup *selectedGroup = [[CTLABGroup alloc] initWithGroupID:defaultGroupID addressBook:self.addressBookRef];
        self.navigationItem.titleView = [self groupPickerButtonWithTitle:[selectedGroup name]];
        [self loadGroup:selectedGroup];
    }
    
    [self prepareContactViewMode];
    
    _emptyView = [self noContactsView];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper.png"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContactListAfterImport:) name:CTLContactWereImportedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContactList:) name:CTLContactListReloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timestampForRowDidChange:) name:CTLTimestampForRowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newContactWasAdded:) name:CTLNewContactWasAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactRowDidChange:) name:CTLContactRowDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayShareContactActionSheet:) name:CTLShareContactNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookDidChange:) name:kAddressBookDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidGoInactive:) name:kApplicationDidGoInactive object:nil];
}

- (void)applicationDidGoInactive:(NSNotification *)notification{
    [self exitContactMode];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddressBookDidChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTLShareContactNotification object:nil];
}

#pragma mark - Loading Contact List

- (void)loadAllContacts
{
    [CTLABPerson peopleFromAddressBook:self.addressBookRef withBlock:^(NSDictionary *results){
        _contactsDictionary = [results mutableCopy];
    }];
    
    [self setContactList];
}

- (void)addressBookDidChange:(NSNotification *)notification
{
    CFErrorRef error = NULL;
    self.addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    CTLABGroup *selectedGroup = [[CTLABGroup alloc] initWithGroupID:[CTLABGroup defaultGroupID] addressBook:self.addressBookRef];
    [self loadGroup:selectedGroup];
     
    if(_inContactMode){
        _selectedPerson = [[CTLABPerson alloc] initWithRecordID:_selectedPerson.recordID withAddressBookRef:self.addressBookRef];
        [self.contactHeader populateViewData:_selectedPerson];
        [self determineToolbarAbilities];
    }
}

- (void)loadGroup:(CTLABGroup *)group
{
    _contactsDictionary = group.members;
    [self setContactList];
}

- (void)reloadContactListAfterImport:(NSNotification *)notification
{
    NSMutableDictionary *importedContacts = [notification object];
    if([importedContacts count] > 0 ){
        for(NSNumber *recordID in importedContacts){
            [_accessedDictionary setObject:[NSDate date] forKey:recordID];
            [_contactsDictionary setObject:[importedContacts objectForKey:recordID] forKey:recordID];
        }
    }
    
    [self handleUIRestrictions];
    [self sortContactListByAccessDate:[_contactsDictionary allValues]];
}

- (void)reloadContactList:(NSNotification *)notification
{
    CFErrorRef error;
    self.addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    CTLABGroup *selectedGroup = [[CTLABGroup alloc] initWithGroupID:[CTLABGroup defaultGroupID] addressBook:self.addressBookRef];
    
    _accessedDictionary = nil;
    _contactsDictionary = nil;
    _contacts = nil;
    
    if([selectedGroup.members count] == 0){
        [self.tableView reloadData];
    }else{
        _contactsDictionary = selectedGroup.members;
        [self setContactList];
    }
}

- (void)handleUIRestrictions
{
    if([_contactsDictionary count] == 0){
        self.searchBar.hidden = YES;
        self.tableView.scrollEnabled = NO;
    }else{
        self.searchBar.hidden = NO;
        self.tableView.scrollEnabled = YES;
    }
}

- (void)setContactList
{
    [self handleUIRestrictions];
    
    //map saved contacts to address book contacts and float most recent to the top
    if(!_accessedDictionary){
        NSArray *storedContacts = [CTLCDPerson MR_findAll];
        _accessedDictionary = [[NSMutableDictionary alloc] initWithCapacity:[storedContacts count]];
        for(NSInteger i=0;i<[storedContacts count];i++){
            CTLCDPerson *contact = [storedContacts objectAtIndex:i];
            if(contact.lastAccessed){
                [_accessedDictionary setObject:contact.lastAccessed forKey:@([contact recordIDValue])];
            }
        }
    }
    
    NSMutableArray *members = [[NSMutableArray alloc] initWithCapacity:[_contactsDictionary count]];
    for(NSNumber *recordID in _contactsDictionary){
        CTLABPerson *abPerson = [_contactsDictionary objectForKey:recordID];
        NSDate *lastAccessed = [_accessedDictionary objectForKey:@([abPerson recordID])];
        if(lastAccessed){
            [abPerson setAccessDate: lastAccessed];
        }
        [members addObject:abPerson];
    }
    
    [self sortContactListByAccessDate:members];
}

- (void)sortContactListByAccessDate:(NSArray *)contacts
{
    NSSortDescriptor *sortByAccessDate = [NSSortDescriptor sortDescriptorWithKey:@"accessDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByAccessDate];
    NSArray *sortedContacts = [contacts sortedArrayUsingDescriptors:sortDescriptors];
    
    _contacts = [[NSMutableArray alloc] initWithArray:sortedContacts];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView setContentOffset:CGPointMake(0.0f, CGRectGetHeight(self.searchDisplayController.searchBar.bounds))];
    });
}

#pragma mark - Group Picker

- (UIButton *)groupPickerButtonWithTitle:(NSString *)selectedGroupName
{
    CTLPickerButton *uiButton = [[CTLPickerButton alloc] initWithTitle:selectedGroupName];
    [uiButton addTarget:self action:@selector(togglePicker:) forControlEvents:UIControlEventTouchUpInside];
    return uiButton;
}

- (void)updateGroupPickerButtonWithTitle:(NSString *)groupName
{
    CTLPickerButton *uiButton = (CTLPickerButton *)self.navigationItem.titleView;
    [uiButton updateTitle:groupName];
    self.navigationItem.titleView = uiButton;
}

- (void)buildGroupSelector:(int)defaultGroupID
{
    _groupPickerView = [self createGroupPickerView];
    
    CTLABGroup *allContacts = [[CTLABGroup alloc] init];
    allContacts.name = NSLocalizedString(@"ALL_CONTACTS", nil);
    allContacts.groupID = CTLAllContactsGroupID;
    
    _groupArray = [[NSMutableArray alloc] initWithObjects:allContacts, nil];
    [_groupArray addObjectsFromArray:[CTLABGroup groupsInLocalSource:self.addressBookRef]];
    
    for(NSInteger i=0;i<[_groupArray count]; i++){
        CTLABGroup *group = [_groupArray objectAtIndex:i];
        if(group.groupID == defaultGroupID){
            [_groupPickerView selectRow:i inComponent:0 animated:NO];
            break;
        }
    }
}

- (CTLPickerView *)createGroupPickerView
{
    CTLPickerView *groupPicker = [[CTLPickerView alloc] initWithWidth:self.view.bounds.size.width];
    groupPicker.delegate = self;
    groupPicker.dataSource = self;
    [self.view addSubview:groupPicker];
    return groupPicker;
}

- (void)togglePicker:(id)sender {
    
    if(_inContactMode){
        [self exitContactMode];
    }
    
    if(_groupPickerView.isVisible){
        [self hideGroupPicker];
    }else{
        [self showGroupPicker];
    }
}

- (void)hideGroupPicker
{
    [_groupPickerView hidePicker];
    [self rightTitlebarWithAddContactButton];
}

- (void)showGroupPicker
{
    [_groupPickerView showPicker];
    [self rightTitlebarWithGroupViewButton];
}

- (IBAction)dismissGroupPickerFromTap:(UITapGestureRecognizer *)recognizer
{
    [self hideGroupPicker];
}

- (CTLABGroup *)selectedGroup
{
    NSInteger selectedRow = [_groupPickerView selectedRowInComponent:0];
    CTLABGroup *selectedGroup = [_groupArray objectAtIndex:selectedRow];
    return selectedGroup;
}

#pragma mark - Group Picker Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    CTLABGroup *abGroup = [_groupArray objectAtIndex:[_groupPickerView selectedRowInComponent:0]];
    [self updateGroupPickerButtonWithTitle:abGroup.name];
    
    if(abGroup.groupID == 0){
        [self loadAllContacts];
    }else{
        [self loadGroup:abGroup];
    }

    [CTLABGroup saveDefaultGroupID:abGroup.groupID];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	CTLABGroup *group = [_groupArray objectAtIndex:row];
    return group.name;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [_groupArray count];
}

#pragma mark - Titlebar Helper

- (void)rightTitlebarWithAddContactButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displayAddContactActionSheet:)];
}

- (void)rightTitlebarWithGroupViewButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displayAddGroupPrompt:)];
}

- (void)displayAddContactActionSheet:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ADD_NEW_CONTACT", nil)
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"NEW_CONTACT", nil), nil];
    actionSheet.tag = CTLAddContactActionSheetTag;
    
    if([self.selectedGroup groupID] != CTLAllContactsGroupID){
        [actionSheet addButtonWithTitle:NSLocalizedString(@"IMPORT_CONTACTS", nil)];
        actionSheet.cancelButtonIndex = 2;
    }else{
        actionSheet.cancelButtonIndex = 1;
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
    [actionSheet showInView:self.view];
}


- (void)displayShareContactActionSheet:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"FORWARD_CONTACT", nil), [_selectedPerson compositeName]] delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SEND_VIA_SMS", nil), NSLocalizedString(@"SEND_VIA_EMAIL", nil), nil];
    
    actionSheet.tag = CTLShareContactActionSheetTag;
    [actionSheet showInView:self.view];
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
                    if([self.selectedGroup groupID] != CTLAllContactsGroupID){
                        [self performSegueWithIdentifier:CTLImporterSegueIdentifyer sender:self];
                    }
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

- (IBAction)displayAddGroupPrompt:(id)sender
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *newGroupName = [[alertView textFieldAtIndex:0] text];
    if([newGroupName length] == 0){
        return ;
    }

    ABRecordRef  existingGroupRef = [CTLABGroup findByName:newGroupName addressBookRef:self.addressBookRef];
    if(existingGroupRef){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"GROUP_EXISTS", nil), newGroupName]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    ABRecordID groupID = [CTLABGroup createGroup:newGroupName addressBookRef:self.addressBookRef];
    if(groupID != kABRecordInvalidID){
        CTLCDFormSchema *formSchema = [CTLCDFormSchema MR_createEntity];
        formSchema.groupIDValue = groupID;
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        
        [CTLABGroup saveDefaultGroupID:groupID];
        
        CTLABGroup *newGroup = [[CTLABGroup alloc] initWithGroupID:groupID addressBook:self.addressBookRef];
        [_groupArray addObject:newGroup];
        [_groupPickerView reloadAllComponents];
        
        NSInteger selectedIndex = [_groupArray count] - 1;
        [_groupPickerView selectRow:selectedIndex inComponent:0 animated:YES];
        [self loadGroup:newGroup];
        [self updateGroupPickerButtonWithTitle:newGroupName];
        [self hideGroupPicker];
    }
}


#pragma mark - Segue Actions

- (void)editContact:(id)sender
{
    [self performSegueWithIdentifier:CTLContactFormSegueIdentifyer sender:self];
}

- (IBAction)showImporter:(id)sender
{
    [self hideGroupPicker];
    [self performSegueWithIdentifier:CTLImporterSegueIdentifyer sender:self];
}

- (void)showGroupList:(id)sender
{
    [self hideGroupPicker];
    [self performSegueWithIdentifier:CTLGroupListSegueIdentifyer sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:CTLImporterSegueIdentifyer]){
        CTLContactImportViewController *importer = [segue destinationViewController];
        [importer setAddressBookRef:self.addressBookRef];
        [importer setSelectedGroup:self.selectedGroup];
        return;
    }
    
    if ([[segue identifier] isEqualToString:CTLContactFormSegueIdentifyer]) {
        CTLContactViewController *contactFormViewController = [segue destinationViewController];
        [contactFormViewController setAddressBookRef:self.addressBookRef];
        [contactFormViewController setAbGroup:self.selectedGroup];
        if(_selectedPerson){
            [contactFormViewController setAbPerson:_selectedPerson];
        }
        return;
    }
    
    if([[segue identifier] isEqualToString:CTLAppointmentSegueIdentifyer]){
        UINavigationController *navigationController = [segue destinationViewController];
        CTLAddEventViewController *appointmentViewController = (CTLAddEventViewController *)navigationController.topViewController;
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
    [self.contactToolbar.mapButton addTarget:self action:@selector(showMapForPerson:) forControlEvents:UIControlEventTouchUpInside];
    
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
    [titleLabel setText:[self.selectedGroup name]];
    titleLabel.tag = CTLEmptyContactsTitleTag;
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120.0f, viewFrame.size.width, 25.0f)];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    [messageLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    [messageLabel setTextColor:textColor];
    [messageLabel setText:NSLocalizedString(@"EMPTY_GROUP", nil)];
    
    CGFloat buttonCenter = viewFrame.size.width/2 - 63;
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"whiteButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // Set the background for any states you plan to use
    [addButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor colorFromUnNormalizedRGB:81.0f green:91.0f blue:130.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [addButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [addButton setTitleColor:[UIColor colorFromUnNormalizedRGB:61.0f green:71.0f blue:110.0f alpha:1.0f] forState:UIControlStateHighlighted];
    
    
    [addButton setFrame:CGRectMake(buttonCenter, 175.0f, 126.0f, 38.0f)];
    [addButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0f]];
    [addButton addTarget:self action:@selector(showImporter:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTitle:NSLocalizedString(@"ADD_CONTACTS", nil) forState:UIControlStateNormal];
    
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
    [self.contactHeader populateViewData:_selectedPerson];
    [self determineToolbarAbilities];
    
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
        //[self.view setBackgroundColor:[UIColor ctlMediumGray]];
    }];
}

- (void)exitContactMode
{
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
            [self sortContactListByAccessDate:_contacts];
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
    
    if(_groupPickerView.isVisible){
        [self hideGroupPicker];
    }
}

- (void)determineToolbarAbilities
{
    //Disable buttons if user does not have contact info
    self.contactToolbar.emailButton.enabled = ([[_selectedPerson email] length] > 0);
    
    if([[_selectedPerson phone] length] > 0){
        self.contactToolbar.callButton.enabled = YES;
        self.contactToolbar.smsButton.enabled = YES;
    }else{
        self.contactToolbar.callButton.enabled = NO;
        self.contactToolbar.smsButton.enabled = NO;
    }
    
    if([_selectedPerson.addressDict count] > 0){
        self.contactToolbar.mapButton.enabled = YES;
    }else{
        self.contactToolbar.mapButton.enabled = NO;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
    UIView *touchedView = [self.view hitTest:touchPoint withEvent:nil];
    return (touchedView == self.tableView || touchedView == _emptyView);
}


#pragma mark - TableViewController Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return [_filteredContacts count];
    }
    
    return [_contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"contactRow";
    CTLContactCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[CTLContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    CTLABPerson *person = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        person = [_filteredContacts objectAtIndex:indexPath.row];
    }else{
        person = [_contacts objectAtIndex:indexPath.row];
    }
     
    [self configureCell:cell person:person];
    
    return cell;
}

- (void)configureCell:(CTLContactCell *)cell person:(CTLABPerson *)person
{
    cell.nameLabel.text = [person compositeName];
    
    if([[person phone] length] > 0){
        cell.detailsLabel.text = person.phone;
    }else if([[person email] length] > 0){
        cell.detailsLabel.text = person.email;
    }else{
        cell.detailsLabel.text = @"";
    }
    
    NSDate *accessDate = [_accessedDictionary objectForKey:@(person.recordID)];
    if(accessDate){
        cell.timestampLabel.text = [NSString stringWithFormat:@"%@", [NSDate dateToString:accessDate]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([_contacts count] == 0){
        return self.view.bounds.size.height;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([_contacts count] == 0){
        UILabel *titleLabel = (UILabel*)[_emptyView viewWithTag:CTLEmptyContactsTitleTag];
        titleLabel.text = [self.selectedGroup name];
        return _emptyView;
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.selectedGroup groupID] == CTLAllContactsGroupID){
        return false;
    }
    //do not allow deleting row in "inContact" Mode
    return !_inContactMode;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        CTLABPerson *abPerson = [_contacts objectAtIndex:indexPath.row];
        [self.selectedGroup removeMember:abPerson.recordID];
        [_contacts removeObjectAtIndex:indexPath.row];
        [_accessedDictionary removeObjectForKey:@(abPerson.recordID)];
        [_contactsDictionary removeObjectForKey:@(abPerson.recordID)];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //if groupPicker is open dismiss it and do nothing else.
    if(_groupPickerView.isVisible){
        [self hideGroupPicker];
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

#pragma mark - Toolbar Actions

- (void)showAppointmentScheduler:(id)sender
{
    [self performSegueWithIdentifier:CTLAppointmentSegueIdentifyer sender:sender];
}

- (void)showMapForPerson:(id)sender
{
    NSArray *addressArray = [_selectedPerson.addressDict allValues];
    NSMutableArray *addyArray = [[NSMutableArray alloc] init];
    for(NSUInteger i=0;i<[addressArray count];i++){
        if([[addressArray objectAtIndex:i] length] > 0){
            [addyArray addObject:[addressArray objectAtIndex:i]];
        }
    }
    
    NSString *addressStr = [addyArray componentsJoinedByString:@", "];
    NSString *encodedAddress = [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *mapURLString = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@", encodedAddress];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapURLString]];
    [self updateContactTimestampInPlace];
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
- (void)updateContactTimestampInPlace
{
    [self saveTimestampForContact];
    [self updateTimestampForActiveCell];
}

- (void)updateTimestampForActiveCell
{
    CTLContactCell *cell = (CTLContactCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
    cell.timestampLabel.text = [NSDate dateToString:[NSDate date]];
    _shouldReorderListOnScroll = YES;
}

- (void)saveTimestampForContact
{
    NSNumber *recordIDKey = @(_selectedPerson.recordID);
        
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordID=%i", _selectedPerson.recordID];
    CTLCDPerson *person = [CTLCDPerson MR_findFirstWithPredicate:predicate];
    
    if(!person){
        person = [CTLCDPerson createFromABPerson:_selectedPerson];
    }
    
    person.lastAccessed = [NSDate date];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    
    _selectedPerson.accessDate = person.lastAccessed;
    [_accessedDictionary setObject:person.lastAccessed forKey:recordIDKey];
    [_contactsDictionary setObject:_selectedPerson forKey:recordIDKey];
}

- (void)timestampForRowDidChange:(NSNotification *)notification
{
    [self updateContactTimestampInPlace];
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)filterContactListForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[_filteredContacts removeAllObjects];
	for (NSNumber *key in _contactsDictionary){
        CTLABPerson *person = [_contactsDictionary objectForKey:key];
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

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption{
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

- (void)shareContactViaEmail:(id)sender {
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
    if([notification.object isKindOfClass:[CTLABPerson class]]){
        _selectedPerson = notification.object;
        _shouldReorderListOnScroll = YES;
        [_contactsDictionary setObject:_selectedPerson forKey:@(_selectedPerson.recordID)];
        [_accessedDictionary setObject:[NSDate date] forKey:@(_selectedPerson.recordID)];
        _contacts = [[_contactsDictionary allValues] mutableCopy];
        [self enterContactMode];
        [self.tableView reloadData];
        [self handleUIRestrictions];
    }
}

- (void)contactRowDidChange:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[CTLABPerson class]]){
        _selectedPerson = notification.object;
        _shouldReorderListOnScroll = YES;
        [_contactsDictionary setObject:_selectedPerson forKey:@(_selectedPerson.recordID)];
        [_accessedDictionary setObject:[NSDate date] forKey:@(_selectedPerson.recordID)];
        _contacts = [[_contactsDictionary allValues] mutableCopy];
        [self.contactHeader populateViewData:_selectedPerson];
        CTLContactCell *cell = (CTLContactCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
        [cell.indicatorLayer removeFromSuperlayer];
        [self.tableView reloadData];
    }
}

#pragma mark - Message Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
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


@end
