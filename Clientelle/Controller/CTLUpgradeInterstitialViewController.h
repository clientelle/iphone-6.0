//
//  CTLUpgradeInterstitialViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 2/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLCDAccount;

@interface CTLUpgradeInterstitialViewController : UIViewController<CTLContainerViewDelegate>

@property (nonatomic, weak) CTLContainerViewController *containerView;
@property (nonatomic, weak) IBOutlet UIButton *upgradeButton;
@property (nonatomic, weak) IBOutlet UILabel *actionMessageLabel;


@end
