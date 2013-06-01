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
#import "CTLMessagesListViewController.h"

NSString *const CTLReloadInboxNotifiyer = @"com.clientelle.notificationKeys.reloadInbox";

@implementation CTLRegisterViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _api = [CTLAPI sharedAPI];
    
    _industryID = @(0);
    _industryPicker = [self configureIndustryPicker];
    
    self.industryTextField.inputView = _industryPicker;
    self.industryTextField.tag = 170;
    
    self.account = [CTLCDAccount findFirst];
    
    [self translateInputPlaceholders];
    self.navigationItem.title = NSLocalizedString(@"CREATE_ACCOUNT", nil);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEditing:)];
    [self.view addGestureRecognizer:tapGesture];

    [self.menuController renderMenuButton:self];
    [self.navigationItem setHidesBackButton:NO animated:YES];
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
            account.password = password;
            account.created_at = [NSDate date];
            account.user_id = @([user[@"id"] intValue]);
            account.is_pro = @(1);
            
            if(user[@"authentication_token"]){
                account.auth_token = user[@"authentication_token"];
                [[NSUserDefaults standardUserDefaults] setValue:user[@"authentication_token"] forKey:kCTLAccountAccessToken];
            }
            
            if([company length] > 0 && user[@"company"]){
                account.company = company;
            }
            
            if([industry length] > 0 && user[@"industry"]){
                account.industry = industry;
                account.industry_id = user[@"industry"][@"id"];
            }
                        
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){ 
                UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:self.menuController.nextNavString];
                UIViewController<CTLSlideMenuDelegate> *viewController = (UIViewController<CTLSlideMenuDelegate> *)navigationController.topViewController;
                viewController.menuController = self.menuController;
                [self.menuController setAccount:account];
                [self.menuController setRightSwipeEnabled:YES];
                [self.menuController setMainViewController:viewController];
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
