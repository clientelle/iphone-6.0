//
//  CTLMessengerInviteView.m
//  Clientelle
//
//  Created by Kevin Liu on 6/20/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CTLMessengerInviteView.h"

@implementation CTLMessengerInviteView

- (void)awakeFromNib
{
    self.layer.shadowOpacity = 0.75f;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

@end
