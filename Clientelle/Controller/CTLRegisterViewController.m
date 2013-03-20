//
//  CTLRegisterViewController.m
//  Clientelle
//
//  Created by Samuel Goodwin on 4/11/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import "CTLAPI.h"
#import "CTLCDAccount.h"

#import "CTLRegisterViewController.h"
#import "CTLLoginViewController.h"
#import "CTLSlideMenuController.h"
#import "CTLInboxInterstitialViewController.h"

NSString *const CTLReloadInboxNotifiyer = @"com.clientelle.notificationKeys.reloadInbox";

@implementation CTLRegisterViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.overrideBackButtonWithMenuButton = YES;
    
    _api = [CTLAPI sharedAPI];
    
    //TODO: implement hasConnection
    if([_api hasInternetConnection]){
        [self industriesFromServer];
    }else{
        _industries = [self industriesFromPList];
    }
    
    _industryPicker = [[UIPickerView alloc] init];
    _industryPicker.delegate = self;
    _industryPicker.dataSource = self;
    _industryPicker.showsSelectionIndicator = YES;
    self.industryTextField.inputView = _industryPicker;
    
    _cdAccount = [CTLCDAccount findFirst];
    
    
    if(_cdAccount){
        
        self.navigationItem.title = @"Your Account";
        
        self.cdAccount = _cdAccount;
        self.companyTextField.text = [self.cdAccount company];
        self.industryTextField.text = [self.cdAccount industry];
        self.emailTextField.text = [self.cdAccount email];
        self.passwordTextField.text = [self.cdAccount password];
    }else{
        self.navigationItem.title = @"Register";
    }
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    
    if(self.overrideBackButtonWithMenuButton){
    
        [self.menuController renderMenuButton:self];
        [self.navigationItem setHidesBackButton:YES animated:YES];
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem: backButton];

}

- (void)dismissEditing:(id)sender{
    [self.view endEditing:YES];
}

- (NSArray *)industriesFromPList {
    return [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Industries" ofType:@"plist"]];
}

- (void)industriesFromServer {
    [_api makeRequest:@"/industries/get-valid" withBlock:^(BOOL requestSucceeded, NSDictionary *response) {
        if(requestSucceeded){
            if([response objectForKey:@"industries"]){
                _industries = [response objectForKey:@"industries"];
            }else{
                _industries = [self industriesFromPList];
            }
        }else{
            NSLog(@"RESPONSE %@", response);
            NSString *message = [CTLAPI messageFromResponse:response];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops :("
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.industryTextField.text = [[_industries objectAtIndex:row] objectForKey:@"industry_name"];
    _industryID = [[_industries objectAtIndex:row] objectForKey:@"industry_id"];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[_industries objectAtIndex:row] objectForKey:@"industry_name"];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [_industries count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}


- (void)toggleMenu:(id)sender{
    [self.menuController toggleMenu:sender];
}

- (IBAction)submit:(id)sender{
    
    if([self.emailTextField.text length] == 0){
        return;
    }
    //TODO: match industry to industry_id and pass it along
    __block CTLCDAccount *account = [CTLCDAccount MR_createEntity];
    account.email = self.emailTextField.text;
    account.company = self.companyTextField.text;
    account.industry = self.industryTextField.text;
    account.password = self.passwordTextField.text;
    account.dateCreated = [NSDate date];
    
    //create dictionary from coredata "account" entity
    NSMutableDictionary *personDict = [[NSMutableDictionary alloc] initWithDictionary:[account dictionaryWithValuesForKeys:@[@"email", @"password", @"company", @"industry"]]];
    
        
    //add some meta data
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    [personDict setValue:locale forKey:@"locale"];
    [personDict setValue:@"iphone" forKey:@"source"];
    
    //?XDEBUG_SESSION_START=ECLIPSE_DBGP
    [_api makeRequest:@"/register?XDEBUG_SESSION_START=ECLIPSE_DBGP" withParams:personDict withBlock:^(BOOL requestSucceeded, NSDictionary *response) {
        
         if(requestSucceeded){
            
            NSDictionary *user = response[@"user"];
            
            account.access_token = response[kCTLAccessTokenKey];
            account.user_idValue = [user[@"user_id"] intValue];
            account.company_idValue = [user[@"company_id"] intValue];
            account.industry_idValue = [user[@"industry_id"] intValue];
            
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){ 
                            
                [[NSUserDefaults standardUserDefaults] setValue:[response objectForKey:kCTLAccessTokenKey] forKey:kCTLAccountAccessToken];
                
                [self.menuController setHasPro:YES];
                [self.menuController setHasAccount:YES];
                [self.menuController setRightSwipeEnabled:YES];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle:[NSBundle mainBundle]];
                UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"inboxInterstitialNavigationController"];
                
                CTLInboxInterstitialViewController<CTLSlideMenuDelegate> *inboxInterstitial = (CTLInboxInterstitialViewController<CTLSlideMenuDelegate> *)navigationController.topViewController;
                
                [inboxInterstitial setMenuController:self.menuController];
                [self.menuController flipToView:inboxInterstitial];
            }];
                                  
        }else{
            
            if([response[@"code"] intValue] == 2){
                NSString *message = @"This email address is already registered. Would you like to login?";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
                [alert show];

            }else{
            
                NSString *message = [CTLAPI messageFromResponse:response];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops :("
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [self performSegueWithIdentifier:@"toLogin" sender:alertView];
    }
}

- (IBAction)segueToLogin:(id)sender
{
    [self performSegueWithIdentifier:@"toLogin" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"toLogin"]){
        CTLLoginViewController *viewController = [segue destinationViewController];
        [viewController setEmailAddress:self.emailTextField.text];
        return;
    }
}



@end
