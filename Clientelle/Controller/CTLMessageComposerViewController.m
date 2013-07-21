//
//  CTLMessageComposerViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 6/17/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "UILabel+CTLLabel.h"
#import "NSString+CTLString.h"
#import "UIColor+CTLColor.h"
#import "CTLViewDecorator.h"

#import "CTLMessageComposerViewController.h"
#import "CTLContactImportViewController.h"
#import "CTLContactsListViewController.h"
#import "CTLContactDetailsViewController.h"
#import "CTLMessengerInviteView.h"

#import "CTLAPI.h"
#import "CTLCDContact.h"
#import "CTLCDConversation.h"
#import "CTLCDMessage.h"
#import "CTLAutoCompleteTableView.h"
#import "CTLAccountManager.h"
#import "CTLCDAccount.h"
#import "CTLMessageManager.h"

int const CTLContactPickerRowHeight = 35.0f;

@interface CTLMessageComposerViewController ()
@property (nonatomic, strong) CTLCDMessage *message;
@property (nonatomic, strong) CTLCDContact *contact;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *filteredContacts;
@property (nonatomic, assign) BOOL hasAppliedShadowToDropdown;
@property (nonatomic, strong) CTLCDAccount *current_user;

@end

@implementation CTLMessageComposerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.current_user = [CTLAccountManager currentUser];
    
    self.navigationItem.title = NSLocalizedString(@"COMPOSE_MESSSAGE", nil);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    
    self.contacts = [CTLCDContact MR_findAllSortedBy:@"lastAccessed" ascending:NO];
    self.filteredContacts = [self.contacts mutableCopy];
            
    self.hasAppliedShadowToDropdown = NO;
    
    [self drawDottedLines];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactWasAdded:) name:CTLNewContactWasAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactsWereImported:) name:CTLContactsWereImportedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.addContactButton.hidden = ([self.contacts count] > 0);
}

- (void)contactWasAdded:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[CTLCDContact class]]){
        self.contact = notification.object;
        self.contacts = @[self.contact];
        self.recipientTextField.text = self.contact.compositeName;
        self.addContactButton.hidden = YES;
    }
}

- (void)contactsWereImported:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[NSMutableArray class]]){
        self.addContactButton.hidden = YES;
        self.contacts = [NSArray arrayWithArray:notification.object];        
        self.filteredContacts = [self.contacts mutableCopy];        

        if([self.contacts count] == 1){
            self.contact = self.contacts[0];
            self.recipientTextField.text = self.contact.compositeName;
            [self.messageTextView becomeFirstResponder];
        }else{
            [self showContactsAutocomplete];
        }
    }
}

#pragma mark TableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CTLContactPickerRowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"contactRow";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    CTLCDContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    
    if(contact.user_idValue == 0){
        
        UIButton *accessory = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [accessory setUserInteractionEnabled:NO];
        [cell setAccessoryView:accessory];
    }

    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.contact = [self.filteredContacts objectAtIndex:indexPath.row];    
    self.recipientTextField.text = self.contact.compositeName;
    [self.recipientTextField resignFirstResponder];
    [self.messageTextView becomeFirstResponder];

    //hide tableview after they chose a contact
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.alpha = 0;
        self.tableView.layer.shadowOpacity = 0;
    } completion:^(BOOL finished){
        self.tableView.hidden = YES;
        self.tableView.layer.shadowOpacity = 0.75f;
    }];
}

#pragma mark -
#pragma mark Recipient TextField Handlers

- (IBAction)promptToAddContacts:(id)sender
{
    UIAlertView *importPrompt = [[UIAlertView alloc] initWithTitle:nil
                                                           message:NSLocalizedString(@"YOU_DO_NOT_HAVE_CONTACTS_YET", nil)
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"IMPORT", nil), NSLocalizedString(@"ADD", nil), nil];
    
    [importPrompt show];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   [self showContactsAutocomplete];
}

- (IBAction)recipientTextFieldDidChange:(UITextField *)textField
{
    [self filterContactListForSearchText:textField.text];
    [self showContactsAutocomplete];
}

- (void)showContactsAutocomplete
{    
    [self.recipientTextField becomeFirstResponder];
    
    [self.tableView reloadData];
    
    self.tableView.hidden = NO;
    self.tableView.alpha = 1.0f;

    int row = [self.tableView numberOfRowsInSection:0];
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = row * CTLContactPickerRowHeight;
    
    self.tableView.frame = tableFrame;
    self.tableView.layer.shadowOpacity = 0.75f;
    self.tableView.layer.shadowRadius = 1.0f;
    self.tableView.layer.shadowOffset = CGSizeMake(0, 1);
    self.tableView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.tableView.bounds].CGPath;
    
    [self.view bringSubviewToFront:self.tableView];
}

#pragma mark -
#pragma mark Contact Filtering

