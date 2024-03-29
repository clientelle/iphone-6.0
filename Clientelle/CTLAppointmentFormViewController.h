//
//  CTLAddEventViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/9/13.
//  Copyright (c) 2013 Clientelle Leads LLC. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "CTLFieldCell.h"

@class CTLCDContact;
@class CTLCDAppointment;

@interface CTLAppointmentFormViewController : UITableViewController<CTLContainerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) CTLContainerViewController *containerView;
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UITextField *contactNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *startTimeTextField;
@property (nonatomic, weak) IBOutlet UITextField *endTimeTextField;
@property (nonatomic, weak) IBOutlet UITextField *feeTextField;
@property (nonatomic, weak) IBOutlet UITextField *addressTextField;
@property (nonatomic, weak) IBOutlet UITextField *address2TextField;

@property (nonatomic, assign) BOOL presentedAsModal;
@property (nonatomic, assign) BOOL transitionedFromLocalNotification;

@property (nonatomic, strong) CTLCDAppointment *appointment;
@property (nonatomic, strong) NSDecimalNumber *appointmentFee;
@property (nonatomic, strong) CTLCDContact *contact;

- (IBAction)contactDidChange:(UITextField *)textField;
- (IBAction)formatFeeString:(UITextField *)textField;
- (IBAction)unformatCurrency:(UITextField *)textField;
- (IBAction)showDatePicker:(id)sender;
- (IBAction)saveAppointment:(id)sender;
- (void)dismiss:(id)sender;

@end
