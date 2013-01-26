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
#import "CTLProspectFormViewController.h"
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


NSString *const CTLContactListReloadNotification = @"com.clientelle.notifications.reloadContacts";

NSString *const CTLImporterSegueIdentifyer = @"toImporter";
NSString *const CTLContactListSegueIdentifyer = @"toContacts";
NSString *const CTLContactFormSegueIdentifyer = @"toContactForm";
NSString *const CTLProspectFormSegueIdentifyer = @"toProspectForm";
NSString *const CTLGroupListSegueIdentifyer = @"toGroupList";
NSString *const CTLAppointmentSegueIdentifyer = @"toSetAppointment";

int const CTLAllContactsGroupID = 0;
int const CTLShareContactActionSheetTag = 234;
int const CTLAddContactActionSheetTag = 424;

@implementation CTLContactsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self rightTitlebarWithAddContactButton];
    
    _addressBookRef = [self.menuController addressBookRef];
    int defaultGroupID = [CTLABGroup defaultGroupID];
    
    [self buildGroupSelector:defaultGroupID];
    
    if(defaultGroupID == CTLAllContactsGroupID){
        self.navigationItem.titleView = [self groupPickerButtonWithTitle: NSLocalizedString(@"ALL_CONTACTS", nil)];
        [self loadAllContacts];
    }else{
        CTLABGroup *selectedGroup = [[CTLABGroup alloc] initWithGroupID:defaultGroupID addressBook:self.addressBookRef];
        self.navigationItem.titleView = [self groupPickerButtonWithTitle:[selectedGroup name]];
        [self loadGroup:selectedGroup];
    }
    
    [self prepareContactViewMode];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContactList:) name:CTLContactListReloadNotification object:nil];
    
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

#pragma mark - Loading Contact List

- (void)loadAllContacts
{
    [CTLABPerson peopleFromAddressBook:self.addressBookRef withBlock:^(NSDictionary *results){
        _contactsDictionary = [results mutableCopy];
    }];
    
    [self setContactList];
}

- (void)loadGroup:(CTLABGroup *)group
{
    _contactsDictionary = group.members;
    [self setContactList];
}

- (void)reloadContactList:(NSNotification *)notification
{
    NSMutableDictionary *importedContacts = [notification object];
    if([importedContacts count] > 0 ){
        for(NSNumber *recordID in importedContacts){
            [_accessedDictionary setObject:[NSDate date] forKey:recordID];
            [_contactsDictionary setObject:[importedContacts objectForKey:recordID] forKey:recordID];
        }
    }

    [self sortContactListByAccessDate:[_contactsDictionary allValues]];
}

