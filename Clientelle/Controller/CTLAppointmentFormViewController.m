//
//  CTLAddEventViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/9/13.
//  Copyright (c) 2013 Clientelle Leads LLC. All rights reserved.
//

#import "UIColor+CTLColor.h"
#import "NSDate+CTLDate.h"
#import "UILabel+CTLLabel.h"

#import "CTLCDPerson.h"
#import "CTLABPerson.h"
#import "CTLAppointmentFormViewController.h"
#import "CTLAppointmentsListViewController.h"

#import "CTLContactImportViewController.h"
#import "CTLContactsListViewController.h"
#import "CTLContactViewController.h"

#import "CTLCDAppointment.h"
#import "CTLCellBackground.h"
#import "UITableViewCell+CellShadows.h"
#import "CTLViewDecorator.h"

#import "CTLPickerView.h"

//#import "CTLFactoryAppointment.h"

int CTLContactTextFieldTag = 1;
int CTLStartTimeInputTag = 2;
int CTLEndTimeInputTag = 3;

@implementation CTLAppointmentFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"APPOINTMENT", nil);
        
    if(self.presentedAsModal){
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    [self configureInputFields];
    [self checkCalendarPermission];
    [self loadContactsInPickerView];
    [self checkForAddressBookUpdates];
        
    if(!self.cdAppointment){
        _isNewAppointment = YES;
        [self createPlaceholderAppointment];
    }else{
        _isNewAppointment = NO;
        if(self.cdAppointment.privateValue == NO){
            //It's not private. Pull updates from calendar
            _appointment = [_eventStore eventWithIdentifier:[self.cdAppointment eventID]];
            self.cdAppointment.title = _appointment.title;
            self.cdAppointment.startDate = _appointment.startDate;
            self.cdAppointment.endDate = _appointment.endDate;
        }

        [self populateForm:self.cdAppointment];
    }
     
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissInputViews:)]];
    
    /*** GENERATE FAKE APPOINTMENTS ***/
    
    //CTLFactoryAppointment *apptFactory = [[CTLFactoryAppointment alloc] init];
    //[apptFactory createAppointments:[NSDate monthsAgo:4]];
    //[apptFactory createAppointments:[NSDate date]];
    //[apptFactory createAppointments:[NSDate monthsFromNow:1]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAddressBookChanges:) name:kAddressBookDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactWasAdded:) name:CTLNewContactWasAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactsWereImported:) name:CTLContactsWereImportedNotification object:nil];

}

- (void)checkForAddressBookUpdates
{
    if(!self.addressBookRef){
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                self.addressBookRef = addressBookRef;
                [self updateAddessBookContacts];
            });
        }
    }
}


- (void)createPlaceholderAppointment
{
    if(!_appointment){
        _appointment = [EKEvent eventWithEventStore:_eventStore];
        _appointment.calendar = [_eventStore defaultCalendarForNewEvents];
    }
    
    self.cdAppointment = [CTLCDAppointment MR_createEntity];
    self.cdAppointment.startDate = [NSDate hoursFrom:[NSDate date] numberOfHours:1];;
    self.cdAppointment.endDate = [NSDate hoursFrom:self.cdAppointment.startDate numberOfHours:1];

    if(self.contact){
        [self.cdAppointment setContact:self.contact];
        self.contactNameTextField.text = self.contact.compositeName;
    }
    
    _appointment.startDate = self.cdAppointment.startDate;
    _appointment.endDate = self.cdAppointment.endDate;
    _appointment.title = self.cdAppointment.title;
}

- (void)contactWasAdded:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[CTLCDPerson class]]){
        self.contact = notification.object;
        _contacts = @[self.contact];
        [_contactPicker reloadAllComponents];
        [self createPlaceholderAppointment];
    }
}

- (void)contactsWereImported:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[NSMutableArray class]]){
        _contacts = [NSArray arrayWithArray:notification.object];
        self.contact = _contacts[0];
        [_contactPicker reloadAllComponents];
        [self createPlaceholderAppointment];
        [self.contactNameTextField becomeFirstResponder];
    }
}

