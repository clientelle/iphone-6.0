//
//  CTLLoginViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 2/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAPI.h"
#import "CTLAccountManager.h"
#import "CTLLoginViewController.h"
#import "CTLContainerViewController.h"
#import "CTLInboxInterstitialViewController.h"

@implementation CTLLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if([self.emailAddress length] > 0){
        self.emailTextField.text = self.emailAddress;
    }
    
    _api = [CTLAPI sharedAPI];
}


- (IBAction)loginAndSyncAccount:(id)sender
{
    if([self.emailTextField.text length] == 0 || [self.passwordTextField.text length] == 0){
        return;
    }
    
    if([self.emailTextField.text rangeOfString:@"@"].location == NSNotFound){
        [self alertMessage:@"INVALID_EMAIL"];
        return;
    }
    
    if([self.passwordTextField.text length] < 6){
        [self alertMessage:@"PASSWORD_REQUIREMENT"];
        return;
    }
    
    NSMutableDictionary *post = [NSMutableDictionary dictionary];
    [post setValue:self.emailTextField.text forKey:@"user[email]"];
    [post setValue:self.passwordTextField.text forKey:@"user[password]"];
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kCTLPushNotifToken];
    
    if(deviceToken){
        [post setValue:deviceToken forKey:@"user[apn_token]"];
    }
    
    [CTLAccountManager loginAndSync:post withCompletionBlock:^(BOOL result, CTLCDAccount *account, NSError *error){
        
        if(result){
                  
            if(self.containerView.nextNavString){
                UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:self.containerView.nextNavString];
                UIViewController<CTLContainerViewDelegate> *viewController = (UIViewController<CTLContainerViewDelegate> *)navigationController.topViewController;
                viewController.containerView = self.containerView;
                [self.containerView setMainViewController:viewController];
                [self.containerView setRightSwipeEnabled:YES];
                [self.containerView flipToView];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
                     
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (void)alertMessage:(NSString *)i18nKey
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:NSLocalizedString(i18nKey, nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}


- (IBAction)forgotPassword:(id)sender
{
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DevConfig" ofType:@"plist"]];
    NSURL *forgotPasswordURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/forgot-password?email=%@", [plist objectForKey:@"mobileRoot"], self.emailTextField.text]];
    [[UIApplication sharedApplication] openURL:forgotPasswordURL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
