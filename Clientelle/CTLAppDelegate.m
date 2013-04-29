//
//  CTLAppDelegate.m
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAppDelegate.h"
#import "CTLSlideMenuController.h"
#import "Appirater.h"

@implementation CTLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //setup global appearance
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    
    //hookup data source
    [MagicalRecord setupCoreDataStack];
    
    //prompt for rating
    //[Appirater setDebug:YES];
    [Appirater setAppId:kAppiraterAppId];
    [Appirater setDaysUntilPrompt:kAppiraterDaysUntilPrompt];
    [Appirater setUsesUntilPrompt:kAppiraterUsesUntilPrompt];
    [Appirater setTimeBeforeReminding:kAppiraterTimeBeforeReminding];
    [Appirater appLaunched:YES];
    
    //Register for External Changes
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        ABAddressBookRegisterExternalChangeCallback(addressBookRef, addressBookChanged, NULL);
    }

    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if(notification && [[notification userInfo][@"navigationController"] length] > 0){
        application.applicationIconBadgeNumber = notification.applicationIconBadgeNumber-1;
        CTLSlideMenuController *rootViewController = (CTLSlideMenuController *)[self.window rootViewController];
        [rootViewController launchWithViewFromNotification:notification];
    }
    
    return YES;
}
                               
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    CTLSlideMenuController *rootViewController = (CTLSlideMenuController *)[self.window rootViewController];
    [rootViewController setMainViewFromNotification:notification applicationState:application.applicationState];
    application.applicationIconBadgeNumber = notification.applicationIconBadgeNumber-1;
}

void addressBookChanged(ABAddressBookRef reference, CFDictionaryRef dictionary, void *context) {
    dispatch_async(dispatch_get_main_queue(), ^{
        id ref = (__bridge id)(reference);
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddressBookDidChange object:ref];
    });
}

@end
