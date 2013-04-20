//
//  CTLAppointmentsViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 3/11/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "CTLAppointmentCell.h"

extern NSString *const CTLReloadAppointmentsNotification;

@class CTLPickerView;

/* view cannot be a TableViewController because of the top rolodex selector */
@interface CTLAppointmentsListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, CTLSlideMenuDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate, CTLAppointmentCellDelegate>{
    UIView *_emptyView;
    CTLPickerView *_filterPickerView;
    NSArray *_filterArray;
    NSArray *_appointments;
    NSMutableDictionary *_events;
    EKEventStore *_eventStore;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) CTLSlideMenuController *menuController;

- (IBAction)addAppointment:(id)sender;
- (IBAction)dismissPickerFromTap:(UITapGestureRecognizer *)recognizer;

@end
