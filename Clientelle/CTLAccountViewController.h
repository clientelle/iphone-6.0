//
//  CTLAccountViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const CTLReloadAccountsNotification;

@class CTLCDAccount;

@interface CTLAccountViewController : UITableViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, CTLContainerViewDelegate>

@property (nonatomic, strong) CTLContainerViewController *containerView;
@property (nonatomic, strong) CTLCDAccount *account;

@property (nonatomic, weak) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *companyTextField;
@property (nonatomic, weak) IBOutlet UITextField *industryTextField;

@property (nonatomic, weak) IBOutlet UILabel *accountEmailLabel;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UILabel *accountAgeLabel;
@property (nonatomic, weak) IBOutlet UILabel *daysLabel;
@property (nonatomic, weak) IBOutlet UIView *accountActionButtonContainerView;
@property (nonatomic, weak) IBOutlet UIButton *accountActionButton;

- (IBAction)saveAccountInfo:(id)sender;

@end
