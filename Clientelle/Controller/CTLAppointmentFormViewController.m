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

#import "CTLABPerson.h"
#import "CTLABGroup.h"
#import "CTLCDPerson.h"
#import "CTLAppointmentFormViewController.h"
#import "CTLContactsListViewController.h"
#import "CTLAppointmentsListViewController.h"

#import "CTLCDAppointment.h"
#import "CTLCellBackground.h"
#import "UITableViewCell+CellShadows.h"
#import "CTLViewDecorator.h"

//#import "CTLFactoryAppointment.h"

int CTLStartTimeInputTag = 2;
int CTLEndTimeInputTag = 3;

@implementation CTLAppointmentFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"SET_APPOINTMENT", nil);
    
    if(self.presentedAsModal){
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    _hasCalendarAccess = NO;
    _eventStore = [[EKEventStore alloc] init];
    
    [self configureInputs];
    [self checkPermission];
    
    _calendar = [_eventStore defaultCalendarForNewEvents];
    
    if(!_calendar){
        _calendar = [self createCalendar];
    }
    
    //IB tags -> Core Data mapping
    _fields = @[@"", @"title", @"startDate", @"endDate", @"notes", @"address", @"city",  @"state", @"zip"];
    
    if(!self.cdAppointment){
        self.cdAppointment = [CTLCDAppointment MR_createEntity];
        _appointment = [EKEvent eventWithEventStore:_eventStore];
        _appointment.calendar = [_eventStore defaultCalendarForNewEvents];
        
        _appointment.startDate = _datePicker.date;
        _appointment.endDate = [NSDate hoursFrom:_appointment.startDate numberOfHours:1];
        
        self.cdAppointment.startDate = _appointment.startDate;
        self.cdAppointment.endDate = _appointment.endDate;
        
    }else{
        _appointment = [_eventStore eventWithIdentifier:[self.cdAppointment eventID]];
        
        if(_appointment){

            self.titleTextField.text = _appointment.title;
            self.startTimeTextField.text = [NSDate formatDateAndTime:_appointment.startDate];
            self.endTimeTextField.text = [NSDate formatDateAndTime:_appointment.endDate];
            self.notesTextField.text = _appointment.notes;
            
            //appointemnt location
            self.addressTextField.text = [self.cdAppointment address];
            self.cityTextField.text = [self.cdAppointment city];
            self.stateTextField.text = [self.cdAppointment state];
            self.zipTextField.text = [self.cdAppointment zip];
        }
    }
    
    if(self.contact){
        NSString *appointmentTitle = [NSString stringWithFormat:NSLocalizedString(@"MEETING_WITH", nil), [self.contact compositeName]];
        _appointment.title = appointmentTitle;
        [self.cdAppointment setTitle:appointmentTitle];
        self.titleTextField.text = appointmentTitle;
    }
    
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissInputViews:)]];
    
    /*** GENERATE FAKE APPOINTMENTS ***/
    
    
    //CTLFactoryAppointment *apptFactory = [[CTLFactoryAppointment alloc] init];
    //[apptFactory createAppointments:[NSDate monthsAgo:4]];
    //[apptFactory createAppointments:[NSDate date]];
    //[apptFactory createAppointments:[NSDate monthsFromNow:1]];
   
    
}

- (void)checkPermission
{
    EKAuthorizationStatus EKAuthStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if(EKAuthStatus == EKAuthorizationStatusNotDetermined){
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if(granted){
                _hasCalendarAccess = YES;
            } else {
                [self displayPermissionPrompt];
            }
        }];
    } else if(EKAuthStatus == EKAuthorizationStatusAuthorized){
        _hasCalendarAccess = YES;
    } else {
        [self displayPermissionPrompt];
    }
}

