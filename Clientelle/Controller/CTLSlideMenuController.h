//
//  CTLSlideMenuController.h
//  Created by Samuel Goodwin on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat CTLMainMenuWidth;

@interface CTLSlideMenuController : UIViewController{
    UIStoryboard *_mainStoryboard;
    ABAddressBookRef _addressBookRef;
}

@property (nonatomic, weak) UIViewController<CTLSlideMenuDelegate> *panel;
@property (nonatomic, weak) UINavigationController *mainViewNavController;
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, strong) UIStoryboard *mainStoryboard;

@property (nonatomic, assign) BOOL hasPro;
@property (nonatomic, assign) BOOL hasAccount;
@property (nonatomic, assign) BOOL hasInbox;
@property (nonatomic, assign) BOOL rightSwipeEnabled;

- (id)initWithMenu:(UIViewController<CTLSlideMenuDelegate> *)menuView mainView:(UINavigationController *)mainView;

- (void)setMainView:(NSString *)navigationControllerName;
- (void)flipToView:(UIViewController<CTLSlideMenuDelegate> *)mainViewController;
- (void)renderMenuButton:(UIViewController<CTLSlideMenuDelegate> *)mainViewController
;

- (void)toggleMenu:(id)sender;

@end
