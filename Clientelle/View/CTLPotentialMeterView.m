//
//  CTLPotentialMeterView.m
//  Clientelle
//
//  Created by Kevin Liu on 3/3/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"

#import "CTLPotentialMeterView.h"

@implementation CTLPotentialMeterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }

    return self;
}

- (void)bindSwipes
{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:swipeRight];
}

-(void)handleSwipeLeft:(UISwipeGestureRecognizer*)recognizer
{
    NSLog(@"SwipeLEFT detected");
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer*)recognizer
{
    NSLog(@"SwipeRIGHT detected");
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self bindSwipes];
    //CAGradientLayer *gradient = [self blueGradient];
    //[self.layer insertSublayer:gradient atIndex:0];
}

- (CAGradientLayer*) blueGradient {
    UIColor *colorOne = [UIColor colorWithRed:(120/255.0) green:(135/255.0) blue:(150/255.0) alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:(57/255.0)  green:(79/255.0)  blue:(96/255.0)  alpha:1.0];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    
    headerLayer.colors = colors;
    
    headerLayer.locations = locations;
    
    return headerLayer;
}


@end
