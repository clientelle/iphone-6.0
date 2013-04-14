//
//  CTLAppDelegate.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLSlideMenuController;

@interface CTLAppDelegate : UIResponder <UIApplicationDelegate>{
    UIStoryboard *_storyboad;
    CTLSlideMenuController *_rootViewController;
}

@property (strong, nonatomic) UIWindow *window;

@end
