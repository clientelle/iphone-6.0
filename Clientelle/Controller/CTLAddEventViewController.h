//
//  CTLAddEventViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/9/13.
//  Copyright (c) 2013 Clientelle Leads LLC. All rights reserved.
//

#import <EventKit/EventKit.h>

@class CTLABPerson;
@class CTLCDAppointment;

@interface CTLAddEventViewController : UITableViewController<UITextFieldDelegate, UIGestureRecognizerDelegate>{
    UIDatePicker *_datePicker;
    NSInteger _activeInputTag;
    EKEvent *_appointment;
    EKEventStore *_eventStore;
    UITextField *_focusedTextField;
    BOOL _hasCalendarAccess;
}

@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UITextField *locationTextField;
@property (nonatomic, weak) IBOutlet UITextField *startTimeTextField;
@property (nonatomic, weak) IBOutlet UITextField *endTimeTextField;

@property (nonatomic, strong) CTLCDAppointment *cdAppointment;
@property (nonatomic, strong) CTLABPerson *contact;

- (IBAction)highlightTextField:(id)sender;
- (IBAction)saveTitle:(id)sender;
- (IBAction)saveLocation:(id)sender;
- (IBAction)showDatePicker:(id)sender;
- (IBAction)saveAppointment:(id)sender;

@end
