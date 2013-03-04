//
//  CTLEnterFormCodeViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 2/15/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLCDInbox.h"
#import "CTLEnterFormCodeViewController.h"
#import "CTLSlideMenuController.h"
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
    newInbox.dateCreated = [NSDate date];
    newInbox.form_id = @"abc";
    newInbox.install_code = self.formCodeTextField.text;
    newInbox.schema = @"{fake json}";
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];
    
    [self.menuController setHasPro:YES];
    [self.menuController setHasAccount:YES];
    [self.menuController setRightSwipeEnabled:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle:[NSBundle mainBundle]];
    
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"inboxNavigationController"];
        
    CTLInboxViewController<CTLSlideMenuDelegate> *inboxViewController = (CTLInboxViewController<CTLSlideMenuDelegate> *)navigationController.topViewController;
    [inboxViewController setInbox:newInbox];
        
    [self.menuController flipToView:inboxViewController];
    [self.menuController renderMenuButton:self];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
