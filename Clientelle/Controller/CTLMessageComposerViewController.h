//
//  CTLMessageComposerViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 6/17/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class CTLMessengerInviteView;
@class CTLCDConversation;

@interface CTLMessageComposerViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>



@property (nonatomic, strong) CTLCDConversation *conversation;



@property (nonatomic, strong) IBOutlet UITextField *recipientTextField;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *addContactButton;
@property (nonatomic, strong) IBOutlet CTLMessengerInviteView *messengerInviteView;

- (IBAction)sendMessage:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)dismissInviterModal:(id)sender;
- (IBAction)inviteViaSms:(id)sender;
- (IBAction)inviteViaEmail:(id)sender;
- (IBAction)copyInviteLinkToClipboard:(id)sender;
- (IBAction)recipientTextFieldDidChange:(id)sender;
- (IBAction)promptToAddContacts:(id)sender;

@end
