//
//  CTLAppointmentCell.h
//  Clientelle
//
//  Created by Kevin Liu on 3/12/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLCDAppointment;

@protocol CTLAppointmentCellDelegate

- (void)configure:(UITableViewCell *)cell withAppointment:(CTLCDAppointment *)appointment;
- (void)showMap:(UITableViewCell *)cell;
- (void)changeAppointmentStatus:(UITableViewCell *)cell;

@end

@interface CTLAppointmentCell : UITableViewCell;

- (IBAction)markAsComplete:(id)sender;
- (IBAction)segueToMapView:(id)sender;
- (void)decorateInCompletedCell:(BOOL)isOverDue;
- (void)decorateCompletedCell;

@property (nonatomic, assign) id<CTLAppointmentCellDelegate>delegate;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *feeLabel;
@property (nonatomic, weak) IBOutlet UIButton *mapButton;

@property (nonatomic, weak) IBOutlet UIButton *doneButton;

@end