- (void)loadContactsInPickerView
{
    _contacts = [CTLCDPerson MR_findAllSortedBy:@"firstName" ascending:YES];
    [_contactPicker reloadAllComponents];
}

- (void)displayAddressBookPermissionPrompt
{
    UIAlertView *requirePermission = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REQUIRES_ACCESS_TO_CONTACTS", nil)
                                                                message:NSLocalizedString(@"GO_TO_SETTINGS_CONTACTS", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
    
    [requirePermission show];
}

- (void)handleAddressBookChanges:(NSNotification *)notification
{
    if(notification){
        self.addressBookRef = (__bridge ABAddressBookRef)notification.object;
        [self updateAddessBookContacts];
    }
    
    if(!self.addressBookRef){
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                // First time access has been granted
                if(granted){
                    self.addressBookRef = addressBookRef;
                    [self updateAddessBookContacts];
                }else{
                    [self displayAddressBookPermissionPrompt];
                }
            });
        } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // The user has previously given access.
            self.addressBookRef = addressBookRef;
            [self updateAddessBookContacts];
        } else {
            // The user has previously denied access
            [self displayAddressBookPermissionPrompt];
        }
    }
}

- (void)updateAddessBookContacts
{
    [CTLABPerson peopleFromAddressBook:self.addressBookRef withBlock:^(NSDictionary *results){
        NSMutableDictionary *peopleDict = [results mutableCopy];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordID != nil AND isPrivate = NO"];
        NSArray *contactsArr = [CTLCDPerson MR_findAllWithPredicate:predicate];
        
        for(NSInteger i=0;i<[contactsArr count];i++){
            CTLCDPerson *contact = contactsArr[i];
            CTLABPerson *person = [peopleDict objectForKey:contact.recordID];
            [contact updateFromABPerson:person];
        }
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context MR_saveToPersistentStoreWithCompletion:^(BOOL result, NSError *error){
           [self loadContactsInPickerView];
        }];
    }];
}

- (IBAction)unformatCurrency:(UITextField *)textField
{
    if ([self.cdAppointment.fee floatValue] > [[NSDecimalNumber zero] floatValue]) {
        textField.text = [NSString stringWithFormat:@"%@", self.cdAppointment.fee];
    }
}

- (NSString *)formatCurrency:(NSDecimalNumber *)amount
{
    if ([amount floatValue] == [[NSDecimalNumber zero] floatValue]) {
        return @"";
    }
    
    NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
    NSLocale *locale = [NSLocale currentLocale];
    [currencyFormat setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormat setLocale:locale];
    
    NSString *currencyStr = [currencyFormat stringFromNumber:amount];
    // NSLog(@"locale %@ | %@", [locale localeIdentifier], currencyStr);//Eg: $50.00
    return currencyStr;
}

- (void)checkCalendarPermission
{
    _hasCalendarAccess = NO;
    _eventStore = [[EKEventStore alloc] init];
    
    EKAuthorizationStatus EKAuthStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if(EKAuthStatus == EKAuthorizationStatusNotDetermined){
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if(granted){
                _hasCalendarAccess = YES;
            } else {
                [self displayCalendarPermissionPrompt];
            }
        }];
    } else if(EKAuthStatus == EKAuthorizationStatusAuthorized){
        _hasCalendarAccess = YES;
    } else {
        [self displayCalendarPermissionPrompt];
    }
    
    _calendar = [_eventStore defaultCalendarForNewEvents];
    
    if(!_calendar){
        _calendar = [self createCalendar];
    }
}

- (void)populateForm:(CTLCDAppointment *)appointment
{
    self.contactNameTextField.text = appointment.contact.compositeName;
    self.startTimeTextField.text = [NSDate formatDateAndTime:appointment.startDate];
    self.endTimeTextField.text = [NSDate formatDateAndTime:appointment.endDate];
    self.titleTextField.text = appointment.title;
    self.addressTextField.text = appointment.address;
    self.address2TextField.text = appointment.address2;
    self.feeTextField.text = [self formatCurrency:appointment.fee];
}

