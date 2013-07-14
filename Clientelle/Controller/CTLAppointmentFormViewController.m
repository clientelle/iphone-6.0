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

#import "CTLCDContact.h"
#import "CTLAppointmentFormViewController.h"
#import "CTLAppointmentsListViewController.h"
#import "CTLPinInterstialViewController.h"
#import "CTLContactImportViewController.h"
#import "CTLContactsListViewController.h"
#import "CTLContactDetailsViewController.h"

#import "CTLCDAppointment.h"
#import "CTLCellBackground.h"
#import "UITableViewCell+CellShadows.h"
#import "CTLViewDecorator.h"

//#import "CTLFactoryAppointment.h"

int CTLContactTextFieldTag = 1;
int CTLStartTimeInputTag = 2;
int CTLEndTimeInputTag = 3;
int CTLTitleInputTag = 4;

@interface CTLAppointmentFormViewController()
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIPickerView *contactPicker;
@property (nonatomic, assign) NSInteger activeInputTag;
@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, strong) EKEvent *event;
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKCalendar *calendar;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, assign) BOOL hasCalendarAccess;
@property (nonatomic, assign) BOOL hasAddress;
@end

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
    
    if(!self.appointment){
        self.headerLabel.text = NSLocalizedString(@"SCHEDULE_AN_APPOINTMENT", nil);
        [self createPlaceholderAppointment];
        self.appointmentFee = [NSDecimalNumber zero];
    }else{
        self.headerLabel.text = NSLocalizedString(@"EDIT_APPOINTMENT", nil);
        self.contact = self.appointment.contact;
        self.appointmentFee = self.appointment.fee;
        [self populateForm:self.appointment];
        _event = [self.eventStore eventWithIdentifier:[self.appointment eventID]];
        if(_event){
            self.appointment.title = _event.title;
            self.appointment.startDate = _event.startDate;
            self.appointment.endDate = _event.endDate;
            [self populateForm:self.appointment];
        }
    }
    
    [self loadContactsInPickerView];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissInputViews:)]];
    
    /*** GENERATE FAKE APPOINTMENTS ***/
    
    //CTLFactoryAppointment *apptFactory = [[CTLFactoryAppointment alloc] init];
    //[apptFactory createAppointments:[NSDate monthsAgo:4]];
    //[apptFactory createAppointments:[NSDate date]];
    //[apptFactory createAppointments:[NSDate monthsFromNow:1]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactWasAdded:) name:CTLNewContactWasAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactsWereImported:) name:CTLContactsWereImportedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.presentedAsModal != YES && [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_LOCKED"]){
        CTLPinInterstialViewController *viewController = (CTLPinInterstialViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"pinInterstitial"];
        [self presentViewController:viewController animated:NO completion:nil];
    }
}

- (void)createPlaceholderAppointment
{
    if(!_event){
        _event = [EKEvent eventWithEventStore:self.eventStore];
        _event.calendar = [self.eventStore defaultCalendarForNewEvents];
    }

    _event.startDate = [NSDate hoursFrom:[NSDate date] numberOfHours:1];;
    _event.endDate = [NSDate hoursFrom:_event.startDate numberOfHours:1];

    if(self.contact){
        _event.title = [NSString stringWithFormat:NSLocalizedString(@"APPOINTMENT_WITH", nil), self.contact.compositeName];
        self.contactNameTextField.text = [self.contact compositeName];
        self.titleTextField.text = _event.title;
        self.addressTextField.text = self.contact.address;
        self.address2TextField.text = self.contact.address2;
    }
}

- (void)contactWasAdded:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[CTLCDContact class]]){
        self.contact = notification.object;
        self.self.contacts = @[self.contact];
        [self.contactPicker reloadAllComponents];
        [self createPlaceholderAppointment];
    }
}

- (void)contactsWereImported:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[NSMutableArray class]]){
        self.self.contacts = [NSArray arrayWithArray:notification.object];
        self.contact = self.self.contacts[0];
        [self.contactPicker reloadAllComponents];
        [self createPlaceholderAppointment];
        [self.contactNameTextField becomeFirstResponder];
    }
}

- (void)loadContactsInPickerView
{
    self.self.contacts = [CTLCDContact MR_findAllSortedBy:@"firstName" ascending:YES];
    [self.contactPicker reloadAllComponents];

    if(self.contact){
        for(NSInteger i=0;i<[self.self.contacts count];i++){
            CTLCDContact *contact = self.self.contacts[i];
            if([contact isEqual:self.contact]){
                [self.contactPicker selectRow:i inComponent:0 animated:NO];
                break;
            }
        }
    }
}

