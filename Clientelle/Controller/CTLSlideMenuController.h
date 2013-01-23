//
//  CTLSlideMenuController.h
//  Created by Samuel Goodwin on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLSlideMenuController : UIViewController

@property (nonatomic, weak) UIViewController<CTLSlideMenuDelegate> *panel;
@property (nonatomic, weak) UINavigationController *mainViewNavController;

- (id)initWithMenu:(UIViewController<CTLSlideMenuDelegate> *)menuView mainView:(UINavigationController *)mainView;
- (void)setMainView:(UINavigationController *)navController;

@end
