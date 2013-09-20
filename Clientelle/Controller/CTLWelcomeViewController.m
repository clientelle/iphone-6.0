//
//  CTLWelcomeViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 7/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "UILabel+CTLLabel.h"
#import "UIColor+CTLColor.h"
#import "CTLWelcomeViewController.h"
#import "CTLContactsListViewController.h"
#import "CTLAccountManager.h"
#import "CTLCDAccount.h"

@interface CTLWelcomeViewController()
@property (nonatomic, strong) UIPickerView *industryPicker;
@property (nonatomic, strong) NSArray *industries;
@property (nonatomic, strong) NSNumber *industryID;
@end


@implementation CTLWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];	
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"WELCOME", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@!", NSLocalizedString(@"WELCOME", nil)];
    
    [self configureRegistrationForm];
    
    
    self.registerButton.titleLabel.text = NSLocalizedString(@"CREATE_NEW_ACCOUNT", nil);
    self.loginButton.titleLabel.text = NSLocalizedString(@"ALREADY_HAVE_AN_ACCOUNT", nil);
    
    [UILabel autoWidth:self.registerButton.titleLabel];
    [UILabel autoWidth:self.loginButton.titleLabel];
    
    self.learnMoreView.alpha = 0;
    [self.view bringSubviewToFront:self.learnMoreView];
    [self showLearnMoreView:nil];
     
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissLearnMorePopup:)];    
    [self.learnMoreView addGestureRecognizer:tap];
}

- (void)configureRegistrationForm
{
    self.industryID = @(0);
    self.industryPicker = [self configureIndustryPicker];
    
    self.industryTextField.inputView = self.industryPicker;
    self.industryTextField.tag = 170;
    
    [self translateInputPlaceholders];
}

- (void)translateInputPlaceholders
{
    self.emailTextField.placeholder = NSLocalizedString(@"EMAIL_ADDRESS", nil);
    self.companyTextField.placeholder = NSLocalizedString(@"COMPANY_NAME", nil);
    self.industryTextField.placeholder = NSLocalizedString(@"INDUSTRY", nil);
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

- (void)showLearnMoreView:(id)sender
{
    self.learnMoreView.hidden = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    [UIView beginAnimations:@"fadeIn" context:nil];
    self.learnMoreView.alpha = 0.8f;
    [UIView commitAnimations];    
}

- (IBAction)dismissLearnMorePopup:(id)sender
{
    [UIView beginAnimations:@"fadeOut" context:nil];
    self.learnMoreView.alpha = 0;
    [UIView commitAnimations];
    
    self.learnMoreView.hidden = YES;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"more" style:UIBarButtonItemStylePlain target:self action:@selector(showLearnMoreView:)];
   
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

- (void)displayErrorMessage:(NSString *)errorMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:errorMessage
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)submit:(id)sender
{       
    NSDictionary *accountDict = [self validateFields];
    if(accountDict){
        [[CTLAccountManager sharedInstance] createAccount:accountDict onComplete:^(NSDictionary *responseObject){
            [self flipToContactsView];
        } onError:^(NSError *error){
            [self displayErrorMessage:[error localizedDescription]];
        }];
    }
}

- (void)flipToContactsView
{
    [self.containerView setRightSwipeEnabled:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Contacts" bundle:[NSBundle mainBundle]];
    
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateInitialViewController];
    
    CTLContactsListViewController<CTLContainerViewDelegate> *contactsListController = (CTLContactsListViewController<CTLContainerViewDelegate> *)navigationController.topViewController;
    
    [self.containerView setMainViewController:contactsListController];
    [self.containerView flipToView];
    [self.containerView renderMenuButton:contactsListController];
    [contactsListController.navigationItem setHidesBackButton:YES animated:YES];
}

- (NSDictionary *)validateFields
{
    NSArray *fields = @[self.emailTextField, self.companyTextField, self.industryTextField];
    
    for(int i=0;i<[fields count]; i++){
        UITextField *textField = fields[i];
        if([textField.text length] == 0){
            textField.backgroundColor = [UIColor ctlErrorPink];
        }
    }
    
    NSString *email = self.emailTextField.text;
    NSString *company = self.companyTextField.text;
    NSString *industry = self.industryTextField.text;
    
    //required fields. thow shall now pass!
    if([email length] == 0){
        return nil;
    }
    
    if ([email rangeOfString:@"@"].location == NSNotFound) {
        [self.emailTextField becomeFirstResponder];
        [self displayErrorMessage:NSLocalizedString(@"INVALID_EMAIL", nil)];
        return nil;
    }
    
    NSString *password = [[CTLAccountManager sharedInstance] generatePassword];
    
    NSDictionary *accountDict = @{ @"email":email, @"password":password, @"company":company, @"industry":industry, @"industry_id":self.industryID };
    return accountDict;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [self performSegueWithIdentifier:@"toLogin" sender:alertView];
    }
}


@end