- (void)setContactList
{
    //map saved contacts to address book contacts and float most recent to the top
    if(!_accessedDictionary){
        NSArray *storedContacts = [CTLCDPerson MR_findAll];
        _accessedDictionary = [[NSMutableDictionary alloc] initWithCapacity:[storedContacts count]];
        for(NSInteger i=0;i<[storedContacts count];i++){
            CTLCDPerson *contact = [storedContacts objectAtIndex:i];
            [_accessedDictionary setObject:contact.lastAccessed forKey:@([contact recordIDValue])];
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
    UIButton *uiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [uiButton setFrame:CGRectMake(0, 0, 210.0f, 40.0f)];
    [uiButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [uiButton setTitle:selectedGroupName forState:UIControlStateNormal];
    [uiButton addTarget:self action:@selector(togglePicker:) forControlEvents:UIControlEventTouchUpInside];
    [uiButton setImage:[UIImage imageNamed:@"wht-arrow-dwn.png"] forState:UIControlStateNormal];
    CGSize titleSize = [[uiButton titleForState:UIControlStateNormal] sizeWithFont:uiButton.titleLabel.font];
    uiButton.imageEdgeInsets = UIEdgeInsetsMake(uiButton.imageView.frame.size.height, (titleSize.width + 20.0f), 0, -titleSize.width);
    return uiButton;
}

- (void)updateGroupPickerButtonWithTitle:(NSString *)groupName
{
    UIButton *uiButton = (UIButton *)self.navigationItem.titleView;
    [uiButton setTitle:groupName forState:UIControlStateNormal];
    CGSize titleSize = [[uiButton titleForState:UIControlStateNormal] sizeWithFont:uiButton.titleLabel.font];
    uiButton.imageEdgeInsets = UIEdgeInsetsMake(uiButton.imageView.frame.size.height, (titleSize.width + 20.0f), 0, -titleSize.width);
    self.navigationItem.titleView = uiButton;
}

- (UIPickerView *)createGroupPickerView
{
    //configure UIPickerView
    UIPickerView *groupPicker = [[UIPickerView alloc] init];
    groupPicker.delegate = self;
    groupPicker.dataSource = self;
    groupPicker.showsSelectionIndicator = YES;
    
    CGRect groupPickerFrame = groupPicker.frame;
    groupPickerFrame.size.height = 162.0f;
    groupPickerFrame.origin.y = -169.0f;
    groupPicker.frame = groupPickerFrame;
    
    //add a drop shadow
    UIView *pickerFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, groupPicker.frame.size.height, groupPicker.frame.size.width, 7.0f)];
    pickerFooterView.backgroundColor = [UIColor colorFromUnNormalizedRGB:43.0f green:44.0f blue:57.0f alpha:1.0f];
    pickerFooterView.layer.shadowOpacity = 1.0f;
    pickerFooterView.layer.shadowRadius = 3.0f;
    pickerFooterView.layer.shadowOffset = CGSizeMake(0,0);
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, pickerFooterView.bounds.size.height-1.0f, pickerFooterView.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorFromUnNormalizedRGB:27.0f green:27.0f blue:27.0f alpha:1.0f].CGColor;
    [pickerFooterView.layer addSublayer:bottomBorder];
    [groupPicker addSubview:pickerFooterView];
    
    //force a group select if user taps twice
    [groupPicker addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGroupPicker:)]];
    return groupPicker;
}

- (void)togglePicker:(id)sender {
    if(_groupPickerIsVisible){
        [self hideGroupPicker:nil];
    }else{
        [self showGroupPicker];
    }
}

- (void)showGroupPicker
{
    if(_inContactMode){
        [self exitContactMode];
    }
    
    [self rightTitlebarWithGroupViewButton];
    
    [self.view addSubview:_groupPickerView];
    CGRect pickerFrame = _groupPickerView.frame;
    pickerFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        _groupPickerView.frame = pickerFrame;
    } completion:^(BOOL finished){
        _groupPickerIsVisible = YES;
    }];
}

- (void)hideGroupPicker:(id)sender {
    
    if(!_groupPickerIsVisible){
        return;
    }
    
    if(_inContactMode){
        [self rightTitlebarWithContactViewButton];
    }else{
        [self rightTitlebarWithAddContactButton];
    }
    
    CGRect pickerFrame = _groupPickerView.frame;
    pickerFrame.origin.y = -pickerFrame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        _groupPickerView.frame = pickerFrame;
    } completion:^(BOOL finished) {
        [_groupPickerView removeFromSuperview];
        _groupPickerIsVisible = NO;
    }];
}

- (IBAction)dismissGroupPickerFromTap:(UITapGestureRecognizer *)recognizer
{
    [self hideGroupPicker:nil];
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

- (void)rightTitlebarWithContactViewButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"31-paper-airplane.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displayShareContactActionSheet:)];
}

- (void)rightTitlebarWithGroupViewButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displayAddGroupPrompt:)];
}

- (void)displayAddContactActionSheet:(id)sender
{
    UIActionSheet *actionSheet = nil;
    if([self.selectedGroup groupID] == CTLAllContactsGroupID){
        //if Group selector is on "All Contacts" it makes no sense to import from address book since it already shows all contacts in address book.
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add a new Contact" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New Contact", @"Quick Lead", nil];
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add a new Contact or Group" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New Contact", @"Quick Lead", @"Import Contact", nil];
    }
    actionSheet.tag = CTLAddContactActionSheetTag;
    [actionSheet showInView:self.view];
}

