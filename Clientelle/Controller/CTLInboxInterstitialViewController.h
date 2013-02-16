//
//  CTLInboxInterstitialViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 2/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLInboxInterstitialViewController : UIViewController<CTLSlideMenuDelegate>

@property (nonatomic, weak) CTLSlideMenuController *menuController;

@property (nonatomic, weak) IBOutlet UIButton *continueButton;

- (IBAction)continueToEnterFormCode:(id)sender;

@end
