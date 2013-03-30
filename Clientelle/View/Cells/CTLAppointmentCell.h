//
//  CTLAppointmentCell.h
//  Clientelle
//
//  Created by Kevin Liu on 3/12/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLCDAppointment;

@interface CTLAppointmentCell : UITableViewCell

- (void)configure:(CTLCDAppointment *)appointment;
- (IBAction)segueToMapView:(id)sender;


@property (nonatomic, weak) CTLCDAppointment *appointment;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIButton *mapButton;

@end
