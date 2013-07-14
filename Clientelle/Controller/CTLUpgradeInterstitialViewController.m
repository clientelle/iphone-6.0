
//
//  CTLUpgradeInterstitialViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 2/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLUpgradeInterstitialViewController.h"
#import "CTLRegisterViewController.h"
#import "CTLContainerViewController.h"

#import "CTLAccountManager.h"
#import "CTLCDAccount.h"

@implementation CTLUpgradeInterstitialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
        
    CTLCDAccount *account = [CTLCDAccount MR_findFirst];
    BOOL hasPro = [CTLAccountManager userDidPurchasePro];
    
    if(hasPro == NO && !account){
        self.navigationItem.title = @"Upgrade";
        self.actionMessageLabel.text = @"You must upgrade to get this feature";
        [self.upgradeButton setTitle: @"Purchase" forState: UIControlStateNormal];
        [self.upgradeButton addTarget:self action:@selector(upgradeToPro:) forControlEvents:UIControlEventTouchUpInside];
    }    
    
    if(hasPro && !account){
        self.navigationItem.title = @"Register";
        self.actionMessageLabel.text = @"Thank you for purchasing.";
        [self.upgradeButton setTitle: @"Create Account" forState: UIControlStateNormal];
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
        [CTLAccountManager recordPurchase];                
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
        [registerViewController setContainerView:self.containerView];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
