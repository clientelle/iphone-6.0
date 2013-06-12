#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "NSString+CTLString.h"
#import "NSDate+CTLDate.h"
#import "UILabel+CTLLabel.h"

#import "CTLSlideMenuController.h"

#import "CTLContactsListViewController.h"
#import "CTLContactDetailsViewController.h"
#import "CTLContactImportViewController.h"
#import "CTLAppointmentFormViewController.h"
#import "CTLMessagePreferenceViewController.h"

#import "CTLContactCell.h"


#import "CTLABPerson.h"
#import "CTLCDContact.h"

#import "CTLPickerView.h"
#import "CTLPickerButton.h"
#import "KBPopupBubbleView.h"

NSString *const CTLContactsWereImportedNotification = @"com.clientelle.notifications.contactsWereImported";
NSString *const CTLContactListReloadNotification = @"com.clientelle.notifications.reloadContacts";
NSString *const CTLTimestampForRowNotification = @"com.clientelle.notifications.updateContactTimestamp";
NSString *const CTLNewContactWasAddedNotification = @"com.clientelle.com.notifications.contactWasAdded";
NSString *const CTLContactRowDidChangeNotification = @"com.clientelle.com.notifications.contactRowDidChange";
NSString *const CTLSortOrderSelectedIndex = @"com.clientelle.notifcations.selectedSortOrder";

NSString *const CTLImporterSegueIdentifier = @"toImporter";
NSString *const CTLContactFormSegueIdentifier = @"toContactForm";
NSString *const CTLAppointmentSegueIdentifier = @"toSetAppointment";

int const CTLShareContactActionSheetTag = 234;
int const CTLAddContactActionSheetTag = 424;

@implementation CTLContactsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _emptyView = [self noContactsView];
    _inContactMode = NO;
    _shouldReorderListOnScroll = NO;
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    
    [self rightTitlebarWithAddContactButton];
    [self buildSortPicker];
    [self buildPickerButton];
    [self prepareContactViewMode];
    [self loadAllContacts];
    [self prepareSortTooltip];
    [self registerNotificationsObservers];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(_sortTooltip){
        [_sortTooltip removeFromSuperview];
    }
}

- (void)prepareSortTooltip
{
    if([[self.fetchedResultsController fetchedObjects] count] > 1 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"display_sort_tooltip_once"]){
        [self displaySortTooltip:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"display_sort_tooltip_once"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
    _filteredContacts = [NSMutableArray array];
    
    
    if([CTLCDContact countOfEntities] > 0){
        
        [self buildSearchBar];
       
        NSInteger sortFilterRow = [_sortPickerView selectedRowInComponent:0];
        NSString *fieldName = _sortArray[sortFilterRow][@"field"];
        BOOL ASC = [_sortArray[sortFilterRow][@"asc"] boolValue];
        
        self.fetchedResultsController = [CTLCDContact fetchAllSortedBy:fieldName ascending:ASC withPredicate:nil groupBy:nil delegate:self];
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
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"display_sort_tooltip_once"]){
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(displaySortTooltip:) userInfo:nil repeats:NO];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"display_sort_tooltip_once"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
}

