//
//  CTLFiveStarRater.h
//  Clientelle
//
//  Created by Samuel Goodwin on 8/16/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CTLFiveStarRaterDelegate

- (void)ratingDidChange:(UIControl *)rater;

@end

@interface CTLFiveStarRater : UIControl

@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *starButtons;
@property (nonatomic, retain) NSNumber *starValue;

- (IBAction)starButtonTapped:(id)sender;

@end