- (void)configureInputFields
{
    self.titleTextField.placeholder = NSLocalizedString(@"APPOINTMENT_DESCRIPTION", nil);
    self.contactNameTextField.placeholder = NSLocalizedString(@"CHOOSE_A_CONTACT", nil);
    self.startTimeTextField.placeholder = NSLocalizedString(@"START_TIME", nil);
    self.endTimeTextField.placeholder = NSLocalizedString(@"END_TIME", nil);
    self.feeTextField.placeholder = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"OPTIONAL", nil)];
    self.addressTextField.placeholder = NSLocalizedString(@"STREET_ADDRESS", nil);
    self.address2TextField.placeholder = NSLocalizedString(@"CITY_STATE_ZIP", nil);
    
    self.startTimeTextField.tag = CTLStartTimeInputTag;
    self.endTimeTextField.tag = CTLEndTimeInputTag;
    
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    _datePicker.date = [NSDate hoursFrom:[NSDate date] numberOfHours:1]; //next hour
    [_datePicker addTarget:self action:@selector(setDate:) forControlEvents:UIControlEventValueChanged];
    
    CGSize ContactPickerFrameSize = self.view.frame.size;
    _contactPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, ContactPickerFrameSize.height, ContactPickerFrameSize.width, 300.0f)];
    _contactPicker.showsSelectionIndicator = YES;
    _contactPicker.delegate = self;
    _contactPicker.dataSource = self;
    
    self.contactNameTextField.inputView = _contactPicker;
        
    self.startTimeTextField.inputView = _datePicker;
    self.endTimeTextField.inputView = _datePicker;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(textField.tag == CTLContactTextFieldTag && [_contacts count] == 0){
        [self promptToImport:textField];
        return NO;
    }
    
    return YES;
}


- (void)promptToImport:(UITextField *)textField
{
    UIAlertView *importPrompt = [[UIAlertView alloc] initWithTitle:nil
                                                           message:NSLocalizedString(@"YOU_DO_NOT_HAVE_CONTACTS_YET", nil)
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"IMPORT", nil), NSLocalizedString(@"ADD", nil), nil];
    
    [importPrompt show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier:CTLImporterSegueIdentifyer sender:alertView];
    }else if (buttonIndex == 1) {
        [self performSegueWithIdentifier:CTLContactFormSegueIdentifyer sender:alertView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:CTLImporterSegueIdentifyer]){
        //reset context because a placeholder appointment has been created in memory
        [[NSManagedObjectContext MR_contextForCurrentThread] reset];
        CTLContactImportViewController *importer = [segue destinationViewController];
        [importer setAddressBookRef:self.addressBookRef];
        return;
    }
    
    if ([[segue identifier] isEqualToString:CTLContactFormSegueIdentifyer]) {
        //reset context because a placeholder appointment has been created in memory
        [[NSManagedObjectContext MR_contextForCurrentThread] reset];
        CTLContactViewController *contactFormViewController = [segue destinationViewController];
        [contactFormViewController setAddressBookRef:self.addressBookRef];
        return;
    }
}

#pragma mark - UIPickerView delegate methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    CTLCDPerson *person = [_contacts objectAtIndex:row];
    [self.cdAppointment setContact:person];
    self.contactNameTextField.text = person.compositeName;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    CTLCDPerson *person = [_contacts objectAtIndex:row];
    return person.compositeName;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [_contacts count];
}

- (void)displayCalendarPermissionPrompt
{
    UIAlertView *requirePermission = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REQUIRES_ACCESS_TO_CALENDARS", nil)
                                                                message:NSLocalizedString(@"GO_TO_SETTINGS_CALENDARS", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
    [requirePermission show];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell addShadowToCellInTableView:self.tableView atIndexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat width = self.tableView.bounds.size.width - 20.0f;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10.0f, width, 30.0f)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, width, 20.0f)];
    headerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor darkGrayColor];
    
    [headerView setFrame:CGRectMake(0, 10.0f, width, 40.0f)];
    
    if(_isNewAppointment){
        headerLabel.text = NSLocalizedString(@"SCHEDULE_AN_APPOINTMENT", nil);
    }else{
        headerLabel.text = NSLocalizedString(@"EDIT_APPOINTMENT", nil);
    }
    
    [headerView addSubview:headerLabel];

    return headerView;
}

