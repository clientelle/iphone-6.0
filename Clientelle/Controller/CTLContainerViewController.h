//
//  CTLContainerViewController.h
//  Created by Kevin Liu on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat CTLMainMenuWidth;

@class CTLCDAccount;
@class CTLMainMenuViewController;

@interface CTLContainerViewController : UIViewController;

@property (nonatomic, strong) CTLCDAccount *currentUser;
@property (nonatomic, weak) UINavigationController *mainNavigationController;

@property (nonatomic, strong) NSString *mainViewControllerIdentifier;

@property (nonatomic, strong) UIViewController<CTLContainerViewDelegate> *nextViewController;
@property (nonatomic, strong) UIViewController<CTLContainerViewDelegate> *mainViewController;
@property (nonatomic, assign) ABAddressBookRef addressBookRef;

@property (nonatomic, strong) NSString *nextNavString;
@property (nonatomic, assign) BOOL rightSwipeEnabled;


- (void)setMainView:(NSString *)identifier;
- (void)flipToView;

- (void)transitionToView:(UIViewController<CTLContainerViewDelegate> *)viewController withAnimationStyle:(UIViewAnimationTransition)animationStyle;

- (void)renderMenuButton:(UIViewController<CTLContainerViewDelegate> *)mainViewController;

- (IBAction)toggleMenu:(id)sender;

- (void)launchWithViewFromNotification:(UILocalNotification *)notification;
- (void)setMainViewFromNotification:(UILocalNotification *)notification applicationState:(UIApplicationState)applicationState;
- (void)requirePin;

@end
