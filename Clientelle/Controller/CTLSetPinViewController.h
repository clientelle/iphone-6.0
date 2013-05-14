//
//  CTLSetPinViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 5/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLSetPinViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *instructionsLabel;
@property (nonatomic, weak) IBOutlet UITextField *pinTextField;

- (IBAction)textFieldDidChange:(UITextField *)textField;

@end
