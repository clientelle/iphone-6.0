//
//  CTLReminderFormViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 4/4/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//
#import "UIColor+CTLColor.h"
#import "NSDate+CTLDate.h"
#import "CTLCDReminder.h"

#import "CTLRemindersListViewController.h"
#import "CTLReminderFormViewController.h"
#import "CTLCellBackground.h"
#import "UITableViewCell+CellShadows.h"
#import "CTLViewDecorator.h"

NSString *const CTLCalendarIDKey = @"com.clientelle.com.userDefaultsKey.calendarName";

@implementation CTLReminderFormViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureInputs];
    [self checkPermission];
    
    //IB tags -> Core Data mapping
    _fields = @[@"", @"title", @"dueDate"];
    
    if(!self.cdReminder){
        
        self.navigationItem.title = NSLocalizedString(@"CREATE_REMINDER", nil);
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        _reminder = [EKReminder reminderWithEventStore:_eventStore];
        _reminder.calendar = [_eventStore defaultCalendarForNewReminders];
        self.cdReminder = [CTLCDReminder MR_createEntity];
        [self.cdReminder setEventID:_reminder.calendarItemIdentifier];
    }else{
        
        self.navigationItem.title = NSLocalizedString(@"EDIT_REMINDER", nil);
        
        _reminder = (EKReminder *)[_eventStore calendarItemWithIdentifier:[self.cdReminder eventID]];
        if(_reminder){
            self.titleTextField.text = _reminder.title;
            NSDate *dueDate = [NSDate dateFromComponents:_reminder.dueDateComponents];
            self.dueTimeTextField.text = [NSDate formatDateAndTime:dueDate];
            [_datePicker setDate:dueDate];
        }else{
            self.titleTextField.text = self.cdReminder.title;
            self.dueTimeTextField.text = [NSDate formatDateAndTime:self.cdReminder.dueDate];
            [_datePicker setDate:self.cdReminder.dueDate];
            
            _reminder = [EKReminder reminderWithEventStore:_eventStore];
            _reminder.title = self.cdReminder.title;
            _reminder.calendar = [_eventStore defaultCalendarForNewReminders];
            _reminder.dueDateComponents = [self dateComponentsFromDate:self.cdReminder.dueDate];
        }
    }
}

