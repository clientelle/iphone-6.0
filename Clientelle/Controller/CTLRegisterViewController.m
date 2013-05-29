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
    
    _industryID = @(0);
    _industryPicker = [self configureIndustryPicker];
    
    self.industryTextField.inputView = _industryPicker;
    self.industryTextField.tag = 170;
    
    _account = [CTLCDAccount findFirst];
    
    [self translateInputPlaceholders];
    
    if(_account){
        
        self.navigationItem.title = NSLocalizedString(@"YOUR_ACCOUNT", nil);
        
        self.account = _account;
        _industryID = self.account.industry_id;
        self.companyTextField.text = [self.account company];
        self.industryTextField.text = [self.account industry];
        self.emailTextField.text = [self.account email];
        self.passwordTextField.text = [self.account password];
        self.confirmPasswordTextField.text = [self.account password];
        
    }else{
        self.navigationItem.title = NSLocalizedString(@"CREATE_ACCOUNT", nil);
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
        NSMutableArray *industries = [[[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Industries" ofType:@"plist"]] mutableCopy];
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
    
    if([_industryID isEqual: @(13)]){
        [self.industryTextField resignFirstResponder];
        self.industryTextField.inputView = nil;
        self.industryTextField.clearButtonMode = UITextFieldViewModeAlways;
        [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(togglePickerKeyboard:) userInfo:nil repeats:NO];
    }else{
        self.industryTextField.clearButtonMode = UITextFieldViewModeNever;
        self.industryTextField.inputView = _industryPicker;
        [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(togglePickerKeyboard:) userInfo:nil repeats:NO];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField.tag == 170){
        textField.inputView = _industryPicker;
        self.industryTextField.clearButtonMode = UITextFieldViewModeNever;
    }
    
    return YES;
}

- (void)togglePickerKeyboard:(id)sender
{
    [self.industryTextField becomeFirstResponder];
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

- (void)alertErrorMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:NSLocalizedString(message, nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];

}

- (IBAction)submit:(id)sender{
    
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *confirmPassword = self.confirmPasswordTextField.text;
    NSString *company = self.companyTextField.text;
    NSString *industry = self.industryTextField.text;
    NSString *industry_id = [NSString stringWithFormat:@"%d", _industryID.intValue];

    if([email length] == 0 || [password length] == 0 || [confirmPassword length] == 0){
        return;
    }
    
    if ([email rangeOfString:@"@"].location == NSNotFound) {
        [self.emailTextField becomeFirstResponder];
        [self alertErrorMessage:@"INVALID_EMAIL"];
        return;
    }    
    
    if([password length] < 6 || [confirmPassword length] < 6){
        [self.passwordTextField becomeFirstResponder];
        [self alertErrorMessage:@"PASSWORD_REQUIREMENT"];
        return;
    }
    
    if([password isEqualToString:confirmPassword] == NO){
        [self.confirmPasswordTextField becomeFirstResponder];
        [self alertErrorMessage:@"PASSWORDS_DO_NOT_MATCH"];
        return;
    }    
        
    
    NSMutableDictionary *post = [NSMutableDictionary dictionary];

    [post setValue:email forKey:@"user[email]"];
    [post setValue:password forKey:@"user[password]"];
    [post setValue:confirmPassword forKey:@"user[password_confirmation]"];
    [post setValue:company forKey:@"company[name]"];
    [post setValue:industry forKey:@"industry[name]"];
    [post setValue:industry_id forKey:@"industry[id]"];
    [post setValue:@"iphone" forKey:@"source"];
    [post setValue:[[NSLocale currentLocale] localeIdentifier] forKey:@"locale"];
        
    [_api makeRequest:@"/register.json" withParams:post method:GOHTTPMethodPOST withBlock:^(BOOL requestSucceeded, NSDictionary *response) {
        
        if(requestSucceeded){

            NSDictionary *user = response[@"user"];

            CTLCDAccount *account = [CTLCDAccount MR_createEntity];
            account.email = email;
            account.company = company;
            account.industry = industry;
            
            if(response[@"user"]){
                if(response[@"user"][@"industry"]){
                    _account.industry_id = response[@"user"][@"industry"][@"id"];
                }
            }
            
            account.password = password;
            account.created_at = [NSDate date];
             
            account.auth_token = response[kCTLAuthTokenKey];
            account.user_id = @([user[@"id"] intValue]);
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
