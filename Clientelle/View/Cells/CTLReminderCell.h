//
//  CTLReminderCell.h
//  Clientelle
//
//  Created by Kevin Liu on 4/4/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLCDReminder;

@protocol CTLReminderCellDelegate

- (void)changeReminderStatus:(UITableViewCell *)cell;

@end


@interface CTLReminderCell : UITableViewCell;

- (IBAction)markAsComplete:(id)sender;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dueDateLabel;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

@property (nonatomic, assign) id<CTLReminderCellDelegate>delegate;

- (void)decorateInCompletedCell:(BOOL)isOverDue;
- (void)decorateCompletedCell;

@end
