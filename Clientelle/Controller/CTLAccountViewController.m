//
//  CTLAccountViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAPI.h"
#import "CTLCDAccount.h"
#import "UIColor+CTLColor.h"
#import "UITableViewCell+CellShadows.h"
#import "CTLAccountViewController.h"
#import "CTLSlideMenuController.h"

@implementation CTLAccountViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _api = [CTLAPI sharedAPI];
    
    _industryPicker = [self configureIndustryPicker];
    
    self.industryTextField.inputView = _industryPicker;
    self.industryTextField.tag = 170;
    
    _account = [CTLCDAccount findFirst];
    
    self.firstNameTextField.placeholder = NSLocalizedString(@"FIRST_NAME", nil);
    self.lastNameTextField.placeholder = NSLocalizedString(@"LAST_NAME", nil);
    self.emailTextField.placeholder = NSLocalizedString(@"EMAIL_ADDRESS", nil);
    self.companyTextField.placeholder = NSLocalizedString(@"COMPANY_NAME", nil);
    self.industryTextField.placeholder = NSLocalizedString(@"INDUSTRY", nil);
    
    if(_account){
        
        self.navigationItem.title = NSLocalizedString(@"YOUR_ACCOUNT", nil);
        
        self.account = _account;
        _industryID = self.account.industry_id;
        self.firstNameTextField.text = [self.account first_name];
        self.lastNameTextField.text = [self.account last_name];
        self.companyTextField.text = [self.account company];
        self.industryTextField.text = [self.account industry];
        self.emailTextField.text = [self.account email];
        
        
    }else{
        self.navigationItem.title = NSLocalizedString(@"CREATE_ACCOUNT", nil);
    }
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEditing:)];
    [self.view addGestureRecognizer:tapGesture];
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

//- (IBAction)submit:(id)sender{
//    
//    NSString *email = self.emailTextField.text;
//    NSString *first_name = self.firstNameTextField.text;
//    NSString *last_name = self.lastNameTextField.text;
//    NSString *company = self.companyTextField.text;
//    NSString *industry = self.industryTextField.text;
//    NSString *industry_id = [NSString stringWithFormat:@"%d", _industryID.intValue];
//    
//    if([email length] == 0 || [password length] == 0 || [confirmPassword length] == 0){
//        return;
//    }
//    
//    if ([email rangeOfString:@"@"].location == NSNotFound) {
//        [self.emailTextField becomeFirstResponder];
//        [self alertErrorMessage:@"INVALID_EMAIL"];
//        return;
//    }
//    
//    if([password length] < 6 || [confirmPassword length] < 6){
//        [self.passwordTextField becomeFirstResponder];
//        [self alertErrorMessage:@"PASSWORD_REQUIREMENT"];
//        return;
//    }
//    
//    if([password isEqualToString:confirmPassword] == NO){
//        [self.confirmPasswordTextField becomeFirstResponder];
//        [self alertErrorMessage:@"PASSWORDS_DO_NOT_MATCH"];
//        return;
//    }
//    
//    
//    NSMutableDictionary *post = [NSMutableDictionary dictionary];
//    
//    [post setValue:email forKey:@"user[email]"];
//    [post setValue:password forKey:@"user[password]"];
//    [post setValue:confirmPassword forKey:@"user[password_confirmation]"];
//    [post setValue:company forKey:@"company"];
//    [post setValue:industry forKey:@"industry"];
//    [post setValue:industry_id forKey:@"industry_id"];
//    [post setValue:@"iphone" forKey:@"source"];
//    [post setValue:[[NSLocale currentLocale] localeIdentifier] forKey:@"locale"];
//    
//    [_api makeRequest:@"/register.json" withParams:post withBlock:^(BOOL requestSucceeded, NSDictionary *response) {
//        
//        if(requestSucceeded){
//            
//            NSDictionary *user = response[@"user"];
//            
//            CTLCDAccount *account = [CTLCDAccount MR_createEntity];
//            account.email = email;
//            account.company = company;
//            account.industry = industry;
//            account.industry_id = _industryID;
//            account.password = password;
//            account.created_at = [NSDate date];
//            
//            account.auth_token = response[kCTLAuthTokenKey];
//            account.user_id = @([user[@"id"] intValue]);
//            account.is_pro = @(1);
//            
//            //account.company_idValue = [user[@"company_id"] intValue];
//            //account.industry_idValue = [user[@"industry_id"] intValue];
//            
//            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
//                
//                [[NSUserDefaults standardUserDefaults] setValue:[response objectForKey:kCTLAuthTokenKey] forKey:kCTLAccountAccessToken];
//                
//                
//                [self.menuController setRightSwipeEnabled:YES];
//                
//                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle:[NSBundle mainBundle]];
//                UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"inboxInterstitialNavigationController"];
//                
//                CTLInboxInterstitialViewController<CTLSlideMenuDelegate> *inboxInterstitial = (CTLInboxInterstitialViewController<CTLSlideMenuDelegate> *)navigationController.topViewController;
//                
//                [inboxInterstitial setMenuController:self.menuController];
//                [self.menuController setMainViewController:inboxInterstitial];
//                [self.menuController flipToView];
//            }];
//            
//            
//        }else{
//            
//            NSString *message = [CTLAPI messageFromResponse:response];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                            message:message
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil, nil];
//            [alert show];
//        }
//    }];
//}

- (void)alertErrorMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:NSLocalizedString(message, nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
}

@end
