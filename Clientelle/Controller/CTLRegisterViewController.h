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

@interface CTLRegisterViewController : UITableViewController<UIPickerViewDelegate, UIPickerViewDataSource,CTLSlideMenuDelegate>{
    UIPickerView *_industryPicker;
    NSArray *_industries;
    CTLAPI *_api;
    NSNumber *_industryID;
    
}

@property (nonatomic, weak) CTLSlideMenuController *menuController;

@property (nonatomic, assign) BOOL overrideBackButtonWithMenuButton;
@property (nonatomic, weak) CTLCDAccount *cdAccount;
@property (nonatomic, weak) IBOutlet UITextField *companyTextField;
@property (nonatomic, weak) IBOutlet UITextField *industryTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;


- (IBAction)submit:(id)sender;

- (IBAction)seeActivity:(id)sender;

@end
