//
//  CTLFiveStarRater.m
//  Clientelle
//
//  Created by Samuel Goodwin on 8/16/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import "CTLFiveStarRater.h"

@implementation CTLFiveStarRater
@synthesize starValue = _starValue;

- (NSNumber *)starValue
{
    if(_starValue){
        return _starValue;
    }
    
    return @0;
}

- (IBAction)starButtonTapped:(id)sender
{
    NSUInteger index = [self.starButtons indexOfObject:sender];
    NSAssert(index != NSNotFound, @"Woah woah woah woah");
    [self setStarValue:@(index+1u)];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    [[UIApplication sharedApplication] sendAction:@selector(ratingDidChange:) to:nil from:self forEvent:nil];
}

- (void)setStarValue:(NSNumber *)starValue
{
    _starValue = starValue;
    NSUInteger index = [starValue unsignedIntegerValue]-1u;
    if([starValue unsignedIntegerValue] == 0){
        index = NSNotFound;
    }
    [self.starButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = obj;
        if(idx <= index && index != NSNotFound){
            [button setImage:[UIImage imageNamed:@"star-filled"] forState:UIControlStateNormal];
        }else{
            [button setImage:[UIImage imageNamed:@"star-empty"] forState:UIControlStateNormal];
        }
    }];
}

/*
- (void)ratingDidChange
{
    [[UIApplication sharedApplication] sendAction:@selector(callPerson:) to:nil from:self forEvent:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ratingChanged:) name:@"starChanged" object:self.starValue];
}*/

@end
