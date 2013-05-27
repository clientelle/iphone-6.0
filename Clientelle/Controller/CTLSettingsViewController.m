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
     
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SETTINGS", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    self.navigationItem.title = NSLocalizedString(@"SETTINGS", nil);
    
    [self.menuController setRightSwipeEnabled:NO];
    
    _account = [CTLCDAccount MR_findFirst];
    
    //Set the notification switch
    [self.notificationSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kCTLSettingsNotification]];
    
    if(!_account){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UPGRADE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(toAccountFormView:)];
    }
    
    self.tableView.backgroundColor = [UIColor colorFromUnNormalizedRGB:206.0f green:206.0f blue:206.0f alpha:1.0f];
    [self.tableView setSeparatorColor:[UIColor colorFromUnNormalizedRGB:247.0f green:247.0f blue:247.0f alpha:1.0f]];
    
    [self configureCells];
}

- (void)upgradeToPro:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Purchase Pro?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Purchase", nil];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [self performSegueWithIdentifier:CTLAccountSegueIdentifyer sender:alertView];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell addShadowToCellInGroupedTableView:self.tableView atIndexPath:indexPath];
    return cell;
}

- (void)configureCells
{
    /* Using static table cells so I style them here instead of cellForRowAtIndexPath */
    
    UITableViewCell *accountTypeCell = [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self styleLabel:accountTypeCell.textLabel withText:NSLocalizedString(@"ACCOUNT_TYPE", nil)];
    accountTypeCell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    if([_account objectID]){
        self.accountTypeCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.accountTypeCell.detailTextLabel.text = NSLocalizedString(@"PRO", nil);
    }else{
        self.accountTypeCell.detailTextLabel.text = NSLocalizedString(@"FREE", nil);
    }
    
    UITableViewCell *notificationCell = [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [self styleLabel:notificationCell.textLabel withText:NSLocalizedString(@"NOTIFICATIONS", nil)];
    
    UITableViewCell *pinCell = [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [self styleLabel:pinCell.textLabel withText:NSLocalizedString(@"CONFIGURE_PIN_ACCESS", nil)];
    
    pinCell.detailTextLabel.text = NSLocalizedString(@"REQUIRES_A_PASSCODE", nil);
    pinCell.detailTextLabel.backgroundColor = [UIColor clearColor];

    UITableViewCell *supportCell = [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [self styleLabel:supportCell.textLabel withText:NSLocalizedString(@"REPORT_A_PROBLEM", nil)];
    
    UITableViewCell *featureCell = [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    [self styleLabel:featureCell.textLabel withText:NSLocalizedString(@"REQUEST_A_FEATURE", nil)];
    
    UITableViewCell *shareCell = [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
    [self styleLabel:shareCell.textLabel withText:NSLocalizedString(@"TELL_A_FRIEND", nil)];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(indexPath.row == 2){
            [self performSegueWithIdentifier:@"toSetPin" sender:nil];
//            if(![_account objectID]){
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"FEATURE_REQUIRES_PRO", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                
//                [alertView show];
//            }else{
//                [self performSegueWithIdentifier:@"toSetPin" sender:nil];
//            }
        }
    }
    
    if(indexPath.section == 1){
        if (indexPath.row == 0) {
            [self didTouchFeedbackCell];
        }
        if(indexPath.row == 1){
            [self didTouchShareWithFriendCell];
        }
    }
}

- (void)styleLabel:(UILabel *)label withText:(NSString *)text
{
    [label setFont:[UIFont fontWithName:kCTLAppFont size:15]];
    label.backgroundColor = [UIColor clearColor];
    label.text = text;
}


- (void)toAccountFormView:(id)sender
{
    [self performSegueWithIdentifier:CTLAccountSegueIdentifyer sender:self];
}

- (IBAction)toggleNotificationSetting:(UISwitch *)notificationSwitch
{
    [[NSUserDefaults standardUserDefaults] setBool:notificationSwitch.isOn forKey:kCTLSettingsNotification];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:CTLAccountSegueIdentifyer]){
        if([_account objectID]){
            CTLRegisterViewController *controller = [segue destinationViewController];
            [controller setAccount:_account];
        }
        return;
    }
}

- (void)didTouchFeedbackCell
{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setToRecipients:@[kFeedbackEmail]];
    [mailComposer setMailComposeDelegate:self];
    [mailComposer setSubject:NSLocalizedString(@"IPHONE_FEEDBACK_SUBJECT", @"iPhone Feedback")];
    [self presentViewController:mailComposer animated:YES completion:^{ }];
}

- (void)didTouchShareWithFriendCell
{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setToRecipients:@[kFeedbackEmail]];
    [mailComposer setMailComposeDelegate:self];
    [mailComposer setSubject:NSLocalizedString(@"IPHONE_FEEDBACK_SUBJECT", @"iPhone Feedback")];
    [self presentViewController:mailComposer animated:YES completion:^{ }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{ }];
}


@end
