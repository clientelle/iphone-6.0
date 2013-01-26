//
//  CTLSlideMenuController.h
//  Created by Samuel Goodwin on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLSlideMenuController : UIViewController{
    UIStoryboard *_mainStoryboard;
    ABAddressBookRef _addressBookRef;
}

@property (nonatomic, weak) UIViewController<CTLSlideMenuDelegate> *panel;
@property (nonatomic, weak) UINavigationController *mainViewNavController;
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, strong) UIStoryboard *mainStoryboard;

- (id)initWithMenu:(UIViewController<CTLSlideMenuDelegate> *)menuView mainView:(UINavigationController *)mainView;
- (void)setMainView:(NSString *)navigationControllerName;

@end
