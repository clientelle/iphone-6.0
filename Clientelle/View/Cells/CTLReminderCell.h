//
//  CTLReminderCell.h
//  Clientelle
//
//  Created by Kevin Liu on 4/4/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLCDReminder;

@interface CTLReminderCell : UITableViewCell

- (void)configure:(CTLCDReminder *)reminder;
- (IBAction)markAsComplete:(id)sender;

@property (nonatomic, weak) CTLCDReminder *reminder;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dueDateLabel;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

@end
