//
//  CTLPinInterstialViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 5/15/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLPinInterstialViewController : UIViewController<UITextFieldDelegate, CTLSlideMenuDelegate>

@property (nonatomic, weak)IBOutlet UILabel *titleLabel;
@property (nonatomic, weak)IBOutlet UIButton *enterPinButton;
@property (nonatomic, weak)IBOutlet UILabel *forgotPinLabel;
@property (nonatomic, weak)IBOutlet UIButton *retrievePinLinkButton;
@property (nonatomic, weak) CTLSlideMenuController *menuController;

- (IBAction)promptForPin:(id)sender;

@end
