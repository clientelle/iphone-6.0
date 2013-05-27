//
//  CTLSlideMenuController.h
//  Created by Samuel Goodwin on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat CTLMainMenuWidth;

@class CTLMainMenuViewController;

@interface CTLSlideMenuController : UIViewController;

@property (nonatomic, weak) UINavigationController *mainNavigationController;

@property (nonatomic, strong) NSString *mainViewControllerIdentifier;

@property (nonatomic, strong) UIViewController<CTLSlideMenuDelegate> *nextViewController;
@property (nonatomic, strong) UIViewController<CTLSlideMenuDelegate> *mainViewController;
@property (nonatomic, assign) ABAddressBookRef addressBookRef;


@property (nonatomic, assign) BOOL rightSwipeEnabled;


- (void)setMainView:(NSString *)identifier;
- (void)flipToView;

- (void)transitionToView:(UIViewController<CTLSlideMenuDelegate> *)viewController withAnimationStyle:(UIViewAnimationTransition)animationStyle;

- (void)renderMenuButton:(UIViewController<CTLSlideMenuDelegate> *)mainViewController;

- (IBAction)toggleMenu:(id)sender;

- (void)launchWithViewFromNotification:(UILocalNotification *)notification;
- (void)setMainViewFromNotification:(UILocalNotification *)notification applicationState:(UIApplicationState)applicationState;

- (void)requirePin;

@end