- (void)checkPermission
{
    _hasCalendarAccess = NO;
    _eventStore = [[EKEventStore alloc] init];
    
    EKAuthorizationStatus EKAuthStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    if(EKAuthStatus == EKAuthorizationStatusNotDetermined){
        [_eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
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

- (void)displayPermissionPrompt
{
    UIAlertView *requirePermission = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REQUIRES_ACCESS_TO_CALENDARS", nil)
                                                                message:NSLocalizedString(@"GO_TO_SETTINGS_CALENDARS", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
    [requirePermission show];
}

- (void)configureInputs
{
    self.titleTextField.placeholder = NSLocalizedString(@"APPOINTMENT_TITLE", nil);
    
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
//_datePicker.date = [NSDate hoursFrom:[NSDate date] numberOfHours:1];
    
    _datePicker.date = [NSDate date];
    
    [_datePicker addTarget:self action:@selector(setDate:) forControlEvents:UIControlEventValueChanged];
    
    self.dueTimeTextField.inputView = _datePicker;
}

- (NSDateComponents *)dateComponentsFromDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate: date];
    return components;
}

- (void)setDate:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    UITextField *textField = (UITextField *)[self.view viewWithTag:_activeInputTag];
    textField.text = [NSDate formatDateAndTime:[_datePicker date]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell addShadowToCellInTableView:self.tableView atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(!self.transitionedFromLocalNotification){
        return 0.0f;
    }
    
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(!self.transitionedFromLocalNotification){
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
    
    UIImage *buttonImage = [[UIImage imageNamed:@"whiteButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // Set the background for any states you plan to use
    [addButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [addButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [addButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0f]];
    [addButton addTarget:self action:@selector(markAsCompleted:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTitle:NSLocalizedString(@"MARK_AS_COMPLETED", nil) forState:UIControlStateNormal];
    
    addButton.layer.shadowOpacity = 0.2f;
    addButton.layer.shadowRadius = 1.0f;
    addButton.layer.shadowOffset = CGSizeMake(0,0);
    
    [footerView addSubview:addButton];
    return footerView;
}

- (void)markAsCompleted:(id)sender
{
    [self.cdReminder setCompeleted:@(1)];
    [self.cdReminder setCompletedDate:[NSDate date]];
    [self saveReminder:sender];
}

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
    [self.dueTimeTextField setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)showDatePicker:(UITextField *)textField
{
    [self highlightTextField:textField];

    if([self.dueTimeTextField.text length] == 0){
        self.dueTimeTextField.text = [NSDate formatDateAndTime:_datePicker.date];
        if(!_reminder.dueDateComponents){
            _reminder.dueDateComponents = [self dateComponentsFromDate:_datePicker.date];
            [self.cdReminder setDueDate:_datePicker.date];
            [_reminder addAlarm:[EKAlarm alarmWithRelativeOffset:-900.0f]];
            [_reminder addAlarm:[EKAlarm alarmWithRelativeOffset:-300.0f]];
        }
    }
    if(_reminder.dueDateComponents){
        _reminder.dueDateComponents = [self dateComponentsFromDate:_datePicker.date];
        _datePicker.date = [NSDate dateFromComponents:_reminder.dueDateComponents];
    }
}

- (BOOL)validateReminder
{
    UIColor *errorColor = [UIColor ctlInputErrorBackground];
    
    if([self.titleTextField.text length] == 0){
        [self.titleTextField setBackgroundColor:errorColor];
        return NO;
    }
    
    if([self.dueTimeTextField.text length] == 0){
        [self.dueTimeTextField setBackgroundColor:errorColor];
        return NO;
    }

    return YES;
}

- (IBAction)saveReminder:(id)sender
{
    if(!_hasCalendarAccess){
        [self displayPermissionPrompt];
        return;
    }
    
    if(![self validateReminder]){
        return;
    }
    
    _reminder.title = self.titleTextField.text;
    _reminder.dueDateComponents = [self dateComponentsFromDate:_datePicker.date];

    self.cdReminder.title = self.titleTextField.text;
    self.cdReminder.dueDate = _datePicker.date;

    if([_datePicker.date compare:[NSDate date]] == NSOrderedAscending || [sender isKindOfClass:[UIButton class]]){
        //date is in the past. look for old notifs that need to be cleared out
        [self cancelLocalNotification:_reminder.calendarItemIdentifier];
    }else{
        //[_reminder addAlarm:[EKAlarm alarmWithRelativeOffset:-900.0f]]; //15 min before
        //[_reminder addAlarm:[EKAlarm alarmWithRelativeOffset:-300.0f]]; //5 min before
        //[_reminder addAlarm:[EKAlarm alarmWithAbsoluteDate:_datePicker.date]];
        [self scheduleNotificationWithItem:_reminder interval:5];
    }
    
    NSError *error = nil;
    BOOL result = [_eventStore saveReminder:_reminder commit:YES error:&error];
    
    if(result){
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
            [[NSNotificationCenter defaultCenter] postNotificationName:CTLReloadRemindersNotification object:nil];
        }];
    }else{
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:[error description]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil, nil];
        [errorAlert show];
    }
    
    [self dismiss:nil];
    
}

-(void)cancelLocalNotification:(NSString *)reminderEventID
{
    for (UILocalNotification *notification in [[[UIApplication sharedApplication] scheduledLocalNotifications] copy]){
        NSDictionary *userInfo = notification.userInfo;
        if ([reminderEventID isEqualToString:[userInfo objectForKey:@"reminderEventID"]]){
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

- (void)scheduleNotificationWithItem:(EKReminder *)item interval:(int)minutesBefore
{
    [self cancelLocalNotification:item.calendarItemIdentifier];
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *itemDate = [calendar dateFromComponents:item.dueDateComponents];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if (notification == nil){
        return;
    }
    
    notification.applicationIconBadgeNumber = 1;
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    //localNotif.fireDate = [itemDate dateByAddingTimeInterval:-(minutesBefore*60)];
    notification.fireDate = itemDate;
    
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"REMINDER", nil), item.title];
    notification.alertAction = NSLocalizedString(@"VIEW_REMINDER", nil);
 
    notification.userInfo = @{@"navigationController":@"remindersNavigationController", @"viewController":@"reminderFormViewController", @"reminderEventID":item.calendarItemIdentifier};
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
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
