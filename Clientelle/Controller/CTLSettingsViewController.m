//
//  CTLSettingsViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//
#import "CTLSlideMenuController.h"
#import "CTLSettingsViewController.h"
#import "CTLRegisterViewController.h"
#import "CTLCDAccount.h"
#import "UITableViewCell+CellShadows.h"
#import "UIColor+CTLColor.h"
#import <MessageUI/MessageUI.h>

NSString *const CTLAccountSegueIdentifyer = @"toAccountInfo";

@implementation CTLSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.menuController setRightSwipeEnabled:NO];
    
    _account = [CTLCDAccount MR_findFirst];
    
    //Set the notification switch
    [self.notificationSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kCTLSettingsNotification]];
    
    if([_account objectID]){
        
        //view & edit account info
        self.actionButton = [[UIBarButtonItem alloc] initWithTitle:@"Acount" style:UIBarButtonItemStylePlain target:self action:@selector(toAccountFormView:)];
        self.navigationItem.rightBarButtonItem = self.actionButton;
        
        //When account has bene purchased, there should be a checkbox and label that says "Paid"
        //[self.changeAccountTypeButton setTitle:@"Paid" forState:UIControlStateNormal];
        self.accountTypeCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        
        self.actionButton = [[UIBarButtonItem alloc] initWithTitle:@"Re" style:UIBarButtonItemStylePlain target:self action:@selector(toAccountFormView:)];
        self.navigationItem.rightBarButtonItem = self.actionButton;
        
        //[self.changeAccountTypeButton setTitle:@"Free" forState:UIControlStateNormal];
        self.accountTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    self.tableView.backgroundColor = [UIColor colorFromUnNormalizedRGB:206.0f green:206.0f blue:206.0f alpha:1.0f];
    [self.tableView setSeparatorColor:[UIColor colorFromUnNormalizedRGB:247.0f green:247.0f blue:247.0f alpha:1.0f]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell addShadowToCellInGroupedTableView:self.tableView atIndexPath:indexPath];
    return cell;
}

- (void)viewWillAppear:(BOOL)animated
{
    /* Using static table cells so I style them here instead of cellForRowAtIndexPath */
    
    UITableViewCell *accountTypeCell = [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self styleLabel:accountTypeCell.textLabel withText:NSLocalizedString(@"ACCOUNT_TYPE", nil)];
    [accountTypeCell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica" size:13]];
    accountTypeCell.detailTextLabel.text = NSLocalizedString(@"PAID", nil);
    accountTypeCell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    UITableViewCell *notificationCell = [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [self styleLabel:notificationCell.textLabel withText:NSLocalizedString(@"NOTIFICATIONS", nil)];
    
    UITableViewCell *supportCell = [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [self styleLabel:supportCell.textLabel withText:NSLocalizedString(@"SUPPORT_FEATURES", nil)];
    
    UITableViewCell *shareCell = [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    [self styleLabel:shareCell.textLabel withText:NSLocalizedString(@"TELL_A_FRIEND", nil)];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"INDEXPATH %@", indexPath);
    
    if (indexPath.row == 0 && indexPath.section == 1) {
        // feedback cell
        [self didTouchFeedbackCell];
    }
    
}

- (void)styleLabel:(UILabel *)label withText:(NSString *)text
{
    [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    label.backgroundColor = [UIColor clearColor];
    label.text = text;
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

- (void)didTouchFeedbackCell {
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setToRecipients:@[kFeedbackEmail]];
    [mailComposer setMailComposeDelegate:self];
    [mailComposer setSubject:NSLocalizedString(@"IPHONE_FEEDBACK_SUBJECT",@"iPhone Feedback")];
    [self presentViewController:mailComposer animated:YES completion:^{
        //
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 //
                             }];
}


@end
