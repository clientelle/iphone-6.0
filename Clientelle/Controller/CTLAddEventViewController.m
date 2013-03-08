//
//  CTLAddEventViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/9/13.
//  Copyright (c) 2013 Clientelle Leads LLC. All rights reserved.
//

#import "UIColor+CTLColor.h"
#import "NSDate+CTLDate.h"
#import "CTLEvent.h"
#import "CTLABPerson.h"
#import "CTLABGroup.h"
#import "CTLCDPerson.h"

#import "CTLAddEventViewController.h"
#import "CTLContactsListViewController.h"

int CTLStartTimeInputTag = 18;
int CTLEndTimeInputTag = 81;

@interface CTLAddEventViewController ()

@end

@implementation CTLAddEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"SET_APPOINTMENT", nil);
	
    _event = [[CTLEvent alloc] initForEvents];
    _appointment = [EKEvent eventWithEventStore:_event.store];
    _appointment.calendar = [_event.store defaultCalendarForNewEvents];
    
    self.titleTextField.placeholder = NSLocalizedString(@"APPOINTMENT_NOTE", nil);
    self.locationTextField.placeholder = NSLocalizedString(@"APPOINTMENT_NOTE", nil);
    self.startTimeTextField.placeholder = NSLocalizedString(@"START_TIME", nil);
    self.endTimeTextField.placeholder = NSLocalizedString(@"END_TIME", nil);
    self.startLabel.text = NSLocalizedString(@"START", nil);
    self.endLabel.text = NSLocalizedString(@"END", nil);
    
    if(self.contact){
        _appointment.title = [NSString stringWithFormat:NSLocalizedString(@"MEETING_WITH", nil), [self.contact compositeName]];
        self.titleTextField.text = _appointment.title;
    }
    
    [self.titleTextField becomeFirstResponder];
       
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [_datePicker addTarget:self action:@selector(setDate:) forControlEvents:UIControlEventValueChanged];
    
    _datePicker.date = [NSDate hoursFrom:[NSDate date] numberOfHours:1];
    
    self.startTimeTextField.inputView = _datePicker;
    self.endTimeTextField.inputView = _datePicker;
    self.startTimeTextField.tag = CTLStartTimeInputTag;
    self.endTimeTextField.tag = CTLEndTimeInputTag;
    
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissInputViews:)]];

}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return NSLocalizedString(@"APPOINTMENT_MSG", nil);
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
    [textField setBackgroundColor:[UIColor textInputHighlightBackgroundColor]];
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
    UIColor *errorColor = [UIColor colorFromUnNormalizedRGB:249.0f green:235.0f blue:231.0f alpha:1.0f];
    
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

- (IBAction)saveAppointment:(id)sender
{
    if(![self validateAppointment:_appointment]){
        return;
    }
    
    NSError *error = nil;
    [[_event store] saveEvent:_appointment span:EKSpanThisEvent commit:YES error:&error];
    
    if (error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        [self dismissAppointmentSetter:sender];
    }
}

#pragma mark - Outlet Controls

- (IBAction)dismissAppointmentSetter:(id)sender
{
    [self.titleTextField setBackgroundColor:[UIColor clearColor]];
    [self.startTimeTextField setBackgroundColor:[UIColor clearColor]];
    [self.endTimeTextField setBackgroundColor:[UIColor clearColor]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CTLTimestampForRowNotification object:nil];
        NSString *successMessage = @"An event has been added to your calendar";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:successMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }];
}

#pragma mark - Cleanup

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
