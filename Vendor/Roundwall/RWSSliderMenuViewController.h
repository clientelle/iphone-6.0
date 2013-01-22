//
//  RWSSliderMenuViewController.h
//  Created by Samuel Goodwin on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWSSlideMenuViewDelegate.h"
#import "RWSSlideMenuRevealDelegate.h"

@interface RWSSliderMenuViewController : UIViewController

@property (nonatomic, weak) UIViewController<RWSSlideMenuViewDelegate> *panel;
@property (nonatomic, weak) UINavigationController *navigationController;

- (id)initWithMenu:(UIViewController<RWSSlideMenuViewDelegate> *)menuPanel andRightPanel:(UINavigationController *)rightPanel;
- (void)setMainView:(UINavigationController *)navController;
- (void)toggleMenu:(id)sender;

@end
