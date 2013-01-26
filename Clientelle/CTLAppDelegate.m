//
//  CTLAppDelegate.m
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

typedef void (^CTLVoidBlock)(void);
typedef void (^CTLABRefBlock)(ABAddressBookRef addressBookRef);

#define kInitializerDidRun @"com.clientelle.notifications.initializerDidRun"

#import "CTLAppDelegate.h"
#import "CTLSlideMenuController.h"
#import "CTLMainMenuViewController.h"
#import "CTLABGroup.h"

@implementation CTLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //setup CoreData/MagicalRecord
    [MagicalRecord setupCoreDataStack];
    
    __block ABAddressBookRef abRef;
    [self createAddressBookReferenceWithBlock:^(ABAddressBookRef addressBookRef){
        abRef = addressBookRef;
        //create default groups only once
        if(![[NSUserDefaults standardUserDefaults] boolForKey:kInitializerDidRun]){
            [CTLABGroup createDefaultGroups:addressBookRef];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kInitializerDidRun];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        //listen for changes to addressbook made outside the app
        ABAddressBookRegisterExternalChangeCallback(addressBookRef, addressBookChanged, NULL);
        
     } errorHandler:^(void){
         //TODO: show require address book permissions view
     }];

    
    //setup global appearance
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    
    //init main menu controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle: nil];
    CTLMainMenuViewController *menuView = [storyboard instantiateInitialViewController];
    UINavigationController *contactList = [storyboard instantiateViewControllerWithIdentifier:@"contactsNavigationController"];
    CTLSlideMenuController *rootViewController = [[CTLSlideMenuController alloc] initWithMenu:menuView mainView:contactList];
    rootViewController.addressBookRef = abRef;
    rootViewController.mainStoryboard = storyboard;
    [self.window setRootViewController:rootViewController];

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
    //Check for permission again in case it was revoked while app was in background
    [self createAddressBookReferenceWithBlock:^(ABAddressBookRef addressBookRef){
        CTLSlideMenuController *rootViewController = (CTLSlideMenuController *)[self.window rootViewController];
        [rootViewController setAddressBookRef:addressBookRef];
    } errorHandler:^(void){
        //TODO: show require address book permissions view
    }];
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



- (void)createAddressBookReferenceWithBlock:(CTLABRefBlock)block errorHandler:(CTLVoidBlock)errorBlock
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CFErrorRef error;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef reqError) {
        if(granted){
            dispatch_sync(dispatch_get_main_queue(), ^{
                block(addressBookRef);
                dispatch_semaphore_signal(semaphore);
            });
        }else{
            errorBlock();
            dispatch_semaphore_signal(semaphore);
        }
    });
    while(dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}


@end
