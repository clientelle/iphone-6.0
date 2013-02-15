//
//  CTLUpgradeInterstitialViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 2/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLAccountInterstitialViewController : UIViewController<CTLSlideMenuDelegate>

@property (nonatomic, weak) CTLSlideMenuController *menuController;

@property (nonatomic, weak) IBOutlet UILabel *actionMessageLabel;
@property (nonatomic, weak) IBOutlet UIButton *upgradeButton;

@end