- (void)configureInputs
{
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    _datePicker.date = [NSDate hoursFrom:[NSDate date] numberOfHours:1];
    [_datePicker addTarget:self action:@selector(setDate:) forControlEvents:UIControlEventValueChanged];
    
    self.startTimeTextField.inputView = _datePicker;
    self.endTimeTextField.inputView = _datePicker;
    self.startTimeTextField.tag = CTLStartTimeInputTag;
    self.endTimeTextField.tag = CTLEndTimeInputTag;
    
    self.titleTextField.placeholder     = NSLocalizedString(@"APPOINTMENT_TITLE", nil);
    self.startTimeTextField.placeholder = NSLocalizedString(@"START_TIME", nil);
    self.endTimeTextField.placeholder   = NSLocalizedString(@"END_TIME", nil);
    self.notesTextField.placeholder     = NSLocalizedString(@"APPOINTMENT_NOTES", nil);
    
    self.addressTextField.placeholder   = NSLocalizedString(@"address", nil);
    self.cityTextField.placeholder      = NSLocalizedString(@"City", nil);
    self.stateTextField.placeholder     = NSLocalizedString(@"State", nil);
    self.zipTextField.placeholder       = NSLocalizedString(@"ZIP", nil);
}

- (void)displayPermissionPrompt
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 40.0f;
    }
    
    return 30.0f;
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
    
    if(section == 0){
        [headerView setFrame:CGRectMake(0, 10.0f, width, 40.0f)];
        headerLabel.text = NSLocalizedString(@"APPOINTMENT_INFO", nil);
    }
    
    //Address Section
    if(section == 1){
        [headerLabel setFrame:CGRectMake(30.0f, 0, width, 20.0f)];
        UIImageView *pinImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"06-map-pin.png"]];
        pinImage.frame = CGRectMake(10.0f, 3.0f, 11.0f, 19.0f);
        headerLabel.text = NSLocalizedString(@"APPOINTMENT_LOCATION", nil);
        [UILabel autoWidth:headerLabel];
        
        UILabel *optionalLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerLabel.frame.size.width+35.0f, 0, width, 20.0f)];
        optionalLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
        optionalLabel.backgroundColor = [UIColor clearColor];
        optionalLabel.text = NSLocalizedString(@"PARENS_OPTIONAL", nil);
        optionalLabel.textColor = [UIColor darkGrayColor];
        [UILabel autoWidth:optionalLabel];

        [headerView addSubview:pinImage];
        [headerView addSubview:optionalLabel];
    }
    
    [headerView addSubview:headerLabel];

    return headerView;
}

#pragma mark - Set Data

- (IBAction)showDatePicker:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self highlightTextField:textField];
    
    if(_activeInputTag == CTLStartTimeInputTag){
        if([textField.text length] == 0){
            textField.text = [NSDate formatDateAndTime:_datePicker.date];
        }
        if(_appointment.startDate){
            _datePicker.date = _appointment.startDate;
        }else{
            _appointment.startDate = _datePicker.date;
        }
    }
    
    if(_activeInputTag == CTLEndTimeInputTag){
        if([textField.text length] == 0){
            if(_appointment.startDate){
                _datePicker.date = [NSDate hoursFrom:_appointment.startDate numberOfHours:1];
            }
            textField.text = [NSDate formatDateAndTime:_datePicker.date];
        }
        if(_appointment.endDate){
            _datePicker.date = _appointment.endDate;
        }else{
            _appointment.endDate = _datePicker.date;
        }
    }
}

- (void)setDate:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if(_activeInputTag == CTLStartTimeInputTag || _activeInputTag == CTLEndTimeInputTag){
        UITextField *textField = (UITextField *)[self.view viewWithTag:_activeInputTag];
        textField.text = [NSDate formatDateAndTime:[_datePicker date]];
        
        if(_activeInputTag == CTLStartTimeInputTag){
            _appointment.startDate = [_datePicker date];
            self.cdAppointment.startDate = [_datePicker date];
            if(_appointment.endDate){
                //do not allow endDate to be before startDate
                if([_appointment.endDate compare:_appointment.startDate] == NSOrderedAscending){
                    NSDate *endDate = [NSDate hoursFrom:_appointment.startDate numberOfHours:1];
                    self.endTimeTextField.text = [NSDate formatDateAndTime:endDate];
                    _appointment.endDate = endDate;
                    self.cdAppointment.endDate = endDate;
                }
            }
        }
        
        if(_activeInputTag == CTLEndTimeInputTag){
            _appointment.endDate = [_datePicker date];
            if(_appointment.startDate){
                //do not allow endDate to be before startDate
                if([_appointment.startDate compare:_appointment.endDate] == NSOrderedDescending){
                    NSDate *startDate = [NSDate hoursBefore:_appointment.endDate numberOfHours:1];
                    self.startTimeTextField.text = [NSDate formatDateAndTime:startDate];
                    _appointment.startDate = startDate;
                    self.cdAppointment.startDate = startDate;
                }
            }
        }
    }
    
}

