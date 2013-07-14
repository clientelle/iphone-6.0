//
//  CTLInboxInterstitialViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 2/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLInboxInterstitialViewController : UIViewController<CTLContainerViewDelegate>

@property (nonatomic, weak) CTLContainerViewController *containerView;

@property (nonatomic, weak) IBOutlet UIButton *continueButton;

- (IBAction)continueToEnterFormCode:(id)sender;

@end
