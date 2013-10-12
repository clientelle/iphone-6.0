//
//  CTLRegisterViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 11/3/2012.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const CTLReloadInboxNotifiyer;

@class CTLCDAccount;

@interface CTLRegisterViewController : UITableViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, CTLContainerViewDelegate>

@property (nonatomic, weak) CTLContainerViewController *containerView;

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordTextField;
@property (nonatomic, weak) IBOutlet UITextField *companyTextField;
@property (nonatomic, weak) IBOutlet UITextField *industryTextField;
@property (nonatomic, weak) IBOutlet UIButton *signInButton;
@property (nonatomic, assign) BOOL showMenuButton;

- (IBAction)submit:(id)sender;
- (IBAction)segueToLogin:(id)sender;

@end