- (void)buildPickerButton
{
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

#pragma mark - Sort Picker Delegate

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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
     switch(actionSheet.tag){
        case CTLAddContactActionSheetTag:
            switch(buttonIndex){
                case 0:
                    _selectedPerson = nil;
                    [self performSegueWithIdentifier:CTLContactFormSegueIdentifier sender:self];
                    break;
                case 1:
                    [self performSegueWithIdentifier:CTLImporterSegueIdentifier sender:self];
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
    [self performSegueWithIdentifier:CTLContactFormSegueIdentifier sender:self];
}

- (void)showImporter:(id)sender
{
    [self hideSortPicker];
    [self performSegueWithIdentifier:CTLImporterSegueIdentifier sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:CTLContactFormSegueIdentifier]) {
        CTLContactDetailsViewController *contactFormViewController = [segue destinationViewController];
        if(_selectedPerson){
            [contactFormViewController setContact:_selectedPerson];
        }
        return;
    }
    
    if([[segue identifier] isEqualToString:CTLAppointmentSegueIdentifier]){
        UINavigationController *navigationController = [segue destinationViewController];
        CTLAppointmentFormViewController *appointmentViewController = (CTLAppointmentFormViewController *)navigationController.topViewController;
        [appointmentViewController setPresentedAsModal:YES];
        [appointmentViewController setContact:_selectedPerson];
        return;
    }
    
    if([[segue identifier] isEqualToString:@"toMessagePreference"]){
        CTLMessagePreferenceViewController *viewController = [segue destinationViewController];
        [viewController setIsModal:YES];
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
    
    CGRect toolbarFrame = CGRectMake(0, viewSize.height + CTLContactModeToolbarViewHeight + shadowOffset, viewSize.width, CTLContactModeToolbarViewHeight);
    
    self.contactToolbar = [[CTLContactToolbarView alloc] initWithFrame:toolbarFrame];
    
    CTLMessagePreferenceType messagePreference = [[NSUserDefaults standardUserDefaults] integerForKey:@"CTLMessagePreferenceType"];
    
    [self.contactToolbar setPreferenceForMessageButton:messagePreference];
    
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
    _selectedPerson = contact;
    [self rightTitlebarWithEditContactButton];
    [self populateViewData:self.contactHeader withContact:contact];
    [self configureForContact:self.contactToolbar withContact:contact];
    
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

- (void)populateViewData:(CTLContactHeaderView *)headerView withContact:(CTLCDContact *)contact
{
    headerView.delegate = self;
    [headerView reset];
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

- (void)configureForContact:(CTLContactToolbarView *)toolbar withContact:(CTLCDContact *)contact
{
    toolbar.delegate = self;
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
    
    CTLCDContact *person = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        person = [_filteredContacts objectAtIndex:indexPath.row];
    }else{
        person = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
    }
     
    cell.nameLabel.text = [self generatePersonName:person];
    cell.detailsLabel.text = [person displayContactStr];
        
    if(person.lastAccessed){
        cell.timestampLabel.text = [self generateDateStamp:person.lastAccessed];
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
        _selectedPerson = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
    }

    _selectedIndexPath = indexPath;
    [self enterContactMode:_selectedPerson];
}

- (void)deleteContact:(CTLCDContact *)contact
{
    [contact MR_deleteEntity];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

- (NSString *)generatePersonName:(CTLCDContact *)person
{
    NSMutableString *compositeName = [NSMutableString stringWithString:@""];
    
    if([_sortPickerView selectedRowInComponent:0] == 2){
        if([person.lastName length] > 0){
            [compositeName appendString:person.lastName];
        }
        
        if([person.firstName length] > 0){
            if([person.lastName length] > 0){
                [compositeName appendFormat:@", %@", person.firstName];
            }else{
                [compositeName appendFormat:@" %@", person.firstName];
            }
        }
    }else{
        if([person.firstName length] > 0){
            [compositeName appendString:person.firstName];
        }
        
        if([person.lastName length] > 0){
            [compositeName appendFormat:@" %@", person.lastName];
        }
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
    NSString *cleanPhoneNumber = [NSString cleanPhoneNumber:[_selectedPerson phone]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", cleanPhoneNumber]]];
    [self saveTimestampForContact];
}

- (void)showEmailForPerson:(id)sender
{
    NSLog(@"showEmailForPerson");
    return;
    
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
    NSLog(@"showSMSForPerson");
    return;
    
    if(_selectedPerson.mobile){
        NSString *sms = [NSString stringWithFormat:@"sms: %@", [NSString cleanPhoneNumber:_selectedPerson.mobile]];
        NSString *smsEncoded = [sms stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:smsEncoded]];
        [self saveTimestampForContact];
    }
}

- (void)showMessagePreferencePrompt:(id)sender
{
    NSLog(@"showMessagePreferencePrompt");
    
    [self performSegueWithIdentifier:@"toMessagePreference" sender:sender];
}

- (void)showMessageActionSheet:(id)sender
{
    NSLog(@"showMessageActionSheet");
}

- (void)showCtlMsgForPerson:(id)sender
{
    NSLog(@"showCtlMsgForPerson");
    return;
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
    _selectedPerson.lastAccessed = [NSDate date];
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
        CTLContactCell *cell = (CTLContactCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
        cell.timestampLabel.text = [NSDate formatShortTimeOnly:[NSDate date]];
        _shouldReorderListOnScroll = YES;
    }];
}

- (void)timestampForRowDidChange:(NSNotification *)notification
{
    [self saveTimestampForContact];
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)filterContactListForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[_filteredContacts removeAllObjects];
    
    NSArray *contacts = [self.fetchedResultsController fetchedObjects];
    
	for (NSInteger i=0;i<[contacts count]; i++){
        CTLCDContact *person = contacts[i];
        NSComparisonResult result = [person.compositeName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
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
    if([notification.object isKindOfClass:[CTLCDContact class]]){
        _selectedPerson = notification.object;
        _shouldReorderListOnScroll = YES;
        [self loadAllContacts];
        [self enterContactMode:notification.object];
    }
}

- (void)contactRowDidChange:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[CTLCDContact class]]){
        _selectedPerson = notification.object;
        _shouldReorderListOnScroll = YES;
        [self loadAllContacts];
        [self populateViewData:self.contactHeader withContact:_selectedPerson];
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

- (void)messsagePreferenceDidChange:(NSNotification *)notification
{
    CTLMessagePreferenceType messagePreference = [notification.object intValue];
    _selectedPerson.preferredConactTypeValue = messagePreference;
    
    [self.contactToolbar.messageButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    
    switch(messagePreference){
        case CTLMessagePreferenceTypeUndetermined:
            
            [self.contactToolbar.messageButton setImage:[UIImage imageNamed:@"09-chat-2"] forState:UIControlStateNormal];
            
            [self.contactToolbar.messageButton addTarget:self action:@selector(showMessagePreferencePrompt:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
        case CTLMessagePreferenceTypeAsk:
            
            [self.contactToolbar.messageButton setImage:[UIImage imageNamed:@"09-chat-2"] forState:UIControlStateNormal];
            
            [self.contactToolbar.messageButton addTarget:self action:@selector(showMessageActionSheet:) forControlEvents:UIControlEventTouchUpInside];
                        
            break;
        case CTLMessagePreferenceTypeEmail:
            
            [self.contactToolbar.messageButton setImage:[UIImage imageNamed:@"18-envelope"] forState:UIControlStateNormal];
            
            [self.contactToolbar.messageButton addTarget:self action:@selector(showEmailForPerson:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
        case CTLMessagePreferenceTypeSms:
                        
            [self.contactToolbar.messageButton setImage:[UIImage imageNamed:@"09-chat-2"] forState:UIControlStateNormal];
            
            [self.contactToolbar.messageButton addTarget:self action:@selector(showSMSForPerson:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
        case CTLMessagePreferenceTypeCtl:
            
            [self.contactToolbar.messageButton setImage:[UIImage imageNamed:@"09-chat-2"] forState:UIControlStateNormal];
            
            [self.contactToolbar.messageButton addTarget:self action:@selector(showCtlMsgForPerson:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
    }
    
    
    [self.contactToolbar setPreferenceForMessageButton:messagePreference];
}

- (void)registerNotificationsObservers
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    
    [notification addObserver:self selector:@selector(displayShareContactActionSheet:) name:CTLShareContactNotification object:nil];
    [notification addObserver:self selector:@selector(reloadContactListAfterImport:) name:CTLContactsWereImportedNotification object:nil];
    [notification addObserver:self selector:@selector(reloadContactList:) name:CTLContactListReloadNotification object:nil];
    [notification addObserver:self selector:@selector(timestampForRowDidChange:) name:CTLTimestampForRowNotification object:nil];
    [notification addObserver:self selector:@selector(newContactWasAdded:) name:CTLNewContactWasAddedNotification object:nil];
    [notification addObserver:self selector:@selector(contactRowDidChange:) name:CTLContactRowDidChangeNotification object:nil];
    [notification addObserver:self selector:@selector(messsagePreferenceDidChange:) name:@"com.clientelle.notification.messagePreference" object:nil];
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