- (IBAction)showDatePicker:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [textField setBackgroundColor:[UIColor ctlFadedGray]];
    
    _activeInputTag = textField.tag;
    
    if(_activeInputTag == CTLStartTimeInputTag){
        if([self.endTimeTextField.text length] > 0 && [self.startTimeTextField.text length] == 0){
            _appointment.startDate = [NSDate hoursFrom:_appointment.endDate numberOfHours:-1];
        }
        _datePicker.date = _appointment.startDate;
    }
    
    if(_activeInputTag == CTLEndTimeInputTag){
        if([self.startTimeTextField.text length] > 0 && [self.endTimeTextField.text length] == 0){
            _appointment.endDate = [NSDate hoursFrom:_appointment.startDate numberOfHours:1];
        }
        _datePicker.date = _appointment.endDate;
    }
    
    textField.text = [NSDate formatDateAndTime:_datePicker.date];
}

- (void)setDate:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if(_activeInputTag == CTLStartTimeInputTag || _activeInputTag == CTLEndTimeInputTag){
        UITextField *textField = (UITextField *)[self.view viewWithTag:_activeInputTag];
        textField.text = [NSDate formatDateAndTime:[_datePicker date]];
        
        if(_activeInputTag == CTLStartTimeInputTag){
            _appointment.startDate = [_datePicker date];
            self.cdAppointment.startDate = _appointment.startDate;
            self.startTimeTextField.text = [NSDate formatDateAndTime:_appointment.startDate];
        }
        
        if(_activeInputTag == CTLEndTimeInputTag){
            _appointment.endDate = [_datePicker date];
            self.cdAppointment.endDate = _appointment.endDate;
            self.endTimeTextField.text = [NSDate formatDateAndTime:_appointment.endDate];
        }
    }
}

- (BOOL)validateAppointment
{
    BOOL isValid = YES;
    UIColor *errorColor = [UIColor ctlInputErrorBackground];
    
    if([self.contactNameTextField.text length] == 0){
        [self.contactNameTextField setBackgroundColor:errorColor];
        isValid = NO;
    }else{
        [self.contactNameTextField setBackgroundColor:[UIColor clearColor]];
    }
    
    if([self.titleTextField.text length] == 0){
        [self.titleTextField setBackgroundColor:errorColor];
        isValid = NO;
    }else{
        [self.titleTextField setBackgroundColor:[UIColor clearColor]];
    }
    
    if([self.startTimeTextField.text length] == 0){
        [self.startTimeTextField setBackgroundColor:errorColor];
        isValid = NO;
    }else{
        [self.startTimeTextField setBackgroundColor:[UIColor clearColor]];
        
        if([_appointment.startDate compare:_appointment.endDate] == NSOrderedDescending){
            [self.startTimeTextField setBackgroundColor:errorColor];
            isValid = NO;
        }else{
            [self.startTimeTextField setBackgroundColor:[UIColor clearColor]];
        }
    }
    
    if([self.endTimeTextField.text length] == 0){
        [self.endTimeTextField setBackgroundColor:errorColor];
        isValid = NO;
    }else{
        [self.endTimeTextField setBackgroundColor:[UIColor clearColor]];
        
        if([_appointment.endDate compare:_appointment.startDate] == NSOrderedAscending){
            [self.endTimeTextField setBackgroundColor:errorColor];
            isValid = NO;
        }else{
            [self.endTimeTextField setBackgroundColor:[UIColor clearColor]];
        }
    }
    
    return isValid;
}

- (EKCalendar *)createCalendar
{
    //TODO: no calendar no sync!
    //get local calendar source (device calendar. not imap)
    EKSource *localSource = nil;
    for (EKSource *source in _eventStore.sources) {
        if (source.sourceType == EKSourceTypeLocal) {
            localSource = source;
            break;
        }
    }

    EKCalendar *localCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:_eventStore];
    localCalendar.title = NSLocalizedString(@"CALENDAR", nil);
    localCalendar.source = localSource;
    [_eventStore saveCalendar:localCalendar commit:YES error:nil];
    return localCalendar;
}

