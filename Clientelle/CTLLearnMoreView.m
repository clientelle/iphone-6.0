//
//  CTLLearnMoreView.m
//  Clientelle
//
//  Created by Kevin Liu on 8/4/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CTLLearnMoreView.h"

@implementation CTLLearnMoreView

- (void)awakeFromNib
{    
    self.sloganLabel.text = NSLocalizedString(@"WELCOME_SLOGAN", nil);
    self.bullet1Label.text = NSLocalizedString(@"SEPARATE_ADDRESS_BOOK", nil);
    self.bullet2Label.text = NSLocalizedString(@"MANAGE_APPOINTMENTS", nil);
    self.bullet3Label.text = NSLocalizedString(@"REALTIME_MESSAGING", nil);
    
    [self.okButton.layer setBorderWidth:1.0f];
    [self.okButton.layer setBorderColor:[UIColor whiteColor].CGColor];    
}

- (void)drawRect:(CGRect)rect
{
    self.alpha = 0.8f;
    self.layer.shadowOpacity = 0.65f;
    self.layer.shadowRadius = 1.0f;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
}

@end
