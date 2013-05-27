//
//  CTLRegisterViewController.m
//  Clientelle
//
//  Created by Samuel Goodwin on 4/11/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import "CTLAPI.h"
#import "CTLCDAccount.h"

#import "UITableViewCell+CellShadows.h"
#import "UIColor+CTLColor.h"

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
    
    _industryPicker = [self configureIndustryPicker];
    
    self.industryTextField.inputView = _industryPicker;
    
    _account = [CTLCDAccount findFirst];
    
    [self translateInputPlaceholders];
    
    if(_account){
        
        self.navigationItem.title = @"Your Account";
        
        self.account = _account;
        self.companyTextField.text = [self.account company];
        self.industryTextField.text = [self.account industry];
        self.emailTextField.text = [self.account email];
        self.passwordTextField.text = [self.account password];
    }else{
        self.navigationItem.title = @"Register";
    }
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    
    if(self.overrideBackButtonWithMenuButton){
    
        [self.menuController renderMenuButton:self];
        [self.navigationItem setHidesBackButton:YES animated:YES];
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem: backButton];

}

- (void)translateInputPlaceholders
{
    self.emailTextField.placeholder = NSLocalizedString(@"EMAIL_ADDRESS", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"PASSWORD", nil);
    self.confirmPasswordTextField.placeholder = NSLocalizedString(@"CONFIRM_PASSWORD", nil);
    self.companyTextField.placeholder = NSLocalizedString(@"COMPANY_NAME", nil);
    self.industryTextField.placeholder = NSLocalizedString(@"INDUSTRY", nil);
    self.signInButton.titleLabel.text = NSLocalizedString(@"ALREADY_HAVE_ACCOUNT", nil);
}

- (UIPickerView *)configureIndustryPicker
{
    UIPickerView *industryPicker = [[UIPickerView alloc] init];
    industryPicker.delegate = self;
    industryPicker.dataSource = self;
    industryPicker.showsSelectionIndicator = YES;
    
    if(!_industries){
        NSMutableArray *industries = [[self industriesFromPList] mutableCopy];
        for(NSInteger i=0;i<[industries count];i++){
            NSMutableDictionary *industry = [industries[i] mutableCopy];
            [industry setValue:NSLocalizedString(industry[@"i18n_key"], nil) forKey:@"industry_name"];
            industries[i] = industry;
        }
        _industries = industries;
    }
    
    return industryPicker;
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
#pragma mark UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell addShadowToCellInGroupedTableView:self.tableView atIndexPath:indexPath];
    return cell;
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
    //add some meta data
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSMutableDictionary *post = [NSMutableDictionary dictionary];


    [post setValue:self.emailTextField.text forKey:@"user[email]"];
    [post setValue:self.passwordTextField.text forKey:@"user[password]"];
    [post setValue:self.confirmPasswordTextField.text forKey:@"user[password_confirmation]"];
    //[post setValue:self.companyTextField.text forKey:@"company"];
    //[post setValue:self.industryTextField.text forKey:@"industry"];
    //[post setValue:@"iphone" forKey:@"source"];
    //[post setValue:locale forKey:@"locale"];
        
    [_api makeRequest:@"/register.json" withParams:post withBlock:^(BOOL requestSucceeded, NSDictionary *response) {
        
        if(requestSucceeded){

            NSDictionary *user = response[@"user"];

             CTLCDAccount *account = [CTLCDAccount MR_createEntity];
             account.email = self.emailTextField.text;
             account.company = self.companyTextField.text;
             account.industry = self.industryTextField.text;
             account.password = self.passwordTextField.text;
             account.created_at = [NSDate date];
             
            account.auth_token = response[kCTLAuthTokenKey];
            account.user_id = @([user[@"id"] intValue]);
            account.is_pro = @(1);
            
            //account.company_idValue = [user[@"company_id"] intValue];
            //account.industry_idValue = [user[@"industry_id"] intValue];
            
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
