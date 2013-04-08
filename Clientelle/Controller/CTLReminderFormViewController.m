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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self configureInputs];
    [self checkPermission];
    
    [self.titleTextField becomeFirstResponder];
    
    //IB tags -> Core Data mapping
    _fields = @[@"", @"title", @"dueDate"];
    
    if(self.isPresentedAsModal){
        self.navigationItem.title = NSLocalizedString(@"CREATE_REMINDER", nil);
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }else{
        self.navigationItem.title = NSLocalizedString(@"EDIT_REMINDER", nil);
    }
    
    if(!self.cdReminder){
        self.cdReminder = [CTLCDReminder MR_createEntity];
        _reminder = [EKReminder reminderWithEventStore:_eventStore];
        _reminder.calendar = [_eventStore defaultCalendarForNewReminders];
        [self.cdReminder setEventID:_reminder.calendarItemIdentifier];
    }else{
        _reminder = (EKReminder *)[_eventStore calendarItemWithIdentifier:[self.cdReminder eventID]];
        if(_reminder){
            self.titleTextField.text = _reminder.title;
            NSDate *dueDate = [NSDate dateFromComponents:_reminder.dueDateComponents];
            self.dueTimeTextField.text = [NSDate formatDateAndTime:dueDate];
        }
    }
}
/*
- (EKCalendar *)createReminderCalendar
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
    EKCalendar *localCalendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:_eventStore];
    localCalendar.title = @"Clientelle";
    localCalendar.source = localSource;

    [_eventStore saveCalendar:localCalendar commit:YES error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:localCalendar.calendarIdentifier forKey:CTLCalendarIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return localCalendar;
}
*/

- (void)checkPermission
{
    _hasCalendarAccess = NO;
    _eventStore = [[EKEventStore alloc] init];
    
    EKAuthorizationStatus EKAuthStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    if(EKAuthStatus == EKAuthorizationStatusNotDetermined){
        [_eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
            if(granted){
                _hasCalendarAccess = YES;
                //[self setupReminderCalendar];
            } else {
                [self displayPermissionPrompt];
            }
        }];
    } else if(EKAuthStatus == EKAuthorizationStatusAuthorized){
        _hasCalendarAccess = YES;
        //[self setupReminderCalendar];
    } else {
        [self displayPermissionPrompt];
    }
}

/*
- (void)setupReminderCalendar
{
    NSString *calendarID = [[NSUserDefaults standardUserDefaults] stringForKey:CTLCalendarIDKey];
    if(calendarID){
        _reminderCalendar = [_eventStore calendarWithIdentifier:calendarID];
        if(!_reminderCalendar){
            _reminderCalendar = [self createReminderCalendar];
        }
    }else{
        _reminderCalendar = [self createReminderCalendar];
    }
}
 */

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
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    _datePicker.date = [NSDate hoursFrom:[NSDate date] numberOfHours:1];
    [_datePicker addTarget:self action:@selector(setDate:) forControlEvents:UIControlEventValueChanged];
    
    self.dueTimeTextField.inputView = _datePicker;
    self.titleTextField.placeholder = NSLocalizedString(@"APPOINTMENT_TITLE", nil);

}

- (NSDateComponents *)dateComponentsFromDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate: date];
    return components;
}

- (void)setDate:(id)sender
{
    UITextField *textField = (UITextField *)[self.view viewWithTag:_activeInputTag];
    textField.text = [NSDate formatDateAndTime:[_datePicker date]];
    _reminder.dueDateComponents = [self dateComponentsFromDate:_datePicker.date];
    self.cdReminder.dueDate = _datePicker.date;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell addShadowToCellInTableView:self.tableView atIndexPath:indexPath];
    return cell;
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
            EKAlarm *firstReminder = [EKAlarm alarmWithRelativeOffset:-900.0f];
            EKAlarm *secondReminder = [EKAlarm alarmWithRelativeOffset:-300.0f];
            _reminder.alarms = @[firstReminder, secondReminder];
        }
    }
    if(_reminder.dueDateComponents){
        _reminder.dueDateComponents = [self dateComponentsFromDate:_datePicker.date];
        _datePicker.date = [NSDate dateFromComponents:_reminder.dueDateComponents];
    }
}

- (BOOL)validateReminder:(EKReminder *)reminder
{
    BOOL isValid = YES;
    UIColor *errorColor = [UIColor ctlInputErrorBackground];
    
    if([reminder.title length] == 0){
        [self.titleTextField setBackgroundColor:errorColor];
        isValid = NO;
    }
    
    if(!reminder.dueDateComponents){
        [self.dueTimeTextField setBackgroundColor:errorColor];
        isValid = NO;
    }

    return isValid;
}

- (IBAction)saveReminder:(id)sender
{
    if(!_hasCalendarAccess){
        [self displayPermissionPrompt];
        return;
    }
    
    if(![self validateReminder:_reminder]){
        return;
    }
 
    [_reminder addAlarm:[EKAlarm alarmWithRelativeOffset:-900.0f]]; //15 min before
    [_reminder addAlarm:[EKAlarm alarmWithRelativeOffset:-300.0f]]; //5 min before
    [_reminder addAlarm:[EKAlarm alarmWithAbsoluteDate:_datePicker.date]];
    
    NSError *error = nil;
    BOOL result = [_eventStore saveReminder:_reminder commit:YES error:&error];
    
    if(result){
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        [[NSNotificationCenter defaultCenter] postNotificationName:CTLReloadRemindersNotification object:nil];
    }else{
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:[error description]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil, nil];
        [errorAlert show];
    }
    
    [self resetForm];
    
    if(self.isPresentedAsModal){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma CTLFieldCellDelegate

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    NSString *field = _fields[textField.tag];
    if([field isEqualToString:@"title"]){
        [_reminder setValue:textField.text forKey:field];
        [self.cdReminder setValue:textField.text forKey:field];
    }
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
