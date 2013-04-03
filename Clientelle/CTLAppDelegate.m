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
#import "NSDate+CTLDate.h"
#import "CTLCDAppointment.h"

@implementation CTLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //setup global appearance
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    
    //initiate split view for main menu
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle: nil];
    CTLMainMenuViewController *menuView = [storyboard instantiateInitialViewController];
    UINavigationController *contactList = [storyboard instantiateViewControllerWithIdentifier:@"contactsNavigationController"];
    CTLSlideMenuController *rootViewController = [[CTLSlideMenuController alloc] initWithMenu:menuView mainView:contactList];
    rootViewController.mainStoryboard = storyboard;
    [self.window setRootViewController:rootViewController];
    
    //hookup data source
    [MagicalRecord setupCoreDataStack];
    
    //prompt for rating
    [Appirater setAppId:kAppiraterAppId];
    [Appirater setDaysUntilPrompt:kAppiraterDaysUntilPrompt];
    [Appirater setUsesUntilPrompt:kAppiraterUsesUntilPrompt];
    [Appirater setTimeBeforeReminding:kAppiraterTimeBeforeReminding];
    [Appirater appLaunched:YES];
    return YES;
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
    //Remove appointments from CoreData that are more than 2 months old
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startDate < %@", [NSDate monthsAgo:2]];
    [CTLCDAppointment MR_deleteAllMatchingPredicate:predicate];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

@end
