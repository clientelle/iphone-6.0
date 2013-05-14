//
//  CTLSetPinViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 5/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLSetPinViewController.h"

@implementation CTLSetPinViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"ENABLE_APP_LOCK", nil);
    
    self.titleLabel.text = NSLocalizedString(@"SET_A_PIN", nil);
    self.instructionsLabel.text = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"ENTER_FOUR_DIGIT_CODE", nil)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