- (IBAction)saveAppointment:(id)sender
{
    if(!_hasCalendarAccess){
        [self displayCalendarPermissionPrompt];
        return;
    }
    
    if(![self validateAppointment]){
        return;
    }
    
    _appointment.title = self.titleTextField.text;
    _appointment.location = [NSString stringWithFormat:@"%@ %@", self.addressTextField.text, self.address2TextField.text];
    
    //self.cdAppointment.contact = [_contacts]
    self.cdAppointment.address = self.addressTextField.text;
    self.cdAppointment.address2 = self.address2TextField.text;
    self.cdAppointment.title = _appointment.title;
    
    if(_appointment.eventIdentifier != nil){
        [self cancelAlarms:_appointment];
    }
    
    NSError *error = nil;
    [_appointment setCalendar:[_eventStore defaultCalendarForNewEvents]];
    [_eventStore saveEvent:_appointment span:EKSpanThisEvent commit:YES error:&error];
    
    if([_datePicker.date compare:[NSDate date]] == NSOrderedDescending){
        [self scheduleNotificationWithItem:_appointment interval:5];
        [_appointment addAlarm:[EKAlarm alarmWithRelativeOffset:-900.0f]];
        [_appointment addAlarm:[EKAlarm alarmWithAbsoluteDate:_datePicker.date]];
    }
    
    if(![self.cdAppointment eventID] && _appointment.eventIdentifier != nil){
        self.cdAppointment.eventID = _appointment.eventIdentifier;
    }

    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:CTLReloadAppointmentsNotification object:nil];
    
    if(self.contact){
        [[NSNotificationCenter defaultCenter] postNotificationName:CTLTimestampForRowNotification object:nil];
    }
    
    [self dismiss:nil];
}

-(void)cancelAlarms:(EKEvent *)appointment
{
    NSArray *alarms = appointment.alarms;
    for(NSInteger i=0;i<[alarms count];i++){
        [appointment removeAlarm:alarms[i]];
        NSLog(@"REMOVED ALARM %@", alarms[i]);
    }
    
    for (UILocalNotification *notification in [[[UIApplication sharedApplication] scheduledLocalNotifications] copy]){
        NSDictionary *userInfo = notification.userInfo;
        if ([appointment.eventIdentifier isEqualToString:[userInfo objectForKey:@"eventID"]]){
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
             NSLog(@"CANCELED LOCAL NOTIF");
        }
    }
}

- (void)scheduleNotificationWithItem:(EKEvent *)item interval:(int)minutesBefore
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if (notification == nil){
        return;
    }
    
    NSDate *itemDate = item.startDate;
    notification.applicationIconBadgeNumber = 1;
    notification.soundName = UILocalNotificationDefaultSoundName;
    //notification.fireDate = [itemDate dateByAddingTimeInterval:-(minutesBefore*60)];
    notification.fireDate = itemDate;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"APPOINTMENT", nil), item.title];
    notification.alertAction = NSLocalizedString(@"VIEW_APPOINTMENT", nil);
    
    notification.userInfo = @{@"navigationController":@"appointmentsNavigationController", @"viewController":@"appointmentFormViewController", @"eventID":item.eventIdentifier};
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark - Outlet Controls

- (void)dismiss:(id)sender
{
    [self resetForm];
    if(self.presentedAsModal){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)resetForm
{
    [self.titleTextField setBackgroundColor:[UIColor clearColor]];
    [self.startTimeTextField setBackgroundColor:[UIColor clearColor]];
    [self.endTimeTextField setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)contactDidChange:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    if([textField.text length] == 0 && self.cdAppointment.contact != nil){
        self.cdAppointment.contact = nil;
    }
}

- (IBAction)formatFeeString:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    if([textField.text length]){
        NSLocale *locale = [NSLocale currentLocale];
        self.cdAppointment.fee = [NSDecimalNumber decimalNumberWithString:textField.text locale:locale];
        textField.text = [self formatCurrency:self.cdAppointment.fee];
    }
}

- (void)dismissInputViews:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

@end
