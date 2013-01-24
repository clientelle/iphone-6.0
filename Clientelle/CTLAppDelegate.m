//
//  CTLAppDelegate.m
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#define kInitializerDidRun @"com.clientelle.init.didRun"

#import "CTLAppDelegate.h"
#import "CTLSlideMenuController.h"
#import "CTLMainMenuViewController.h"
#import "CTLABGroup.h"

@implementation CTLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //setup CoreData/MagicalRecord
    [MagicalRecord setupCoreDataStack];
    
    //setup global appearance
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];

    //init main menu controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle: nil];
    CTLMainMenuViewController *menuView = [storyboard instantiateInitialViewController];
    UINavigationController *contactList = [storyboard instantiateViewControllerWithIdentifier:@"contactsNavigationController"];
    CTLSlideMenuController *rootViewController = [[CTLSlideMenuController alloc] initWithMenu:menuView mainView:contactList];
    [self.window setRootViewController:rootViewController];

    CFErrorRef error; //handle addressbook permission and external changes
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef requestError){
        if(granted){
            //listen for changes to addressbook made outside the app
            ABAddressBookRegisterExternalChangeCallback(addressBookRef, addressBookChanged, NULL);
            //create default groups only once
            if(![[NSUserDefaults standardUserDefaults] boolForKey:kInitializerDidRun]){
                [CTLABGroup createDefaultGroups:addressBookRef];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kInitializerDidRun];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    });
    
    return YES;
}


void addressBookChanged(ABAddressBookRef reference, CFDictionaryRef dictionary, void *context) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddressBookDidChange object:nil];
    });
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

@end
