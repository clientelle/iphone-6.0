//
//  CTLWelcomeViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 7/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "UILabel+CTLLabel.h"
#import "CTLWelcomeViewController.h"

@implementation CTLWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];	
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    [self.navigationItem setHidesBackButton:YES animated:YES];
}

- (void)tanslateLabels
{
    self.navigationItem.title = NSLocalizedString(@"WELCOME", nil);
    self.sloganLabel.text = NSLocalizedString(@"WELCOME_SLOGAN", nil);
    self.bullet1Label.text = NSLocalizedString(@"SEPARATE_ADDRESS_BOOK", nil);
    self.bullet2Label.text = NSLocalizedString(@"MANAGE_APPOINTMENTS", nil);
    self.bullet3Label.text = NSLocalizedString(@"REALTIME_MESSAGING", nil);
    self.bullet4Label.text = NSLocalizedString(@"COLLECT_LEADS", nil);
    self.requireUpgradeLabel.text = NSLocalizedString(@"REQUIRES_UPGRADE", nil);
    self.registerButton.titleLabel.text = NSLocalizedString(@"CREATE_NEW_ACCOUNT", nil);
    self.loginButton.titleLabel.text = NSLocalizedString(@"LOGIN_TO_MY_ACCOUNT", nil);
    
    [UILabel autoWidth:self.registerButton.titleLabel];
    [UILabel autoWidth:self.loginButton.titleLabel];
}

@end
