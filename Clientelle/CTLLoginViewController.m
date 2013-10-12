//
//  CTLLoginViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 2/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLNetworkClient.h"

#import "CTLLoginViewController.h"
#import "UITableViewCell+CellShadows.h"
#import "CTLAccountManager.h"

@implementation CTLLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.navigationItem.title = NSLocalizedString(@"LOGIN", nil);
    
    if(self.emailAddress){
        self.emailTextField.text = self.emailAddress;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell addShadowToCellInGroupedTableView:self.tableView atIndexPath:indexPath];
    return cell;
}

- (IBAction)login:(id)sender
{
    if([self.emailTextField.text length] == 0 || [self.passwordTextField.text length] == 0){
        return;
    }
    
    if([self.emailTextField.text rangeOfString:@"@"].location == NSNotFound){
        [self displayAlert:NSLocalizedString(@"INVALID_EMAIL", nil)];
        return;
    }
    
    if([self.passwordTextField.text length] < 6){
        [self displayAlert:NSLocalizedString(@"PASSWORD_REQUIREMENT", nil)];
        return;
    }
    
    NSDictionary *credentials = @{@"user[email]":self.emailTextField.text, @"user[password]":self.passwordTextField.text};
    
    [[CTLAccountManager sharedInstance] loginWith:credentials onComplete:^(NSDictionary *responseObject){
        //TODO: Flip to logged-in view        
    } onError:^(NSError *error){
        [self displayAlert:[error localizedDescription]];
    }];
}

- (void)displayAlert:(NSString *)alertMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}


- (IBAction)forgotPassword:(id)sender
{
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DevConfig" ofType:@"plist"]];
    NSURL *forgotPasswordURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/forgot-password?email=%@", [plist objectForKey:@"mobileRoot"], self.emailTextField.text]];
    [[UIApplication sharedApplication] openURL:forgotPasswordURL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
