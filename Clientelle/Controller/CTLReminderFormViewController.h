//
//  CTLReminderFormViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 4/4/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "CTLFieldCell.h"

@class CTLCDReminder;

@interface CTLReminderFormViewController : UITableViewController<CTLFieldCellDelegate>{
    UIDatePicker *_datePicker;
    NSInteger _activeInputTag;
    EKReminder *_reminder;
    EKEventStore *_eventStore;
    BOOL _hasCalendarAccess;
    EKCalendar *_reminderCalendar;
    NSArray *_fields;
}

@property (nonatomic, assign) BOOL isPresentedAsModal;
@property (nonatomic, strong) CTLCDReminder *cdReminder;

@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UITextField *dueTimeTextField;

/* CTLFieldCellDelegate */
@property (nonatomic, weak) UITextField *focusedTextField;
- (IBAction)highlightTextField:(UITextField *)textField;
- (IBAction)textFieldDidChange:(UITextField *)textField;

- (IBAction)showDatePicker:(id)sender;
- (IBAction)saveReminder:(id)sender;

@end
