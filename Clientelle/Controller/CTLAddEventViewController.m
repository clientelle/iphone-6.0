//
//  CTLAddEventViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/9/13.
//  Copyright (c) 2013 Clientelle Leads LLC. All rights reserved.
//

#import "UIColor+CTLColor.h"
#import "NSDate+CTLDate.h"
#import "CTLABPerson.h"
#import "CTLABGroup.h"
#import "CTLCDPerson.h"
#import "CTLAddEventViewController.h"
#import "CTLContactsListViewController.h"
#import "CTLAppointmentsViewController.h"

#import "CTLCDAppointment.h"
#import "CTLCellBackground.h"
#import "UITableViewCell+CellShadows.h"
#import "CTLViewDecorator.h"

int CTLStartTimeInputTag = 18;
int CTLEndTimeInputTag = 81;

@implementation CTLAddEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"SET_APPOINTMENT", nil);
    self.titleTextField.placeholder = NSLocalizedString(@"APPOINTMENT_NOTE", nil);
    self.startTimeTextField.placeholder = NSLocalizedString(@"START_TIME", nil);
    self.endTimeTextField.placeholder = NSLocalizedString(@"END_TIME", nil);
    self.locationTextField.placeholder = NSLocalizedString(@"LOCATION", nil);
    
    _hasCalendarAccess = NO;
    
    _eventStore = [[EKEventStore alloc] init];
    
    
    EKAuthorizationStatus EKAuthStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    if(EKAuthStatus == EKAuthorizationStatusNotDetermined){
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if(granted){
                NSLog(@"first time access");
                _hasCalendarAccess = YES;
            } else {
                [self displayPermissionPrompt];
            }
        }];
    } else if(EKAuthStatus == EKAuthorizationStatusAuthorized){
        NSLog(@"i has access");
        _hasCalendarAccess = YES;
    } else {
        [self displayPermissionPrompt];
    }
    
    //segued from an appointment row
    if(self.cdAppointment){
        _appointment = [_eventStore eventWithIdentifier:[self.cdAppointment eventID]];
        if(_appointment){
            self.titleTextField.text = _appointment.title;
            self.startTimeTextField.text = [NSDate dateToString:_appointment.startDate];
            self.endTimeTextField.text = [NSDate dateToString:_appointment.endDate];
            self.locationTextField.text = _appointment.location;
        }
    }else{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        _appointment = [EKEvent eventWithEventStore:_eventStore];
        _appointment.calendar = [_eventStore defaultCalendarForNewEvents];
        [self.titleTextField becomeFirstResponder];
    }
    
    if(self.contact){
        _appointment.title = [NSString stringWithFormat:NSLocalizedString(@"MEETING_WITH", nil), [self.contact compositeName]];
        self.titleTextField.text = _appointment.title;
    }
    
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    _datePicker.date = [NSDate hoursFrom:[NSDate date] numberOfHours:1];
    [_datePicker addTarget:self action:@selector(setDate:) forControlEvents:UIControlEventValueChanged];
    
    self.startTimeTextField.inputView = _datePicker;
    self.endTimeTextField.inputView = _datePicker;
    self.startTimeTextField.tag = CTLStartTimeInputTag;
    self.endTimeTextField.tag = CTLEndTimeInputTag;
    
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissInputViews:)]];
    
    /*** GENERATE FAKE APPOINTMENTS ***/
    /*
    [self createAppointmentsForMonth:[NSDate monthsAgo:1]];
    [self createAppointmentsForMonth:[NSDate date]];
    [self createAppointmentsForMonth:[NSDate monthsFromNow:1]];
     
    [[NSNotificationCenter defaultCenter] postNotificationName:CTLReloadAppointmentsNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
    */
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(self.cdAppointment){
        return 50.0f;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(!self.cdAppointment){
        return nil;
    }
    
    CGRect viewFrame = self.view.frame;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, 50.0f)];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGRect buttonFrame = addButton.frame;
    buttonFrame.size.height = 35.0f;
    buttonFrame.size.width = viewFrame.size.width - 20.0f;
    buttonFrame.origin.y += 10.0f;
    buttonFrame.origin.x += 10.0f;
    [addButton setFrame:buttonFrame];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"redButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"redButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // Set the background for any states you plan to use
    [addButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [addButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    [addButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0f]];
    [addButton addTarget:self action:@selector(confirmDelete:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTitle:NSLocalizedString(@"DELETE_APPOINTMENT", nil) forState:UIControlStateNormal];
    
    addButton.layer.shadowOpacity = 0.2f;
    addButton.layer.shadowRadius = 1.0f;
    addButton.layer.shadowOffset = CGSizeMake(0,0);
    
 
    [footerView addSubview:addButton];
    return footerView;
}

#pragma mark - Calendar PickerView

- (void)showPicker:(UIView *)pickerView {
    
    [self.view endEditing:YES];
    [self.view addSubview:pickerView];
     
    CGRect pickerFrame = pickerView.frame;
    CGFloat totalHeight = CGRectGetHeight(self.view.bounds);
    pickerFrame.origin.y = totalHeight;
    [pickerView setFrame:pickerFrame];
    pickerFrame.origin.y = totalHeight - CGRectGetHeight(pickerFrame);
    
    [UIView animateWithDuration:0.3 animations:^{
        pickerView.frame = pickerFrame;
    }];
}

- (void)hidePicker:(UIView *)pickerView
{
    CGFloat totalHeight = CGRectGetHeight(self.view.bounds);
    CGRect dateFrame = pickerView.frame;
    dateFrame.origin.y = totalHeight;
        
    [UIView animateWithDuration:0.3 animations:^{
        pickerView.frame = dateFrame;
    } completion:^(BOOL finished){
        if(finished){
            [pickerView removeFromSuperview];
        }
    }];
}

- (void)dismissInputViews:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    [self hidePicker:_datePicker];
    [_focusedTextField setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Set Data

- (IBAction)showDatePicker:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    _activeInputTag = textField.tag;

    if(_activeInputTag == CTLStartTimeInputTag){
        if([self.startTimeTextField.text length] == 0){
            self.startTimeTextField.text = [NSDate dateToString:_datePicker.date];
            if(!_appointment.startDate){
                _appointment.startDate = _datePicker.date;
                EKAlarm *firstReminder = [EKAlarm alarmWithRelativeOffset:-900.0f];
                EKAlarm *secondReminder = [EKAlarm alarmWithRelativeOffset:-300.0f];
                _appointment.alarms = @[firstReminder, secondReminder];
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
            }
            self.endTimeTextField.text = [NSDate dateToString:_datePicker.date];
        }
        if(_appointment.endDate){
            _datePicker.date = _appointment.endDate;
        }
    }
}

- (IBAction)highlightTextField:(id)sender
{
    [_focusedTextField setBackgroundColor:[UIColor clearColor]];
    UITextField *textField = (UITextField *)sender;
    [textField setBackgroundColor:[UIColor ctlFadedGray]];
    _focusedTextField = textField;
}

- (IBAction)saveTitle:(id)sender
{
    _appointment.title = self.titleTextField.text;
}

- (IBAction)saveLocation:(id)sender
{
    _appointment.location = self.locationTextField.text;
}

- (void)setDate:(id)sender
{
    if(_activeInputTag == CTLStartTimeInputTag || _activeInputTag == CTLEndTimeInputTag){
        UITextField *textField = (UITextField *)[self.view viewWithTag:_activeInputTag];
        textField.text = [NSDate dateToString:[_datePicker date]];
        
        if(_activeInputTag == CTLStartTimeInputTag){
            _appointment.startDate = [_datePicker date];
            if(_appointment.endDate){
                //do not allow endDate to be before startDate
                if([_appointment.endDate compare:_appointment.startDate] == NSOrderedAscending) {
                    _appointment.endDate = [NSDate hoursFrom:_appointment.startDate numberOfHours:1];
                    self.endTimeTextField.text = [NSDate dateToString:_appointment.endDate];
                }
            }
        }
        
        if(_activeInputTag == CTLEndTimeInputTag){
            _appointment.endDate = [_datePicker date];
            if(_appointment.startDate){
                //do not allow endDate to be before startDate
                if([_appointment.startDate compare:_appointment.endDate] == NSOrderedDescending) {
                    _appointment.startDate = [NSDate hoursBefore:_appointment.endDate numberOfHours:1];
                    self.startTimeTextField.text = [NSDate dateToString:_appointment.startDate];
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

    if(!self.cdAppointment){
        CTLCDAppointment *appointment = [CTLCDAppointment MR_createEntity];
        appointment.eventID = _appointment.eventIdentifier;
        appointment.title = _appointment.title;
        appointment.startDate = _appointment.startDate;
        appointment.endDate = _appointment.endDate;
        appointment.location = _appointment.location;
    }else{
        self.cdAppointment.title = _appointment.title;
        self.cdAppointment.startDate = _appointment.startDate;
        self.cdAppointment.endDate = _appointment.endDate;
        self.cdAppointment.location = _appointment.location;
    }
            
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:CTLReloadAppointmentsNotification object:nil];
    
    [self resetForm];
    if(self.contact){
        [[NSNotificationCenter defaultCenter] postNotificationName:CTLTimestampForRowNotification object:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
