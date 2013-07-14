//
//  CTLRegisterViewController.m
//  Clientelle
//
//  Created by Samuel Goodwin on 4/11/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import "UITableViewCell+CellShadows.h"
#import "UIColor+CTLColor.h"

#import "CTLRegisterViewController.h"
#import "CTLAccountManager.h"
#import "CTLLoginViewController.h"
#import "CTLContainerViewController.h"
#import "CTLInboxInterstitialViewController.h"
#import "CTLConversationListViewController.h"

NSString *const CTLReloadInboxNotifiyer = @"com.clientelle.notificationKeys.reloadInbox";

@interface CTLRegisterViewController()
@property (nonatomic, strong) UIPickerView *industryPicker;
@property (nonatomic, strong) NSArray *industries;
@property (nonatomic, strong) CTLAPI *api;
@property (nonatomic, strong) NSNumber *industryID;
@end


@implementation CTLRegisterViewController

- (void)viewDidLoad{
    [super viewDidLoad];
            
    self.industryID = @(0);
    self.industryPicker = [self configureIndustryPicker];
    
    self.industryTextField.inputView = self.industryPicker;
    self.industryTextField.tag = 170;
    
    [self translateInputPlaceholders];
    self.navigationItem.title = NSLocalizedString(@"CREATE_ACCOUNT", nil);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEditing:)];
    [self.view addGestureRecognizer:tapGesture];

    if(self.showMenuButton){
        [self.navigationItem setHidesBackButton:YES animated:NO];
        [self.containerView renderMenuButton:self];
    }
    
    [self.emailTextField becomeFirstResponder];
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
    
    if(!self.industries){
        NSMutableArray *industries = [[[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Industries" ofType:@"plist"]] mutableCopy];
        for(NSInteger i=0;i<[industries count];i++){
            NSMutableDictionary *industry = [industries[i] mutableCopy];
            [industry setValue:NSLocalizedString(industry[@"i18n_key"], nil) forKey:@"industry_name"];
            industries[i] = industry;
        }
        self.industries = industries;
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
    self.industryTextField.text = [[self.industries objectAtIndex:row] objectForKey:@"industry_name"];
    self.industryID = [[self.industries objectAtIndex:row] objectForKey:@"industry_id"];
    
    if([self.industryID isEqual: @(13)]){
        [self.industryTextField resignFirstResponder];
        self.industryTextField.inputView = nil;
        self.industryTextField.clearButtonMode = UITextFieldViewModeAlways;
        [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(togglePickerKeyboard:) userInfo:nil repeats:NO];
    }else{
        self.industryTextField.clearButtonMode = UITextFieldViewModeNever;
        self.industryTextField.inputView = self.industryPicker;
        [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(togglePickerKeyboard:) userInfo:nil repeats:NO];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField.tag == 170){
        textField.inputView = self.industryPicker;        
        self.industryTextField.clearButtonMode = UITextFieldViewModeNever;
    }
    
    return YES;
}

- (void)togglePickerKeyboard:(id)sender
{
    [self.industryTextField becomeFirstResponder];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[self.industries objectAtIndex:row] objectForKey:@"industry_name"];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [self.industries count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (void)toggleMenu:(id)sender{
    [self.containerView toggleMenu:sender];
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

- (IBAction)submit:(id)sender
{
    NSDictionary *accountDict = [self validateFields];
    
    if(accountDict){
        
        [CTLAccountManager createAccount:accountDict completionBlock:^(BOOL success, CTLCDAccount *account, NSError *error) {
            
            if(success){
                
                [CTLAccountManager recordPurchase];
                
                if(self.containerView.nextNavString){
                    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:self.containerView.nextNavString];
                    UIViewController<CTLContainerViewDelegate> *viewController = (UIViewController<CTLContainerViewDelegate> *)navigationController.topViewController;
                    viewController.containerView = self.containerView;
                    [self.containerView setMainViewController:viewController];
                    [self.containerView setCurrentUser:account];
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
}

- (NSDictionary *)validateFields
{
    NSArray *fields = @[self.emailTextField, self.passwordTextField, self.confirmPasswordTextField];
    
    for(int i=0;i<[fields count]; i++){
        UITextField *textField = fields[i];
        if([textField.text length] == 0){
            textField.backgroundColor = [UIColor ctlErrorPink];
        }
    }
    
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *confirmPassword = self.confirmPasswordTextField.text;
    NSString *company = self.companyTextField.text;
    NSString *industry = self.industryTextField.text;
       
    //required fields. thow shall now pass!
    if([email length] == 0 || [password length] == 0 || [confirmPassword length] == 0){
        return nil;
    }

    if ([email rangeOfString:@"@"].location == NSNotFound) {
        [self.emailTextField becomeFirstResponder];
        [self alertErrorMessage:@"INVALID_EMAIL"];
        return nil;
    }
    
    if([password length] < 6 || [confirmPassword length] < 6){
        [self.passwordTextField becomeFirstResponder];
        [self alertErrorMessage:@"PASSWORD_REQUIREMENT"];
        return nil;
    }
    
    if([password isEqualToString:confirmPassword] == NO){
        [self.confirmPasswordTextField becomeFirstResponder];
        [self alertErrorMessage:@"PASSWORDS_DO_NOT_MATCH"];
        return nil;
    }
    
    NSDictionary *accountDict = @{ @"email":email, @"password":password, @"company":company, @"industry":industry, @"industry_id":self.industryID };
    return accountDict;
    
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
        [viewController setContainerView:self.containerView];
        [viewController setEmailAddress:self.emailTextField.text];
        return;
    }
}



@end
