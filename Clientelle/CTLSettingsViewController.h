//
//  CTLSettingsViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class CTLCDAccount;

@interface CTLSettingsViewController : UITableViewController<CTLContainerViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) CTLContainerViewController *containerView;
@property (nonatomic, strong) IBOutlet UISwitch *appointmentNotificationSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *messageNotificationSwitch;

@property (nonatomic, strong) IBOutlet UITableViewCell *accountTypeCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *appointmentNotificationCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *messageNotificationCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *pinCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *supportCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *featureCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *shareCell;

- (IBAction)toggleNotificationSetting:(UITapGestureRecognizer *)recognizer;


@end

