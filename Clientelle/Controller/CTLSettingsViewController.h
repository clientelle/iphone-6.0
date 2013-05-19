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

@interface CTLSettingsViewController : UITableViewController<CTLSlideMenuDelegate, MFMailComposeViewControllerDelegate>{
    CTLCDAccount *_account;
    UIAlertView *_purchaseAlertView;
}

@property (nonatomic, weak) CTLSlideMenuController *menuController;
@property (nonatomic, strong) IBOutlet UISwitch *notificationSwitch;
@property (nonatomic, strong) IBOutlet UITableViewCell *accountTypeCell;

- (IBAction)toggleNotificationSetting:(UITapGestureRecognizer *)recognizer;


@end

