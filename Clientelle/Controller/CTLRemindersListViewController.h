//
//  CTLRemindersListViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 4/4/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

extern NSString *const CTLReloadRemindersNotification;

@interface CTLRemindersListViewController : UITableViewController{
    NSArray *_reminders;
}

@property (nonatomic, weak) CTLSlideMenuController *menuController;

- (IBAction)addReminder:(id)sender;

@end