- (IBAction)unformatCurrency:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    textField.text = [NSString stringWithFormat:@"%@", self.appointmentFee];
}

- (NSString *)formattedFee:(NSDecimalNumber *)fee
{
    if ([fee floatValue] == [[NSDecimalNumber zero] floatValue]) {
        return @"";
    }
    
    NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
    NSLocale *locale = [NSLocale currentLocale];
    [currencyFormat setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormat setLocale:locale];
    
    return [currencyFormat stringFromNumber:fee];
}

- (void)checkCalendarPermission
{
    self.hasCalendarAccess = NO;
    self.eventStore = [[EKEventStore alloc] init];
    
    EKAuthorizationStatus EKAuthStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if(EKAuthStatus == EKAuthorizationStatusNotDetermined){
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if(granted){
                self.hasCalendarAccess = YES;
            } else {
                [self displayCalendarPermissionPrompt];
            }
        }];
    } else if(EKAuthStatus == EKAuthorizationStatusAuthorized){
        self.hasCalendarAccess = YES;
    } else {
        [self displayCalendarPermissionPrompt];
    }
    
    self.calendar = [self.eventStore defaultCalendarForNewEvents];
    
    if(!self.calendar){
        self.calendar = [self createCalendar];
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
    self.feeTextField.text = [appointment formattedFee];
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
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.date = [NSDate hoursFrom:[NSDate date] numberOfHours:1]; //next hour
    [self.datePicker addTarget:self action:@selector(setDate:) forControlEvents:UIControlEventValueChanged];
    
    CGSize ContactPickerFrameSize = self.view.frame.size;
    self.contactPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, ContactPickerFrameSize.height, ContactPickerFrameSize.width, 300.0f)];
    self.contactPicker.showsSelectionIndicator = YES;
    self.contactPicker.delegate = self;
    self.contactPicker.dataSource = self;
    [self.contactPicker addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissInputViews:)]];
    
    self.contactNameTextField.inputView = self.contactPicker;
        
    self.startTimeTextField.inputView = self.datePicker;
    self.endTimeTextField.inputView = self.datePicker;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(textField.tag == CTLContactTextFieldTag){
        if([self.self.contacts count] == 0){
            [self promptToImport:textField];
            return NO;
        }else{
            if(!self.contact){
                [self.contactPicker selectRow:0 inComponent:0 animated:NO];
                self.contact = self.self.contacts[0];
                [self chooseContact];
            }            
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}


- (void)promptToImport:(id)sender
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
        [self performSegueWithIdentifier:CTLImporterSegueIdentifier sender:alertView];
    }else if (buttonIndex == 1) {
        [self performSegueWithIdentifier:CTLContactFormSegueIdentifier sender:alertView];
    }
}

#pragma mark - UIPickerView delegate methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.contact = [self.self.contacts objectAtIndex:row];
    [self chooseContact];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    CTLCDContact *person = [self.self.contacts objectAtIndex:row];
    return person.compositeName;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.self.contacts count];
}

- (void)chooseContact
{
    if(self.appointment){
        [self.appointment setContact:self.contact];
    }
    
    self.contactNameTextField.text = self.contact.compositeName;
    self.titleTextField.text =  [NSString stringWithFormat:NSLocalizedString(@"APPOINTMENT_WITH", nil), self.contact.compositeName];
    self.addressTextField.text = self.contact.address;
    self.address2TextField.text = self.contact.address2;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48.0;
}

- (IBAction)showDatePicker:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [textField setBackgroundColor:[UIColor ctlFadedGray]];
    
    self.activeInputTag = textField.tag;
    
    if(self.activeInputTag == CTLStartTimeInputTag){
        if([self.endTimeTextField.text length] > 0 && [self.startTimeTextField.text length] == 0){
            _event.startDate = [NSDate hoursFrom:_event.endDate numberOfHours:-1];
        }
        self.datePicker.date = _event.startDate;
    }
    
    if(self.activeInputTag == CTLEndTimeInputTag){
        if([self.startTimeTextField.text length] > 0 && [self.endTimeTextField.text length] == 0){
            _event.endDate = [NSDate hoursFrom:_event.startDate numberOfHours:1];
        }
        self.datePicker.date = _event.endDate;
    }
    
    textField.text = [NSDate formatDateAndTime:self.datePicker.date];
}

