//
//  CTLPinInterstialViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 5/15/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"

#import "CTLMainMenuViewController.h"
#import "CTLPinInterstialViewController.h"
#import "CTLAppointmentsListViewController.h"

@implementation CTLPinInterstialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self promptForPin:nil];
    
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"whiteButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // Set the background for any states you plan to use
    [self.enterPinButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.enterPinButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    [self.enterPinButton setTitleColor:[UIColor colorFromUnNormalizedRGB:81.0f green:91.0f blue:130.0f alpha:1.0f] forState:UIControlStateNormal];
    [self.enterPinButton setTitleColor:[UIColor colorFromUnNormalizedRGB:61.0f green:71.0f blue:110.0f alpha:1.0f] forState:UIControlStateHighlighted];
    
    self.enterPinButton.layer.shadowOpacity = 0.2f;
    self.enterPinButton.layer.shadowRadius = 1.0f;
    self.enterPinButton.layer.shadowOffset = CGSizeMake(0,0);
    
    self.titleLabel.text = NSLocalizedString(@"REQUIRE_PIN_ACCESS", nil);
    [self.enterPinButton setTitle:NSLocalizedString(@"ENTER_PIN", nil) forState:UIControlStateNormal];
    self.forgotPinLabel.text = NSLocalizedString(@"FORGOT_YOUR_PIN", nil);
}

- (IBAction)promptForPin:(id)sender
{
    UIAlertView *confirmPinAlert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ENTER_CURRENT_PIN", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:@"OK", nil];
    
    confirmPinAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    
    UITextField *textField = [confirmPinAlert textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.delegate = self;
    [confirmPinAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([[alertView textFieldAtIndex:0].text isEqualToString:[defaults valueForKey:@"PIN_NUMBER"]]){
            [defaults setBool:NO forKey:@"IS_LOCKED"];
            [defaults synchronize];
            self.titleLabel.textColor = [UIColor ctlTorquoise];
            self.titleLabel.text = NSLocalizedString(@"CORRECT_PIN", nil);
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            self.titleLabel.textColor = [UIColor ctlRed];
            self.titleLabel.text = NSLocalizedString(@"WRONG_PIN_ENTERED", nil);
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    return (newLength > 4) ? NO : YES;
}

- (BOOL)textFieldShouldReturn: (UITextField*) textField
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
