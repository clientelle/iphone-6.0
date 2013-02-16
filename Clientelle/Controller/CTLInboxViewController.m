//
//  CTLInboxViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLInboxViewController.h"
#import "CTLSlideMenuController.h"

@implementation CTLInboxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    

    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    
    NSLog(@"CDInbox %@", self.inbox);
    
    
        
    [self.menuController renderMenuButton:self];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
