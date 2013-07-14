//
//  CTLInboxInterstitialViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 2/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLInboxInterstitialViewController.h"
#import "CTLEnterFormCodeViewController.h"
#import "CTLContainerViewController.h"

@implementation CTLInboxInterstitialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.containerView setRightSwipeEnabled:YES];
    [self.containerView renderMenuButton:self];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
}

- (IBAction)continueToEnterFormCode:(id)sender
{
    [self performSegueWithIdentifier:@"enterFormCode" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"enterFormCode"]){
        CTLEnterFormCodeViewController *viewController = [segue destinationViewController];
        
        [viewController setContainerView:self.containerView];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
