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

@property(nonatomic, strong) CTLCDAccount *cdAccount;
@property (nonatomic, weak) CTLSlideMenuController *menuController;
@property(nonatomic, strong) IBOutlet UITextField *companyTextField;
@property(nonatomic, strong) IBOutlet UITextField *industryTextField;
@property(nonatomic, strong) IBOutlet UITextField *emailTextField;
@property(nonatomic, strong) IBOutlet UITextField *passwordTextField;


- (IBAction)submit:(id)sender;

- (IBAction)seeActivity:(id)sender;

@end
