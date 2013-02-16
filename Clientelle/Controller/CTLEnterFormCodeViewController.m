//
//  CTLEnterFormCodeViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 2/15/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLEnterFormCodeViewController.h"

@implementation CTLEnterFormCodeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)submitFormCode:(id)sender
{
    NSLog(@"FORM CODE %@", self.formCodeTextField.text);
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
