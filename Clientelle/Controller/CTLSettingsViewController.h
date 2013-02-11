//
//  CTLSettingsViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLCDAccount;

@interface CTLSettingsViewController : UITableViewController<CTLSlideMenuDelegate, UIGestureRecognizerDelegate>{
    CTLCDAccount *_account;
    UIAlertView *_purchaseAlertView;
}

@property (nonatomic, weak) CTLSlideMenuController *menuController;
@property (nonatomic, strong) IBOutlet UISwitch *notificationSwitch;
@property (nonatomic, strong) IBOutlet UIButton *changeAccountTypeButton;
@property (nonatomic, strong) IBOutlet UITableViewCell *accountTypeCell;

@property (nonatomic, strong) UIBarButtonItem *actionButton;

- (IBAction)dismissKeyboard:(UITapGestureRecognizer *)recognizer;

- (IBAction)toggleNotificationSetting:(UITapGestureRecognizer *)recognizer;


@end