- (BOOL)validateAppointment
{
    BOOL isValid = YES;
    UIColor *errorColor = [UIColor ctlInputErrorBackground];
    
    if([self.titleTextField.text length] == 0){
        [self.titleTextField setBackgroundColor:errorColor];
        isValid = NO;
    }
    
    if(!_appointment.startDate){
        [self.startTimeTextField setBackgroundColor:errorColor];
        isValid = NO;
    }
    
    if(!_appointment.endDate){
        [self.endTimeTextField setBackgroundColor:errorColor];
        isValid = NO;
    }
    
    return isValid;
}

- (EKCalendar *)createCalendar
{
    //get local calendar source (device calendar. not imap)
    EKSource *localSource = nil;
    for (EKSource *source in _eventStore.sources) {
        if (source.sourceType == EKSourceTypeLocal) {
            localSource = source;
            break;
        }
    }
    //create a calendar to store app-created reminders
    EKCalendar *localCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:_eventStore];
    localCalendar.title = NSLocalizedString(@"CALENDAR", nil);
    localCalendar.source = localSource;
    [_eventStore saveCalendar:localCalendar commit:YES error:nil];
    return localCalendar;
}

- (IBAction)saveAppointment:(id)sender
{
    if(!_hasCalendarAccess){
        [self displayPermissionPrompt];
        return;
    }
    
    if(![self validateAppointment]){
        return;
    }
    
    _appointment.title = self.titleTextField.text;
    _appointment.notes = self.notesTextField.text;
    
    self.cdAppointment.title = self.titleTextField.text;
    //self.cdAppointment.startDate = _appointment.startDate;
    //self.cdAppointment.endDate = _appointment.endDate;
    
    if([self.notesTextField.text length] > 0){
        self.cdAppointment.notes = self.notesTextField.text;
    }
    
    if([self.addressTextField.text length] > 0){
        self.cdAppointment.address = self.addressTextField.text;
    }
    
    if([self.cityTextField.text length] > 0){
        self.cdAppointment.city = self.cityTextField.text;
    }
    
    if([self.stateTextField.text length] > 0){
        self.cdAppointment.state = self.stateTextField.text;
    }
    
    if([self.zipTextField.text length] > 0){
        self.cdAppointment.address = self.zipTextField.text;
    }
    
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
    
    [self.cdAppointment setHasAddressValue:[self hasAddress]];
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
    notification.fireDate = [itemDate dateByAddingTimeInterval:-(minutesBefore*60)];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"APPOINTMENT", nil), item.title];
    notification.alertAction = NSLocalizedString(@"VIEW_APPOINTMENT", nil);
    
    notification.userInfo = @{@"navigationController":@"appointmentsNavigationController", @"viewController":@"appointmentFormViewController", @"eventID":item.eventIdentifier};
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (BOOL)hasAddress
{
    if([self.addressTextField.text length] > 0 ||
       [self.cityTextField.text length] > 0 ||
       [self.stateTextField.text length] > 0 ||
       [self.zipTextField.text length] > 0){
        return YES;
    }
    
    return NO;
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

#pragma CTLFieldCellDelegate

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (IBAction)highlightTextField:(UITextField *)textField
{
    [self.focusedTextField setBackgroundColor:[UIColor clearColor]];
    [textField setBackgroundColor:[UIColor ctlFadedGray]];
    self.focusedTextField = textField;
    _activeInputTag = textField.tag;
}

- (void)dismissInputViews:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    [self.focusedTextField setBackgroundColor:[UIColor clearColor]];
}

@end
