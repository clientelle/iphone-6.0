//
//  CTLRegisterViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 11/3/2012.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString *const CTLReloadInboxNotifiyer;

@class CTLAPI;
@class CTLCDAccount;

@interface CTLRegisterViewController : UITableViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, CTLSlideMenuDelegate>{
    UIPickerView *_industryPicker;
    NSArray *_industries;
    CTLAPI *_api;
    NSNumber *_industryID;
    BOOL _overrideBackButtonWithMenuButton;
    CTLCDAccount *_account;
    
}

@property (nonatomic, weak) CTLSlideMenuController *menuController;

@property (nonatomic, assign) BOOL overrideBackButtonWithMenuButton;
@property (nonatomic, strong) CTLCDAccount *account;

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordTextField;
@property (nonatomic, weak) IBOutlet UITextField *companyTextField;
@property (nonatomic, weak) IBOutlet UITextField *industryTextField;
@property (nonatomic, weak) IBOutlet UIButton *signInButton;


- (IBAction)submit:(id)sender;

- (IBAction)segueToLogin:(id)sender;

@end
