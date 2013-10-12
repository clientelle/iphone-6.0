//
//  CTLMessageComposerViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 6/17/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const CTLChooseContactToMessageNotification;

@class CTLCDConversation;

@interface CTLMessageComposerViewController : UIViewController<UITextFieldDelegate, UITextFieldDelegate>

@property (nonatomic, strong) CTLCDConversation *conversation;

@property (nonatomic, strong) IBOutlet UITextField *recipientTextField;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (nonatomic, strong) IBOutlet UIButton *addContactButton;
@property (nonatomic, strong) IBOutlet UIButton *inviteButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sendButton;

- (IBAction)sendMessage:(id)sender;
- (IBAction)dismiss:(id)sender;

@end
