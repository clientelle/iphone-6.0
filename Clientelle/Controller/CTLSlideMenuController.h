//
//  CTLSlideMenuController.h
//  Created by Samuel Goodwin on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat CTLMainMenuWidth;

@class CTLMainMenuViewController;

@interface CTLSlideMenuController : UIViewController{
    UIStoryboard *_mainStoryboard;
    ABAddressBookRef _addressBookRef;
}

@property (nonatomic, weak) CTLMainMenuViewController<CTLSlideMenuDelegate> *panel;
@property (nonatomic, weak) UINavigationController *mainNavigationController;
@property (nonatomic, strong) UIViewController<CTLSlideMenuDelegate> *nextViewController;
@property (nonatomic, strong) UIViewController<CTLSlideMenuDelegate> *mainViewController;
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, strong) UIStoryboard *mainStoryboard;

@property (nonatomic, assign) BOOL hasPro;
@property (nonatomic, assign) BOOL hasAccount;
@property (nonatomic, assign) BOOL hasInbox;
@property (nonatomic, assign) BOOL rightSwipeEnabled;


- (id)initWithIdentifier:(NSString *)identifier;

- (id)initWithIdentifier:(NSString *)identifier viewController:(UIViewController<CTLSlideMenuDelegate> *)viewController;

- (void)setMainView:(NSString *)identifier;
- (void)flipToView;


- (void)transitionToView:(UIViewController<CTLSlideMenuDelegate> *)viewController withAnimationStyle:(UIViewAnimationTransition)animationStyle;

- (void)renderMenuButton:(UIViewController<CTLSlideMenuDelegate> *)mainViewController;

- (void)toggleMenu:(id)sender;

@end
