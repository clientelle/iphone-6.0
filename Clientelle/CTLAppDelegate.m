//
//  CTLAppDelegate.m
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAppDelegate.h"
#import "CTLSlideMenuController.h"
#import "CTLMainMenuViewController.h"
#import "Appirater.h"

#import "CTLRemindersListViewController.h"
#import "CTLReminderFormViewController.h"
#import "CTLCDReminder.h"

@implementation CTLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //setup global appearance
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    
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
    
    /*
    EKAuthorizationStatus EKAuthStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if(EKAuthStatus == EKAuthorizationStatusAuthorized){
        EKEventStoreChangedNotification
    }
    */
    
    _storyboad = [UIStoryboard storyboardWithName:@"Clientelle" bundle: nil];
    
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if(notification && [[notification userInfo][@"navigationController"] length] > 0){
        application.applicationIconBadgeNumber = notification.applicationIconBadgeNumber-1;
        _rootViewController = [self setViewFromNotification:notification];
    }else{
        _rootViewController = [[CTLSlideMenuController alloc] initWithIdentifier:@"contactsNavigationController"];
    }
    
    [self.window setRootViewController:_rootViewController];

    return YES;
}
                               
- (CTLSlideMenuController *)setViewFromNotification:(UILocalNotification *)notification
{
    CTLSlideMenuController *rootViewController = nil;
    
    NSDictionary *userInfo = [notification userInfo];

    if([userInfo[@"viewController"] isEqualToString:@"reminderFormViewController"]){
        
        CTLReminderFormViewController *reminderFormViewController = [self configureReminderViewController:userInfo];
        [reminderFormViewController setPresentedAsModal:NO];
        
        rootViewController = [[CTLSlideMenuController alloc] initWithIdentifier:userInfo[@"navigationController"] viewController:reminderFormViewController];
    }
    
    if(rootViewController == nil){
        rootViewController = [[CTLSlideMenuController alloc] initWithIdentifier:@"contactsNavigationController"];
    }
    
    return rootViewController;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}

void addressBookChanged(ABAddressBookRef reference, CFDictionaryRef dictionary, void *context) {
    dispatch_async(dispatch_get_main_queue(), ^{
        id ref = (__bridge id)(reference);
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddressBookDidChange object:ref];
    });
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
    BOOL canTransition = NO;
    
    if([[notification userInfo][@"viewController"] isEqualToString:@"reminderFormViewController"]){
        CTLReminderFormViewController *viewController = [self configureReminderViewController:[notification userInfo]];
        [viewController setPresentedAsModal:[self currentViewIsModal]];
        [self handleTransition:viewController applicationState:application.applicationState];
        canTransition = YES;
    }
    
    if(canTransition && application.applicationState == UIApplicationStateActive){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:notification.alertBody delegate:_rootViewController cancelButtonTitle:NSLocalizedString(@"CLOSE", nil) otherButtonTitles:NSLocalizedString(@"VIEW", nil), nil];
        [alert show];
    }

    application.applicationIconBadgeNumber = notification.applicationIconBadgeNumber-1;
}

- (void)handleTransition:(UIViewController<CTLSlideMenuDelegate> *)viewController applicationState:(UIApplicationState)state
{
    if(state == UIApplicationStateInactive){
        [_rootViewController transitionToView:viewController withAnimationStyle:UIViewAnimationTransitionFlipFromLeft];
    }else if(state == UIApplicationStateActive){
        [_rootViewController setNextViewController:viewController];
    }
}

#pragma mark - Configure transitionable view controller (from local notification)

- (CTLReminderFormViewController *)configureReminderViewController:(NSDictionary *)userInfo
{
    CTLReminderFormViewController *reminderFormViewController = (CTLReminderFormViewController *)[_storyboad instantiateViewControllerWithIdentifier:userInfo[@"viewController"]];
    
    CTLCDReminder *reminder = [CTLCDReminder MR_findFirstByAttribute:@"eventID" withValue:userInfo[@"reminderEventID"]];
    
    [reminderFormViewController setCdReminder:reminder];
    [reminderFormViewController setTransitionedFromLocalNotification:YES];
    [reminderFormViewController setPresentedAsModal:NO];

    return reminderFormViewController;
}

- (BOOL)currentViewIsModal
{
    UIViewController *presentedViewController = _rootViewController.mainViewController.presentedViewController;
    
    BOOL presentedViewHasNavigationController = [presentedViewController isKindOfClass:[UINavigationController class]];
    
    return presentedViewHasNavigationController == NO && presentedViewController != nil;
}

@end
