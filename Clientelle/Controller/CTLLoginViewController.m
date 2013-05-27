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


- (IBAction)loginAndSyncAccount:(id)sender{
    
    if([self.emailTextField.text length] > 0 && [self.passwordTextField.text length] > 0){

        //create dictionary from coredata "account" entity
        NSDictionary *credentials = @{@"email":self.emailTextField.text, @"password":self.passwordTextField.text};
                               
        [_api makeRequest:@"/auth/login.json" withParams:credentials withBlock:^(BOOL requestSucceeded, NSDictionary *response) {
            
            if(requestSucceeded){
                
                NSDictionary *user = response[@"user"];
                NSDictionary *company = response[@"company"];
                
                CTLCDAccount *account = [CTLCDAccount MR_createEntity];
                account.auth_token = response[kCTLAuthTokenKey];
                account.user_idValue = [user[@"user_id"] intValue];
                account.email = user[@"email"];
                account.password = user[@"password"];
                account.first_name = user[@"first_name"];
                account.last_name = user[@"last_name"];
                account.created_at = [NSDate date];
                account.company = company[@"name"];
                account.company_idValue = [user[@"company_id"] intValue];
                account.industry = company[@"industry_name"];
                account.industry_idValue = [company[@"industry_id"] intValue];
                account.is_pro = @(1);
                                
                [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
                    
                    [[NSUserDefaults standardUserDefaults] setValue:[response objectForKey:kCTLAuthTokenKey] forKey:kCTLAccountAccessToken];
                    
                    [self.menuController setRightSwipeEnabled:YES];
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle:[NSBundle mainBundle]];
                    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"inboxInterstitialNavigationController"];
                    
                    CTLInboxInterstitialViewController<CTLSlideMenuDelegate> *inboxInterstitial = (CTLInboxInterstitialViewController<CTLSlideMenuDelegate> *)navigationController.topViewController;
                    
                    [inboxInterstitial setMenuController:self.menuController];
                    [self.menuController setMainViewController:inboxInterstitial];
                    [self.menuController flipToView];
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
