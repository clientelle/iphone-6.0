//
//  CTLAccountViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLCDAccount;

@interface CTLAccountViewController : UITableViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) CTLContainerViewController *containerView;
@property (nonatomic, strong) CTLCDAccount *currentUser;

@property (nonatomic, weak) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *companyTextField;
@property (nonatomic, weak) IBOutlet UITextField *industryTextField;

@property (nonatomic, weak) IBOutlet UILabel *accountEmailLabel;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UILabel *accountAgeLabel;
@property (nonatomic, weak) IBOutlet UILabel *daysLabel;

- (IBAction)submit:(id)sender;

@end
