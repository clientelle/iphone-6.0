//
//  CTLWelcomeViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 7/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLWelcomeViewController : UIViewController<CTLContainerViewDelegate>

@property (nonatomic, strong) CTLContainerViewController *containerView;

@property (nonatomic, weak) IBOutlet UILabel *sloganLabel;
@property (nonatomic, weak) IBOutlet UILabel *bullet1Label;
@property (nonatomic, weak) IBOutlet UILabel *bullet2Label;
@property (nonatomic, weak) IBOutlet UILabel *bullet3Label;
@property (nonatomic, weak) IBOutlet UILabel *bullet4Label;
@property (nonatomic, weak) IBOutlet UILabel *requireUpgradeLabel;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;

@end
