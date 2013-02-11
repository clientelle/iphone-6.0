//
//  CTLRegisterViewController.m
//  Clientelle
//
//  Created by Samuel Goodwin on 4/11/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import "CTLAPI.h"
#import "CTLSlideMenuController.h"
#import "CTLRegisterViewController.h"
#import "CTLCDAccount.h"

NSString *const CTLReloadInboxNotifiyer = @"com.clientelle.notificationKeys.reloadInbox";

@interface CTLRegisterViewController ()

@end

@implementation CTLRegisterViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
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
    }
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEditing:)];
    
    [self.view addGestureRecognizer:tapGesture];

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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops :(" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){

        //create dictionary from coredata "account" entity
        NSMutableDictionary *personDict = [[NSMutableDictionary alloc] initWithDictionary:[account dictionaryWithValuesForKeys:@[@"email",@"password",@"company",@"industry"]]];
        
        //add some meta data
        NSString *locale = [[NSLocale currentLocale] localeIdentifier];
        [personDict setValue:locale forKey:@"locale"];
        [personDict setValue:@"iphone" forKey:@"source"];
        
        [self createDefaultInboxes];
        
[[NSNotificationCenter defaultCenter] postNotificationName:CTLReloadInboxNotifiyer object:account];
[self.navigationController popViewControllerAnimated:YES];
        
        
        /*
        [_api makeRequest:@"/register" withParams:personDict withBlock:^(BOOL requestSucceeded, NSDictionary *response) {
            if(requestSucceeded){
                 
                 NSLog(@"RESPONSE %@", response);
                //[self createDefaultInboxes];
                 
                [[NSUserDefaults standardUserDefaults] setValue:[response objectForKey:kCTLAccessTokenKey] forKey:kCTLAccountAccessToken];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:CTLReloadInboxNotifiyer object:account];
                [self.navigationController popViewControllerAnimated:YES];
                                  
            }else{
                NSLog(@"RESPONSE %@", response);
                NSString *message = [CTLAPI messageFromResponse:response];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops :(" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
        
            }
         }];
         */
    }];
}

- (IBAction)seeActivity:(id)sender {
    
    CTLAPI *api = [CTLAPI sharedAPI];
    [api makeRequest:@"/activity" withParams:@{} withBlock:^(BOOL result, NSDictionary *response) {
        if(result){
            NSLog(@"RESULT %@", response);
        }
    }];
}

- (void)createDefaultInboxes {
    /*
    CTLCDWebForm *leadsForm = [CTLCDWebForm MR_createEntity];
    leadsForm.title = @"Contact Us";
    leadsForm.inboxName = @"Leads";
    leadsForm.url = @"https://api.clientelle.com/43430323";
    
     */
     
    /* CREATE LEAD FORM */
    
    /*
    NSDictionary *nameField = @{@"type":@"text",@"name":@"name",@"label":@"Name",@"placeholder":@"Full Name"};
    NSDictionary *emailField = @{@"type":@"text",@"name":@"email",@"label":@"Email",@"placeholder":@"Email Address"};
    NSDictionary *questionField = @{@"type":@"textView",@"name":@"question",@"label":@"Question",@"placeholder":@"Question"};


    NSArray *leadFormFields = [[NSMutableArray alloc] initWithObjects:nameField, emailField, questionField, nil];
    
    
    NSError *leadFormError = nil;
    leadsForm.formJSON = [NSJSONSerialization dataWithJSONObject:leadFormFields options:0 error:&leadFormError];
*/
       
    /* CREATE APPOINTMENT FORM */

/*
    CTLCDWebForm *appointmentForm = [CTLCDWebForm MR_createEntity];
    appointmentForm.title = @"Request an Appointment";
    appointmentForm.inboxName = @"Appointments";
    appointmentForm.url = @"https://api.clientelle.com/43430323";
    

    NSDictionary *contactField = @{@"type":@"text",@"name":@"name",@"label":@"Name",@"placeholder":@"Full Name"};
    NSDictionary *timeField = @{@"type":@"text",@"name":@"email",@"label":@"Time",@"placeholder":@"Time to meet"};
   
    
    NSArray *apptFormFields = [[NSMutableArray alloc] initWithObjects:contactField, timeField, nil];
    
    
    NSError *apptFormError = nil;
    appointmentForm.formJSON = [NSJSONSerialization dataWithJSONObject:apptFormFields options:0 error:&apptFormError];
    
*/
    
    /*
         
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveErrorHandler:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to create account!" message:[[error userInfo] description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        
        NSLog(@"ERRLOG %@", [[error userInfo] description]);
        [alert show];
    }];
*/
}

@end
