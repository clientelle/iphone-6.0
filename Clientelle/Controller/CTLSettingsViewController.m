//
//  CTLSettingsViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "UITableViewCell+CellShadows.h"
#import "UIColor+CTLColor.h"

#import "CTLContainerViewController.h"
#import "CTLSettingsViewController.h"
#import "CTLRegisterViewController.h"
#import "CTLAccountViewController.h"
#import "CTLAccountsViewController.h"

#import "CTLAccountManager.h"
#import "CTLCDAccount.h"

NSString *const CTLAccountSegueIdentifyer = @"toAccountView";
NSString *const CTLAccountsSegueIdentifyer = @"toAccounts";
NSString *const CTLSignupSegueIdentifyer = @"toSignup";

@interface CTLSettingsViewController()

@property (nonatomic, strong) CTLCDAccount *currentUser;
@property (nonatomic, strong) UIAlertView *purchaseAlertView;
@property (nonatomic, assign) BOOL hasManyAccounts;

@end

@implementation CTLSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
     
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SETTINGS", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    self.navigationItem.title = NSLocalizedString(@"SETTINGS", nil);
    
    [self.containerView setRightSwipeEnabled:NO];
    self.currentUser = [CTLAccountManager currentUser];
    
    
    NSLog(@"CRRENT ACCT %@", self.currentUser);
    
    //Set the notification switch
    [self.appointmentNotificationSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kCTLSettingsAppointmentNotification]];
    [self.messageNotificationSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kCTLSettingsAppointmentNotification]];

    if(!self.currentUser.is_proValue){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UPGRADE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(upgradeToPro:)];
    }
    
    self.tableView.backgroundColor = [UIColor colorFromUnNormalizedRGB:206.0f green:206.0f blue:206.0f alpha:1.0f];
    [self.tableView setSeparatorColor:[UIColor colorFromUnNormalizedRGB:247.0f green:247.0f blue:247.0f alpha:1.0f]];

    self.hasManyAccounts = [CTLCDAccount countOfEntities] > 1;    
    
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
        [self performSegueWithIdentifier:CTLSignupSegueIdentifyer sender:alertView];
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
    if(self.hasManyAccounts){
        self.accountTypeCell.textLabel.text = NSLocalizedString(@"LOGGED_IN_AS", nil);
        self.accountTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.accountTypeCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.currentUser.email];
    }else{
                
        if(self.currentUser.is_proValue){
            self.accountTypeCell.textLabel.text = NSLocalizedString(@"LOGGED_IN_AS", nil);
            self.accountTypeCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.currentUser.email];
            self.accountTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            self.accountTypeCell.textLabel.text = NSLocalizedString(@"ACCOUNT_TYPE", nil);
            self.accountTypeCell.detailTextLabel.text = NSLocalizedString(@"FREE", nil);            
            self.accountTypeCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    self.accountTypeCell.detailTextLabel.textColor = [UIColor ctlGreen];
    
    self.appointmentNotificationCell.textLabel.text = NSLocalizedString(@"APPT_NOTIFICATIONS", nil);
    self.appointmentNotificationCell.textLabel.font = [UIFont fontWithName:kCTLAppFontMedium size:14];
    self.appointmentNotificationCell.textLabel.backgroundColor = [UIColor clearColor];
    
    self.messageNotificationCell.textLabel.text = NSLocalizedString(@"MSG_NOTIFICATIONS", nil);
    self.messageNotificationCell.textLabel.font = [UIFont fontWithName:kCTLAppFontMedium size:14];
    self.messageNotificationCell.textLabel.backgroundColor = [UIColor clearColor];
        
    self.pinCell.textLabel.text = NSLocalizedString(@"CONFIGURE_PIN_ACCESS", nil);
    self.supportCell.textLabel.text = NSLocalizedString(@"REPORT_A_PROBLEM", nil);
    self.featureCell.textLabel.text = NSLocalizedString(@"REQUEST_A_FEATURE", nil);
    self.shareCell.textLabel.text = NSLocalizedString(@"TELL_A_FRIEND", nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(indexPath.row == 0){            
            if(self.hasManyAccounts){
                [self performSegueWithIdentifier:CTLAccountsSegueIdentifyer sender:nil];
            }else if(self.currentUser.is_proValue){
                [self performSegueWithIdentifier:CTLAccountSegueIdentifyer sender:self.currentUser];
            }           
        }
        if(indexPath.row == 3){
            if(![self.currentUser objectID]){
                [self upgradeToPro:nil];
            }else{
                [self performSegueWithIdentifier:@"toSetPin" sender:nil];
            }
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

- (IBAction)toggleNotificationSetting:(UISwitch *)notificationSwitch
{
    if(notificationSwitch.tag == 1){
        [[NSUserDefaults standardUserDefaults] setBool:notificationSwitch.isOn forKey:kCTLSettingsAppointmentNotification];
    }else if(notificationSwitch.tag == 2){
        [[NSUserDefaults standardUserDefaults] setBool:notificationSwitch.isOn forKey:kCTLSettingsMessageNotification]; 
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:CTLSignupSegueIdentifyer]){
        CTLRegisterViewController *controller = [segue destinationViewController];
        [controller setShowMenuButton:NO];
        return;
    }
    
    if([[segue identifier] isEqualToString:CTLAccountSegueIdentifyer]){
        CTLCDAccount *account = (CTLCDAccount *)sender;
        CTLAccountViewController *controller = [segue destinationViewController];
        [controller setAccount:account];
        [controller setContainerView:self.containerView];      
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
