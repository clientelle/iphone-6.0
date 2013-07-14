//
//  CTLAccountViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAPI.h"
#import "UIColor+CTLColor.h"
#import "UITableViewCell+CellShadows.h"
#import "NSDate+CTLDate.h"
#import "CTLAccountViewController.h"
#import "CTLContainerViewController.h"

#import "CTLAccountManager.h"
#import "CTLCDAccount.h"

@interface CTLAccountViewController()

@property(nonatomic, strong) CTLAPI *api;
@property(nonatomic, strong) UIPickerView *industryPicker;
@property(nonatomic, strong) NSArray *industries;
@property(nonatomic, strong) NSNumber *industryID;

@end

@implementation CTLAccountViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.currentUser = self.containerView.currentUser;
     
    self.industryPicker = [self configureIndustryPicker];
    
    self.industryTextField.inputView = self.industryPicker;
    self.industryTextField.tag = 170;

    self.firstNameTextField.placeholder = NSLocalizedString(@"FIRST_NAME", nil);
    self.lastNameTextField.placeholder = NSLocalizedString(@"LAST_NAME", nil);
    self.companyTextField.placeholder = NSLocalizedString(@"COMPANY_NAME", nil);
    self.industryTextField.placeholder = NSLocalizedString(@"INDUSTRY", nil);

    self.accountEmailLabel.text = NSLocalizedString(@"ACCOUNT_EMAIL", nil);
    self.accountAgeLabel.text = NSLocalizedString(@"ACCOUNT_AGE", nil);
    
    if(self.currentUser){
        
        self.navigationItem.title = NSLocalizedString(@"YOUR_ACCOUNT", nil);
          
        self.industryID = self.currentUser.industry_id;
        self.firstNameTextField.text = self.currentUser.first_name;
        self.lastNameTextField.text = self.currentUser.last_name;
        self.companyTextField.text = self.currentUser.company;
        self.industryTextField.text = self.currentUser.industry;
        
        self.emailLabel.text = [self.currentUser email];
        self.daysLabel.text = [self dateAgo:self.currentUser.created_at];
                
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

- (IBAction)submit:(id)sender
{
    NSDictionary *accountDict = [self validateFields];    
    if (accountDict) {                
        [CTLAccountManager updateAccount:accountDict withUser:self.currentUser completionBlock:^(BOOL success, CTLCDAccount *account, NSError *error) {
            if(success){
                self.currentUser = account;
                [self.navigationController popViewControllerAnimated:YES];            
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message: [error localizedDescription]
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
    NSArray *fields = @[self.firstNameTextField, self.lastNameTextField, self.companyTextField, self.industryTextField];
    
    for(int i=0;i<[fields count]; i++){
        UITextField *textField = fields[i];
        if([textField.text length] == 0){
            textField.backgroundColor = [UIColor ctlErrorPink];
        }
    }
    
    NSString *first_name = self.firstNameTextField.text;
    NSString *last_name = self.lastNameTextField.text;
    NSString *company = self.companyTextField.text;
    NSString *industry = self.industryTextField.text;
    NSString *industry_id = [NSString stringWithFormat:@"%d", self.industryID.intValue];
    
    //required fields. thow shall now pass!
    if ([first_name length] == 0 &&
        [last_name length]  == 0 &&
        [company length]    == 0 &&
        [industry length]   == 0 ){
        //form is empty!
        return nil;
    }
    
    NSDictionary *accountDict = @{ @"first_name":first_name, @"last_name":last_name, @"company":company, @"industry":industry, @"industry_id":industry_id };
    return accountDict;
    
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
