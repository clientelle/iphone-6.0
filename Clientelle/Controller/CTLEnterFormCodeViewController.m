//
//  CTLEnterFormCodeViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 2/15/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLCDInbox.h"
#import "CTLEnterFormCodeViewController.h"
#import "CTLInboxViewController.h"

@implementation CTLEnterFormCodeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)submitFormCode:(id)sender
{
    CTLCDInbox *newInbox = [CTLCDInbox MR_createEntity];
    newInbox.created_at = [NSDate date];
    newInbox.form_id = @"abc";
    newInbox.install_code = self.formCodeTextField.text;
    newInbox.schema = @"{fake json}";
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];
    
    
    [self.containerView setRightSwipeEnabled:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Inbox" bundle:[NSBundle mainBundle]];
    
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateInitialViewController];
        
    CTLInboxViewController<CTLContainerViewDelegate> *inboxViewController = (CTLInboxViewController<CTLContainerViewDelegate> *)navigationController.topViewController;
    [inboxViewController setInbox:newInbox];
    [self.containerView setMainViewController:inboxViewController];
    [self.containerView flipToView];
    [self.containerView renderMenuButton:self];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
