//
//  CTLAddEventViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/9/13.
//  Copyright (c) 2013 Clientelle Leads LLC. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "CTLFieldCell.h"

@class CTLCDPerson;
@class CTLCDAppointment;

@interface CTLAppointmentFormViewController : UITableViewController<CTLFieldCellDelegate, CTLSlideMenuDelegate>{
    UIDatePicker *_datePicker;
    NSInteger _activeInputTag;
    EKEvent *_appointment;
    EKEventStore *_eventStore;
    BOOL _hasCalendarAccess;
    NSArray *_fields;
    BOOL _hasAddress;
    EKCalendar *_calendar;
}

/* CTLFieldCellDelegate */
@property (nonatomic, weak) UITextField *focusedTextField;
- (IBAction)highlightTextField:(UITextField *)textField;
- (IBAction)textFieldDidChange:(UITextField *)textField;

@property (nonatomic, weak) CTLSlideMenuController *menuController;

@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UITextField *startTimeTextField;
@property (nonatomic, weak) IBOutlet UITextField *endTimeTextField;
@property (nonatomic, weak) IBOutlet UITextField *notesTextField;

@property (nonatomic, weak) IBOutlet UITextField *addressTextField;
@property (nonatomic, weak) IBOutlet UITextField *cityTextField;
@property (nonatomic, weak) IBOutlet UITextField *stateTextField;
@property (nonatomic, weak) IBOutlet UITextField *zipTextField;

@property (nonatomic, assign) BOOL presentedAsModal;
@property (nonatomic, assign) BOOL transitionedFromLocalNotification;

@property (nonatomic, strong) CTLCDAppointment *cdAppointment;
@property (nonatomic, strong) CTLCDPerson *contact;

- (IBAction)showDatePicker:(id)sender;
- (IBAction)saveAppointment:(id)sender;
- (void)dismiss:(id)sender;

@end
