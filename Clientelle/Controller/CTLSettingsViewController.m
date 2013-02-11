//
//  CTLSettingsViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLSettingsViewController.h"


#import "CTLRegisterViewController.h"
#import "CTLCDAccount.h"

NSString *const CTLAccountSegueIdentifyer = @"toAccountInfo";

@interface CTLSettingsViewController ()

@end

@implementation CTLSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _account = [CTLCDAccount MR_findFirst];
    
    //Set the notification switch
    [self.notificationSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kCTLSettingsNotification]];
    
    if([_account objectID]){
        
        //view & edit account info
        self.actionButton = [[UIBarButtonItem alloc] initWithTitle:@"Acount" style:UIBarButtonItemStylePlain target:self action:@selector(toAccountFormView:)];
        self.navigationItem.rightBarButtonItem = self.actionButton;
        
        //When account has bene purchased, there should be a checkbox and label that says "Paid"
        [self.changeAccountTypeButton setTitle:@"Paid" forState:UIControlStateNormal];
        self.accountTypeCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        
        self.actionButton = [[UIBarButtonItem alloc] initWithTitle:@"Re" style:UIBarButtonItemStylePlain target:self action:@selector(toAccountFormView:)];
        self.navigationItem.rightBarButtonItem = self.actionButton;
        
        [self.changeAccountTypeButton setTitle:@"Free" forState:UIControlStateNormal];
        self.accountTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
}

- (void)toAccountFormView:(id)sender {
    [self performSegueWithIdentifier:CTLAccountSegueIdentifyer sender:self];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (IBAction)dismissKeyboard:(UITapGestureRecognizer *)recognizer{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleNotificationSetting:(id)sender{
    
    UISwitch *notificationSwitch = sender;
    
    NSLog(@"TURNING %i", notificationSwitch.isOn);
    
    [[NSUserDefaults standardUserDefaults] setBool:notificationSwitch.isOn forKey:kCTLSettingsNotification];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:CTLAccountSegueIdentifyer]){
        if([_account objectID]){
            CTLRegisterViewController *controller = [segue destinationViewController];
            [controller setCdAccount:_account];
        }
        return;
    }
}



@end
