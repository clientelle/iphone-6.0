//
//  CTLWelcomeViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 7/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLWelcomeViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, CTLContainerViewDelegate>

@property (nonatomic, strong) CTLContainerViewController *containerView;

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *companyTextField;
@property (nonatomic, weak) IBOutlet UITextField *industryTextField;

@property (nonatomic, weak) IBOutlet UIView *learnMoreView;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;

- (IBAction)submit:(id)sender;
- (IBAction)dismissLearnMorePopup:(id)sender;

@end
