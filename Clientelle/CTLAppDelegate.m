//
//  CTLAppDelegate.m
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAppDelegate.h"
#import "CTLSlideMenuController.h"
#import "CTLPinInterstialViewController.h"
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

    //When app is launched from a local notification
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if(notification && [[notification userInfo][@"navigationController"] length] > 0){
        application.applicationIconBadgeNumber = notification.applicationIconBadgeNumber-1;
        CTLSlideMenuController *rootViewController = (CTLSlideMenuController *)[self.window rootViewController];
        [rootViewController launchWithViewFromNotification:notification];
        return YES;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"PIN NUMBER %@", [defaults valueForKey:@"PIN_NUMBER"]),
    NSLog(@"PIN ENABLED %i", [defaults boolForKey:@"PIN_ENABLED"]);
    
    if([self shouldPromptForPin]){
        [self performSelector:@selector(showPinView:) withObject:nil afterDelay:0.1];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // Recieved local notification while using app
    CTLSlideMenuController *rootViewController = (CTLSlideMenuController *)[self.window rootViewController];
    [rootViewController setMainViewFromNotification:notification applicationState:application.applicationState];
    application.applicationIconBadgeNumber = notification.applicationIconBadgeNumber-1;
}
                               
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *idleDate = [defaults valueForKey:@"WENT_INACTIVE_TIME"];
    NSTimeInterval timeLapse = [[NSDate date] timeIntervalSinceDate:idleDate];

    if(timeLapse > 300){ //5 minutes have passed
        [self performSelector:@selector(showPinView:) withObject:nil afterDelay:0.1];
    }
    
    [Appirater appEnteredForeground:YES];
}

- (void)showPinView:(id)sender
{
    CTLSlideMenuController *rootViewController = (CTLSlideMenuController *)[self.window rootViewController];
    CTLPinInterstialViewController *viewController = (CTLPinInterstialViewController *)[rootViewController.storyboard instantiateViewControllerWithIdentifier:@"pinInterstitial"];
    [rootViewController.mainNavigationController presentViewController:viewController animated:NO completion:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
    [self saveDefaultPinState];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    [self saveDefaultPinState];
}

- (BOOL)shouldPromptForPin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (([[defaults valueForKey:@"PIN_NUMBER"] length] == 4) && [defaults boolForKey:@"PIN_ENABLED"]);
}

- (void)saveDefaultPinState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"IS_LOCKED"];
    [defaults setValue:[NSDate date] forKey:@"WENT_INACTIVE_TIME"];
    [defaults synchronize];
}

@end