- (void)filterContactListForSearchText:(NSString*)searchText
{
	[self.filteredContacts removeAllObjects];
	for (CTLCDContact *contact in self.contacts){
        NSComparisonResult result = [contact.compositeName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        if (result == NSOrderedSame){
            [self.filteredContacts addObject:contact];
        }
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier:CTLImporterSegueIdentifier sender:alertView];
    }else if (buttonIndex == 1) {
        [self performSegueWithIdentifier:CTLContactFormSegueIdentifier sender:alertView];
    }
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if([segue.identifier isEqualToString:CTLContactFormSegueIdentifier]){
//        CTLContactDetailsViewController *viewController = [segue destinationViewController];
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
//        
//        [self.navigationController pushViewController:navController animated:YES];
//    }
//}

- (void)chooseContact:(CTLCDContact *)contact
{
    if(contact.user_idValue == 0){
        
        [self showInviteModal:nil];
        
        //[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showInviteModal:) userInfo:nil repeats:NO];
        
    }else{
        
        if(self.messengerInviteView){
            [self.messengerInviteView removeFromSuperview];
        }
        
        if(self.message){
            [self.message.conversation setContact:contact];
        }
    }
    
    self.recipientTextField.text = contact.compositeName;
}

- (void)sendMessage:(id)sender
{
  NSString *messageText = self.messageTextView.text;
  
  if(!self.contact || [messageText length] == 0){
      return;
  }
  
  if(!self.conversation){
    self.conversation = [CTLCDConversation MR_createEntity];
  }
  
  self.conversation.contact = self.contact;  
  self.conversation.account = self.current_user;
  
  [CTLMessageManager sendMessage:messageText withConversation:self.conversation completionBlock:^(BOOL result, NSError *error){
    [self dismissViewControllerAnimated:YES completion:nil]; 
  }];  
}

- (void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissInputViews:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    self.tableView.hidden = YES;
}

- (void)showInviteModal:(id)sender
{
    [[NSBundle mainBundle] loadNibNamed:@"CTLMessengerInviteView" owner:self options:nil];
    self.messengerInviteView.alpha = 0;
    self.messengerInviteView.inviteContactViaLabel.text = [NSString stringWithFormat:@"Invite %@ to Clientelle", self.contact.firstName];
        
    CGRect modalFrame = self.messengerInviteView.frame;
    modalFrame.origin.x = (self.view.frame.size.width - modalFrame.size.width) / 2;
    modalFrame.origin.y = 60.0f;
    self.messengerInviteView.frame = modalFrame;
    
    self.messengerInviteView.inviteViaEmailButton.enabled = [self.contact.email length] > 0;
    self.messengerInviteView.inviteViaSMSButton.enabled = [self.contact.mobile length] > 0;
    
    [self.view addSubview:self.messengerInviteView];
    [self.recipientTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.messengerInviteView.alpha = 1.0f;
    } completion:^(BOOL finished){
        
    }];
}

- (IBAction)dismissInviterModal:(id)sender
{
    self.message.conversation.contact = nil;
    self.messageTextView.editable = NO;
    [self.messengerInviteView removeFromSuperview];
}

- (IBAction)inviteViaEmail:(id)sender
{
    NSLog(@"inviteViaEmail");
    return;
    
    if(self.contact.email){
        if([MFMailComposeViewController canSendMail]){
            MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
            [mailController setMailComposeDelegate:self];
            [mailController setToRecipients:@[self.contact.email]];
            [self presentViewController:mailController animated:YES completion:nil];
        }else{
            [self displayAlertMessage: NSLocalizedString(@"DEVICE_NOT_CONFIGURED_TO_SEND_EMAIL", nil)];
        }
    }
}

- (IBAction)inviteViaSms:(id)sender
{
    NSLog(@"inviteViaSMS");
    return;
    if(self.contact.mobile){
        if([MFMessageComposeViewController canSendText]){
            NSString *sms = [NSString stringWithFormat:@"sms: %@", [NSString cleanPhoneNumber:self.contact.mobile]];
            NSString *smsEncoded = [sms stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:smsEncoded]];
        }else{
            [self displayAlertMessage: NSLocalizedString(@"DEVICE_NOT_CONFIGURED_TO_SEND_SMS", nil)];
        }
    }
}

-(IBAction)copyInviteLinkToClipboard:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.messengerInviteView.invitationLinkLabel.text;
}

- (void)displayAlertMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Message Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if(result == MFMailComposeResultSent){
        //invite sent
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if(result == MessageComposeResultSent){
        //invite sent
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)drawDottedLines
{
    UIColor *fill = [UIColor ctlMediumGray];
//    CAShapeLayer *shapelayer = [CAShapeLayer layer];
//    shapelayer.strokeStart = 0.0;
//    shapelayer.strokeColor = fill.CGColor;
//    shapelayer.lineWidth = 1.0;
//    shapelayer.lineJoin = kCALineJoinRound;
//    shapelayer.lineDashPattern = @[@(1), @(3)];
    
    CGFloat Y = 60.0f;
    
    
    //int numLines = self.messageTextView.contentSize.height / self.messageTextView.font.lineHeight;
    
    
    for(int i=0;i<10;i++){
        Y += 35.5f;//row height
        
        CAShapeLayer *shapelayer = [CAShapeLayer layer];
        shapelayer.strokeStart = 0.0;
        shapelayer.strokeColor = fill.CGColor;
        shapelayer.lineWidth = 1.0;
        shapelayer.lineJoin = kCALineJoinRound;
        shapelayer.lineDashPattern = @[@(1), @(3)];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(50.0f, Y)];
        [path addLineToPoint:CGPointMake(300.0f, Y)];
        shapelayer.path = path.CGPath;
        [self.view.layer addSublayer:shapelayer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
