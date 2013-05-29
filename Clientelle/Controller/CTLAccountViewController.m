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
#import "NSDate+CTLDate.h"
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
    self.companyTextField.placeholder = NSLocalizedString(@"COMPANY_NAME", nil);
    self.industryTextField.placeholder = NSLocalizedString(@"INDUSTRY", nil);

    self.accountEmailLabel.text = NSLocalizedString(@"ACCOUNT_EMAIL", nil);
    self.accountAgeLabel.text = NSLocalizedString(@"ACCOUNT_AGE", nil);
    
    if(_account){
        
        self.navigationItem.title = NSLocalizedString(@"YOUR_ACCOUNT", nil);
        
        self.account = _account;
        _industryID = self.account.industry_id;
        self.firstNameTextField.text = [self.account first_name];
        self.lastNameTextField.text = [self.account last_name];
        self.companyTextField.text = [self.account company];
        self.industryTextField.text = [self.account industry];
        
        self.emailLabel.text = [self.account email];
        self.daysLabel.text = [self dateAgo:self.account.created_at];
                
    }else{
        self.navigationItem.title = NSLocalizedString(@"CREATE_ACCOUNT", nil);
    }
     
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEditing:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (NSString *)dateAgo:(NSDate *)cakeDay
{
    NSDate *todaysDate = [NSDate date];
    NSTimeInterval lastDiff = [cakeDay timeIntervalSinceNow];
    NSTimeInterval todaysDiff = [todaysDate timeIntervalSinceNow];
    NSTimeInterval dateDiff = lastDiff - todaysDiff;
    NSTimeInterval days = (dateDiff * -1)/86400;
    
    if(days < 1){
        return @"1 d";
    }
    
    return [NSString stringWithFormat:@"%f d", round(days)];
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

- (IBAction)submit:(id)sender{
    
    //TODO: loading 
    NSString *first_name = self.firstNameTextField.text;
    NSString *last_name = self.lastNameTextField.text;
    NSString *company = self.companyTextField.text;
    NSString *industry = self.industryTextField.text;
    NSString *industry_id = [NSString stringWithFormat:@"%d", _industryID.intValue];
    
    if([first_name length] == 0 ||
       [last_name length] == 0 ||
       [company length] == 0 ||
       [industry length] == 0){
        return;
    }    
    
    NSMutableDictionary *post = [NSMutableDictionary dictionary];
    [post setValue:_account.user_id forKey:@"id"];
    [post setValue:first_name forKey:@"user[first_name]"];
    [post setValue:last_name forKey:@"user[last_name]"];
    [post setValue:company forKey:@"company[name]"];
    [post setValue:industry forKey:@"industry[name]"];
    [post setValue:industry_id forKey:@"industry[id]"];
        
    NSString *path = [NSString stringWithFormat:@"/account/%@/?auth_token=%@&format=json", _account.user_id, _account.auth_token];
    [_api makeRequest:path withParams:post method:GOHTTPMethodPUT withBlock:^(BOOL requestSucceeded, NSDictionary *response) {
        
        if(requestSucceeded){

            _account.first_name = first_name;
            _account.last_name = last_name;
            _account.company = company;
            _account.industry = industry;
            
            if(response[@"user"]){
                if(response[@"user"][@"industry"]){
                    _account.industry_id = response[@"user"][@"industry"][@"id"];
                }
            }        
            
            _account.updated_at = [NSDate date];
            
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
                //TODO: dismiss loading screen
                [self.navigationController popViewControllerAnimated:YES];
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

- (void)alertErrorMessage:(NSString *)i18nKey
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:NSLocalizedString(i18nKey, nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
}

@end
