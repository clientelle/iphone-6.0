
//
//  CTLUpgradeInterstitialViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 2/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLUpgradeInterstitialViewController.h"
#import "CTLRegisterViewController.h"
#import "CTLSlideMenuController.h"
#import "CTLCDAccount.h"

@implementation CTLUpgradeInterstitialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];

    _account = [CTLCDAccount MR_findFirst];
    
    if(self.menuController.isPro && !_account){
        self.navigationItem.title = @"Register";
        [self.upgradeButton setTitle: @"Create Account" forState: UIControlStateNormal];
        self.actionMessageLabel.text = @"Thank you for purchasing.";
        [self.upgradeButton addTarget:self action:@selector(toSignup:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if(!self.menuController.isPro){
        self.navigationItem.title = @"Upgrade";
        self.actionMessageLabel.text = @"You must upgrade to get this feature";
        
        [self.upgradeButton setTitle: @"Purchase" forState: UIControlStateNormal];
        [self.upgradeButton addTarget:self action:@selector(upgradeToPro:) forControlEvents:UIControlEventTouchUpInside];
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
        self.menuController.isPro = YES;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"IS_PRO"];
        [defaults synchronize];
        [self toSignup:alertView];
    }
}

- (void)toSignup:(id)sender
{
    [self performSegueWithIdentifier:@"toSignup" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"toSignup"]){
        CTLRegisterViewController *registerViewController = [segue destinationViewController];
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
