//
//  CTLAddEventViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/9/13.
//  Copyright (c) 2013 Clientelle Leads LLC. All rights reserved.
//

#import <EventKit/EventKit.h>

@class CTLABPerson;
@class CTLEvent;

@interface CTLAddEventViewController : UITableViewController<UITextFieldDelegate, UIGestureRecognizerDelegate>{
    UIDatePicker *_datePicker;
    NSInteger _activeInputTag;
    EKEvent *_appointment;
    CTLEvent *_event;
    UITextField *_focusedTextField;
}

@property (nonatomic, strong) IBOutlet UITextField *titleTextField;
@property (nonatomic, strong) IBOutlet UITextField *locationTextField;
@property (nonatomic, strong) IBOutlet UITextField *startTimeTextField;
@property (nonatomic, strong) IBOutlet UITextField *endTimeTextField;

@property (nonatomic, strong) CTLABPerson *contact;

- (IBAction)dismissAppointmentSetter:(id)sender;
- (IBAction)highlightTextField:(id)sender;
- (IBAction)saveTitle:(id)sender;
- (IBAction)saveLocation:(id)sender;
- (IBAction)showDatePicker:(id)sender;
- (IBAction)saveAppointment:(id)sender;

@end
