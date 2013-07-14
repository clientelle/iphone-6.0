//
//  CTLReplyComposerViewController.m
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

#import "CTLReplyComposerViewController.h"
#import "CTLCDConversation.h"

#import "CTLCDContact.h"
#import "CTLCDMessage.h"

#import "CTLAccountManager.h"
#import "CTLCDAccount.h"

@interface CTLReplyComposerViewController ()

@property (nonatomic, strong) CTLCDMessage *message;
@property (nonatomic, strong) CTLCDContact *contact;
@property (nonatomic, strong) CTLCDAccount *current_user;

@end

@implementation CTLReplyComposerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.current_user = [CTLAccountManager currentUser];
    
    self.navigationItem.title = NSLocalizedString(@"REPLY", nil);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
 
    //[self drawDottedLines];
}

#pragma mark TableView Delegate Methods

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 35.0f;
//}


#pragma mark -
#pragma mark SendMessage Handlers

- (void)sendReply:(id)sender
{
    if(!self.conversation){
        //must have a conversation at this point
        return;
    }
    
    NSString *replyString = @"EHllow!";
    
//    if(!self.contact || [self.replyTextView.text length] == 0){
//        return;
//    }    
    
    self.conversation.contact = self.contact;
    self.conversation.preview_message = replyString;
    self.conversation.last_sender_uid = self.current_user.user_id;
    self.conversation.updated_at = [NSDate date];

    CTLCDMessage *message = [CTLCDMessage createEntity];
    message.conversation = self.conversation;
    message.message_text = replyString;
        
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
