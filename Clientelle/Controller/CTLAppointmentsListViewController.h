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

extern NSString *const CTLAppointmentWasAddedNotification;

@class CTLPickerView;

@interface CTLAppointmentsListViewController : UIViewController<NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, CTLContainerViewDelegate, UIGestureRecognizerDelegate, CTLAppointmentCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) CTLContainerViewController *containerView;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;

- (IBAction)addAppointment:(id)sender;

@end
