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
    
    if(self.isPresentedAsModal){
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    [self configureInputs];
    [self checkPermission];
    
    //IB tags -> Core Data mapping
    _fields = @[@"", @"title", @"startDate", @"endDate", @"notes", @"address", @"city",  @"state", @"zip"];
    
    if(!self.cdAppointment){
        self.cdAppointment = [CTLCDAppointment MR_createEntity];
        _appointment = [EKEvent eventWithEventStore:_eventStore];
        _appointment.calendar = [_eventStore defaultCalendarForNewEvents];
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
    _hasCalendarAccess = NO;
    _eventStore = [[EKEventStore alloc] init];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0 || [_appointment eventIdentifier] == nil){
        return 0;
    }

    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section == 0 || [_appointment eventIdentifier] == nil){
        return nil;
    }
    
    CGFloat buttonHeight = 30.0f;
    CGFloat buttonWidth = 60.0f;
    CGFloat labelWidth = 100.0f;
    CGFloat buttonPositionX = self.view.bounds.size.width/2 - buttonWidth/2;
    CGFloat labelPositionX = self.view.bounds.size.width/2 - labelWidth/2;
    
    UILabel *dashesLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelPositionX, 5, labelWidth, buttonHeight)];
    dashesLabel.backgroundColor = [UIColor clearColor];
    dashesLabel.textAlignment = NSTextAlignmentCenter;
    dashesLabel.text = @"-       -";
    
    UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonPositionX, 5, buttonWidth, buttonHeight)];
    [settingsButton setImage:[UIImage imageNamed:@"trash-grey.png"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(confirmDelete:) forControlEvents:UIControlEventTouchUpInside];
    [settingsButton setAlpha:0.75f];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30.0f)];
    [footerView addSubview:dashesLabel];
    [footerView addSubview:settingsButton];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    return footerView;
}


#pragma mark - Set Data

- (IBAction)showDatePicker:(UITextField *)textField
{
    [self highlightTextField:textField];

    if(_activeInputTag == CTLStartTimeInputTag){
        if([self.startTimeTextField.text length] == 0){
            self.startTimeTextField.text = [NSDate formatDateAndTime:_datePicker.date];
            if(!_appointment.startDate){
                _appointment.startDate = _datePicker.date;
                [self.cdAppointment setStartDate:_datePicker.date];
                [_appointment addAlarm:[EKAlarm alarmWithRelativeOffset:-900.0f]]; //15 min before
                [_appointment addAlarm:[EKAlarm alarmWithRelativeOffset:-300.0f]]; //5 min before
                [_appointment addAlarm:[EKAlarm alarmWithAbsoluteDate:_datePicker.date]];
            }
        }
        if(_appointment.startDate){
            _datePicker.date = _appointment.startDate;
        }
    }
    
    if(_activeInputTag == CTLEndTimeInputTag){
        if([self.endTimeTextField.text length] == 0){
            if(_appointment.startDate){
                _datePicker.date = [NSDate hoursFrom:_appointment.startDate numberOfHours:1];
            }
            if(!_appointment.endDate){
                _appointment.endDate = _datePicker.date;
                [self.cdAppointment setEndDate:_datePicker.date];
            }
            self.endTimeTextField.text = [NSDate formatDateAndTime:_datePicker.date];
        }
        if(_appointment.endDate){
            _datePicker.date = _appointment.endDate;
        }
    }
}

- (void)setDate:(id)sender
{
    if(_activeInputTag == CTLStartTimeInputTag || _activeInputTag == CTLEndTimeInputTag){
        UITextField *textField = (UITextField *)[self.view viewWithTag:_activeInputTag];
        textField.text = [NSDate formatDateAndTime:[_datePicker date]];
        
        if(_activeInputTag == CTLStartTimeInputTag){
            _appointment.startDate = [_datePicker date];
            if(_appointment.endDate){
                //do not allow endDate to be before startDate
                if([_appointment.endDate compare:_appointment.startDate] == NSOrderedAscending){
                    NSDate *endDate = [NSDate hoursFrom:_appointment.startDate numberOfHours:1];
                    _appointment.endDate = endDate;
                    [self.cdAppointment setEndDate:endDate];
                    self.endTimeTextField.text = [NSDate formatDateAndTime:_appointment.endDate];
                }
            }
        }
        
        if(_activeInputTag == CTLEndTimeInputTag){
            _appointment.endDate = [_datePicker date];
            if(_appointment.startDate){
                //do not allow endDate to be before startDate
                if([_appointment.startDate compare:_appointment.endDate] == NSOrderedDescending){
                    NSDate *startDate = [NSDate hoursBefore:_appointment.endDate numberOfHours:1];
                    _appointment.startDate = startDate;
                    [self.cdAppointment setStartDate:startDate];
                    self.startTimeTextField.text = [NSDate formatDateAndTime:_appointment.startDate];
                }
            }
        }
    }
    
}

- (BOOL)validateAppointment:(EKEvent *)appointment
{
    BOOL isValid = YES;
    UIColor *errorColor = [UIColor ctlInputErrorBackground];
    
    if([appointment.title length] == 0){
        [self.titleTextField setBackgroundColor:errorColor];
        isValid = NO;
    }
    
    if(!appointment.startDate){
        [self.startTimeTextField setBackgroundColor:errorColor];
        isValid = NO;
    }
    
    if(!appointment.endDate){
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

- (void)confirmDelete:(id)sender
{
    UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:nil
                                                           message:NSLocalizedString(@"CONFIRM_DELETE_APPOINTMENT", NIL)
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                 otherButtonTitles:@"OK", nil];
    [confirmAlert show];
}

- (void)deleteAppointment:(id)sender
{
    NSString *eventID = [self.cdAppointment eventID];
    [self.cdAppointment MR_deleteEntity];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
        if(eventID){
            NSError *error = nil;
            [_eventStore removeEvent:_appointment span:EKSpanThisEvent commit:YES error:&error];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CTLReloadAppointmentsNotification object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [self deleteAppointment:alertView];
    }
}

- (IBAction)saveAppointment:(id)sender
{
    if(!_hasCalendarAccess){
        [self displayPermissionPrompt];
        return;
    }
    
    if(![self validateAppointment:_appointment]){
        return;
    }
    
    EKCalendar *defaultCalendar = [_eventStore defaultCalendarForNewEvents];
    
    if(defaultCalendar){
        NSError *error = nil;
        [_appointment setCalendar:defaultCalendar];
        [_eventStore saveEvent:_appointment span:EKSpanThisEvent commit:YES error:&error];
    }
    
    if(![self.cdAppointment eventID] && _appointment.eventIdentifier != nil){
        self.cdAppointment.eventID = _appointment.eventIdentifier;
    }
    
    [self.cdAppointment setHasAddressValue:[self hasAddress]];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:CTLReloadAppointmentsNotification object:nil];
    
    [self resetForm];
    if(self.contact){
        [[NSNotificationCenter defaultCenter] postNotificationName:CTLTimestampForRowNotification object:nil];
    }
    
    if(self.isPresentedAsModal){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)addressIsEmpty
{
    if([self.addressTextField.text length] == 0 &&
       [self.cityTextField.text length] == 0 &&
       [self.stateTextField.text length] == 0 &&
       [self.zipTextField.text length] == 0){
        return YES;
    }
    
    return NO;
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

- (void)cancel:(id)sender
{
    [self resetForm];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    NSString *field = _fields[textField.tag];
    if([field isEqualToString:@"title"] || [field isEqualToString:@"notes"]){
       [_appointment setValue:textField.text forKey:field]; 
    }
    [self.cdAppointment setValue:textField.text forKey:field];
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
