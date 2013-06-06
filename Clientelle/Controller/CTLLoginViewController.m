//
//  CTLLoginViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 2/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAPI.h"
#import "CTLCDAccount.h"
#import "CTLLoginViewController.h"
#import "CTLSlideMenuController.h"
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
                           
    [_api makeRequest:@"/login.json" withParams:post method:GOHTTPMethodPOST withBlock:^(BOOL requestSucceeded, NSDictionary *response) {
        
        if(requestSucceeded){
            
            CTLCDAccount *account = [CTLCDAccount createFromDictionary:response];
            
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
                
                if(self.menuController.nextNavString){
                    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:self.menuController.nextNavString];
                    UIViewController<CTLSlideMenuDelegate> *viewController = (UIViewController<CTLSlideMenuDelegate> *)navigationController.topViewController;
                    viewController.menuController = self.menuController;
                    [self.menuController setMainViewController:viewController];
                    [self.menuController setIsPro:YES];
                    [self.menuController setAccount:account];
                    [self.menuController setRightSwipeEnabled:YES];
                    [self.menuController flipToView];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
            
        }else{
            
            NSString *message = [CTLAPI messageFromResponse:response];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
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
