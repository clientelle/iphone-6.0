
//
//  CTLUpgradeInterstitialViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 2/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAccountInterstitialViewController.h"
#import "CTLRegisterViewController.h"
#import "CTLSlideMenuController.h"
#import "CTLCDAccount.h"

@implementation CTLAccountInterstitialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _account = [CTLCDAccount MR_findFirst];
    
    if(!_account){
        
        self.navigationItem.title = @"Upgrade";
        self.actionMessageLabel.text = @"You must upgrade to get this feature";
        
        [self.upgradeButton setTitle: @"Purchase" forState: UIControlStateNormal];
        [self.upgradeButton addTarget:self action:@selector(upgradeToPro:) forControlEvents:UIControlEventTouchUpInside];
        
    }else {
        
        self.navigationItem.title = @"Register";
        [self.upgradeButton setTitle: @"Create Account" forState: UIControlStateNormal];
        self.actionMessageLabel.text = @"Thank you for purchasing.";
        
        [self.upgradeButton addTarget:self action:@selector(toSignup:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

- (void)upgradeToPro:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Purchase Pro?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Purchase", nil];

    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        _account.is_pro = @(1);
        [self performSegueWithIdentifier:@"toSignup" sender:alertView];
    }
}

- (void)toSignup:(id)sender{
    [self performSegueWithIdentifier:@"toSignup" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"toSignup"]){
        CTLRegisterViewController *registerViewController = [segue destinationViewController];
        [registerViewController setOverrideBackButtonWithMenuButton:NO];
        [registerViewController setMenuController:self.menuController];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
