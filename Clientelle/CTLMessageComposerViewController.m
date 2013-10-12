//
//  CTLMessageComposerViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 6/17/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NSString+CTLString.h"
#import "UILabel+CTLLabel.h"
#import "UIColor+CTLColor.h"
#import "CTLViewDecorator.h"

#import "CTLMessageComposerViewController.h"
#import "CTLInviteContactViewController.h"

#import "CTLCDContact.h"
#import "CTLCDConversation.h"
#import "CTLCDMessage.h"
#import "CTLAutoCompleteTableView.h"
#import "CTLAccountManager.h"
#import "CTLCDAccount.h"
#import "CTLAddressBook.h"
#import "CTLABPerson.h"
#import "CTLMessageManager.h"

int const CTLContactPickerRowHeight = 35.0f;
NSString *const CTLChooseContactToMessageNotification = @"com.clientelle.notifications.chooseContact";

@interface CTLMessageComposerViewController ()
@property (nonatomic, strong) CTLCDMessage *message;
@property (nonatomic, strong) CTLCDContact *contact;
@property (nonatomic, strong) NSSet *existingContacts;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *filteredContacts;
@property (nonatomic, assign) BOOL hasAppliedShadowToDropdown;
@property (nonatomic, strong) CTLCDAccount *currentUser;

@end

@implementation CTLMessageComposerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"COMPOSE_MESSSAGE", nil);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    
    self.currentUser = [[CTLAccountManager sharedInstance] currentUser];
    [self drawDottedLines];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactWasChosen:) name:CTLChooseContactToMessageNotification object:nil];
}

- (void)contactWasChosen:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[CTLCDContact class]]){
        self.contact = notification.object;
        self.recipientTextField.text = self.contact.compositeName;
        self.addContactButton.hidden = YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self performSegueWithIdentifier:@"toChooseContact" sender:textField];
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
    self.conversation.account = self.currentUser;
  
    [[CTLMessageManager sharedInstance] sendMessage:messageText withConversation:self.conversation completionBlock:^(CTLCDMessage *message, id responseObject){
        [self dismissViewControllerAnimated:YES completion:nil];
    } errorBlock:^(NSError *error){
        
    }];
}

- (void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissInputViews:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
 }

- (void)showInviteModal:(id)sender
{
    [self performSegueWithIdentifier:@"" sender:sender];
}

- (IBAction)dismissInviterModal:(id)sender
{
    self.message.conversation.contact = nil;
    self.messageTextView.editable = NO;
}

- (void)displayAlertMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
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