- (void)displayShareContactActionSheet:(id)sender
{
    UIActionSheet *actionSheet = nil;
    NSString *title = [NSString stringWithFormat:@"Forward %@'s contact info", [_selectedPerson compositeName]];
    actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send via SMS", @"Send via Email", nil];
    
    actionSheet.tag = CTLShareContactActionSheetTag;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(actionSheet.tag){
        case CTLAddContactActionSheetTag:
            switch(buttonIndex){
                case 0:
                    [self performSegueWithIdentifier:CTLContactFormSegueIdentifyer sender:self];
                    break;
                case 1:
                    [self performSegueWithIdentifier:CTLProspectFormSegueIdentifyer sender:self];
                    break;
                case 2:
                    //if group selector is set to "all contacts" the import button is hidden
                    //because all the importer shows all contacts so you can import to itself.
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
        NSString *dupMessage = [NSString stringWithFormat:NSLocalizedString(@"GROUP_EXISTS", nil), newGroupName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:dupMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
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
        [self hideGroupPicker:alertView];
    }
}


#pragma mark - Segue Actions

- (void)editContact:(id)sender
{
    [self performSegueWithIdentifier:CTLContactFormSegueIdentifyer sender:self];
}

- (IBAction)showImporter:(id)sender
{
    [self hideGroupPicker:nil];
    [self performSegueWithIdentifier:CTLImporterSegueIdentifyer sender:self];
}

- (void)showGroupList:(id)sender
{
    [self hideGroupPicker:nil];
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
    
    //Add Contact Header
    self.contactHeader = [[CTLContactHeaderView alloc] initWithFrame:CGRectMake(0, -CTLContactViewHeaderHeight - shadowOffset, viewSize.width, CTLContactViewHeaderHeight)];
    
    [self.contactHeader.editButton addTarget:self action:@selector(editContact:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.contactHeader];
    
    //Configure Toolbar Actions
    
    self.contactToolbar = [[CTLContactToolbarView alloc] initWithFrame:CGRectMake(0, viewSize.height + CTLContactModeToolbarViewHeight + shadowOffset, viewSize.width, CTLContactModeToolbarViewHeight)];
    
    [self.contactToolbar.appointmentButton addTarget:self action:@selector(showAppointmentScheduler:) forControlEvents:UIControlEventTouchUpInside];
    [self.contactToolbar.emailButton addTarget:self action:@selector(showEmailForPerson:) forControlEvents:UIControlEventTouchUpInside];
    [self.contactToolbar.callButton addTarget:self action:@selector(showDialPerson:) forControlEvents:UIControlEventTouchUpInside];
    [self.contactToolbar.smsButton addTarget:self action:@selector(showSMSForPerson:) forControlEvents:UIControlEventTouchUpInside];
    [self.contactToolbar.mapButton addTarget:self action:@selector(showMapForPerson:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.contactToolbar];
}

- (void)enterContactMode{
    
    [self.contactHeader populateViewData:_selectedPerson];
    [self determineToolbarAbilities];
    
    if(_inContactMode){
        return;
    }
    
    _inContactMode = true;
    [self rightTitlebarWithContactViewButton];
    
    CGRect headerFrame = self.contactHeader.frame;
    CGRect toolbarFrame = self.contactToolbar.frame;
    
    headerFrame.origin.y = 0;
    toolbarFrame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(toolbarFrame) + 5;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.contactHeader.frame = headerFrame;
        self.contactToolbar.frame = toolbarFrame;
    }];
}

- (void)exitContactMode {
    
    [self.tableView deselectRowAtIndexPath:_selectedIndexPath animated:YES];
    CTLContactCell *cell = (CTLContactCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
    [cell.indicatorLayer removeFromSuperlayer];
    
    CGRect headerFrame = self.contactHeader.frame;
    CGRect footerFrame = self.contactToolbar.frame;
    
    headerFrame.origin.y = -100;
    footerFrame.origin.y = CGRectGetHeight(self.view.bounds) + 5;
    
    typeof(self) weakself = self;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.contactHeader.frame = headerFrame;
        self.contactToolbar.frame = footerFrame;
    } completion:^(BOOL finished){
        _inContactMode = NO;
        _selectedPerson = nil;
        _selectedIndexPath = nil;
        
        if(_shouldReorderListOnScroll){
            [weakself sortContactListByAccessDate:_contacts];
            _shouldReorderListOnScroll = NO;
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if(_inContactMode){
        [self rightTitlebarWithAddContactButton];
        [self exitContactMode];
    }
    
    if(_groupPickerIsVisible){
        [self hideGroupPicker:nil];
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
    
    if(_selectedPerson.addressDict){
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
     
    cell.nameLabel.text = [person compositeName];
    
    if([[person phone] length] > 0){
        cell.detailsLabel.text = [person phone];//[self formatPhoneNumber:[person phone]];
    }else if([[person email] length] > 0){
        cell.detailsLabel.text = [person email];
    }else{
        cell.detailsLabel.text = @"";
    }
    
    NSString *timestampStr = [NSDate dateToString:[person accessDate]];
    cell.timestampLabel.text = [timestampStr stringByReplacingOccurrencesOfString:@"Today, " withString:@""];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([_contacts count] == 0){
        return self.view.bounds.size.height;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([_contacts count] == 0){
        _emptyView = [[[NSBundle mainBundle] loadNibNamed:@"CTLContactsEmptyView" owner:self options:nil] objectAtIndex:0];
        self.emptyContactsTitleLabel.text = [self.selectedGroup name];
        self.emptyContactsMessageLabel.text = @"This group has no contacts yet.";
        return _emptyView;
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return !_inContactMode;//do not allow deleting row in "inContact" Mode
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        CTLABPerson *abPerson = [_contacts objectAtIndex:indexPath.row];
        [self.selectedGroup removeMember:abPerson.recordID];
        [_contacts removeObjectAtIndex:indexPath.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //if groupPicker is open dismiss it and do nothing else.
    if(_groupPickerIsVisible){
        [self hideGroupPicker:nil];
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

#pragma mark Share Contact

- (void)shareContactViaSMS:(id)sender
{
    if(![MFMessageComposeViewController canSendText]){
        // Kevin: Maybe error message here?
        return;
    }
    
    MFMessageComposeViewController *smsController = [[MFMessageComposeViewController alloc] init];
    smsController.body = [self generateShareContactMessageString];
    smsController.messageComposeDelegate = self;
    [self presentViewController:smsController animated:YES completion:nil];
}

- (void)shareContactViaEmail:(id)sender {
    if(![MFMailComposeViewController canSendMail]){
        // Kevin: Maybe error message here?
        return;
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setMessageBody:[self generateShareContactMessageString] isHTML:NO];
    [self presentViewController:mailController animated:YES completion:nil];
}

- (NSString *)generateShareContactMessageString {
    NSString *body = [NSString stringWithFormat:@"Here is %@'s contact info: ", _selectedPerson.firstName];
    
    if([_selectedPerson.phone length] > 0){
        body = [body stringByAppendingFormat:@"phone: %@", _selectedPerson.phone];
        if([_selectedPerson.email length] > 0){
            body = [body stringByAppendingString:@", "];
        }
    }
    
    if([_selectedPerson.email length] > 0){
        body = [body stringByAppendingFormat:@"email: %@ ", _selectedPerson.email];
    }
    
    return body;
}

#pragma mark - Message Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if(result == MFMailComposeResultSent){
        //[self updateContactTimestampInPlace];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if(result == MessageComposeResultSent){
        //[self updateContactTimestampInPlace];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