- (void)setDate:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if(self.activeInputTag == CTLStartTimeInputTag || self.activeInputTag == CTLEndTimeInputTag){
        UITextField *textField = (UITextField *)[self.view viewWithTag:self.activeInputTag];
        textField.text = [NSDate formatDateAndTime:[self.datePicker date]];
        
        if(self.activeInputTag == CTLStartTimeInputTag){
            _event.startDate = [self.datePicker date];
            self.startTimeTextField.text = [NSDate formatDateAndTime:_event.startDate];
        }
        
        if(self.activeInputTag == CTLEndTimeInputTag){
            _event.endDate = [self.datePicker date];
            self.endTimeTextField.text = [NSDate formatDateAndTime:_event.endDate];
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
        
        if([_event.startDate compare:_event.endDate] == NSOrderedDescending){
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
        
        if([_event.endDate compare:_event.startDate] == NSOrderedAscending){
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
    //TODO: get local calendar source (device calendar. not imap) when there is no calendar
    EKSource *localSource = nil;
    for (EKSource *source in self.eventStore.sources) {
        if (source.sourceType == EKSourceTypeLocal) {
            localSource = source;
            break;
        }
    }

    EKCalendar *localCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventStore];
    localCalendar.title = NSLocalizedString(@"CALENDAR", nil);
    localCalendar.source = localSource;
    [self.eventStore saveCalendar:localCalendar commit:YES error:nil];
    return localCalendar;
}

- (IBAction)saveAppointment:(id)sender
{
    if(!self.hasCalendarAccess){
        [self displayCalendarPermissionPrompt];
        return;
    }
    
    if(![self validateAppointment]){
        return;
    }
    
    if(_event.eventIdentifier != nil){
        [self cancelAlarms:_event];
    }

    _event.title = self.titleTextField.text;
    _event.location = [NSString stringWithFormat:@"%@ %@", self.addressTextField.text, self.address2TextField.text];
    
    NSError *error = nil;
    [_event setCalendar:[self.eventStore defaultCalendarForNewEvents]];
    [self.eventStore saveEvent:_event span:EKSpanThisEvent commit:YES error:&error];
    
    if(!self.appointment){
        self.appointment = [CTLCDAppointment MR_createEntity];
        self.appointment.eventID = _event.eventIdentifier;
    }

    if(self.contact){
        self.appointment.contact = self.contact;
    }

    self.appointment.startDate = _event.startDate;
    self.appointment.endDate = _event.endDate;
    self.appointment.title = self.titleTextField.text;
    
    if([self.feeTextField.text length] == 0){
        self.appointment.fee = 0;
    }else{
        self.appointment.fee = self.appointmentFee;
    }
 
    self.appointment.address = self.addressTextField.text;
    self.appointment.address2 = self.address2TextField.text;
    
    if(!self.contact.address){
        self.contact.address = self.appointment.address;
    }
    
    if(!self.contact.address2){
        self.contact.address2 = self.appointment.address2;
    }    
    
    if([_event.startDate compare:_event.endDate] == NSOrderedDescending){
        [self scheduleNotificationWithItem:_event interval:5]; //5 minutes before due. show calendar alert
        [_event addAlarm:[EKAlarm alarmWithRelativeOffset:-900.0f]]; //15 minutes before, show local alert
    }

    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showSplash"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:CTLTimestampForRowNotification object:nil];
    
    [self dismiss:sender];
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
    notification.fireDate = [itemDate dateByAddingTimeInterval:-(minutesBefore*60)];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"APPOINTMENT", nil), item.title];
    notification.alertAction = NSLocalizedString(@"VIEW_APPOINTMENT", nil);
    
    notification.userInfo = @{@"navigationController":@"appointments", @"viewController":@"appointmentFormViewController", @"eventID":item.eventIdentifier};
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark - Outlet Controls

- (void)dismiss:(id)sender
{
    [self resetForm];
    if(self.presentedAsModal){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [[NSManagedObjectContext MR_contextForCurrentThread] reset];
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
    
    if(self.appointment){
        if([textField.text length] == 0 && self.appointment.contact != nil){
            self.appointment.contact = nil;
        }
    }
}

- (IBAction)formatFeeString:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    if([textField.text length]){
        NSLocale *locale = [NSLocale currentLocale];

        self.appointmentFee = [NSDecimalNumber decimalNumberWithString:textField.text locale:locale];
        
        if (self.appointmentFee == nil || [self.appointmentFee floatValue] == [[NSDecimalNumber zero] floatValue]) {
            textField.text = @"";
        }else{
            NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
            NSLocale *locale = [NSLocale currentLocale];
            [currencyFormat setNumberStyle:NSNumberFormatterCurrencyStyle];
            [currencyFormat setLocale:locale];
            textField.text = [currencyFormat stringFromNumber:self.appointmentFee];
        }
    }
}

- (void)dismissInputViews:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

- (void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}



@end
