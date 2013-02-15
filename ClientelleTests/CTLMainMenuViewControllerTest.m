//
//  CTLMainMenuViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLMainMenuViewControllerTest.h"
#import "CTLMainMenuViewController.h"

@implementation CTLMainMenuViewControllerTest

- (void)setUp
{
    [super setUp];
    _storyboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle: nil];
    _menuItems = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:CTLMenuPlistName ofType:@"plist"]];
}

- (void)tearDown
{
    _storyboard = nil;
    _menuItems = nil;
    [super tearDown];
}

- (void)testMenuHasValidItems
{
    NSInteger menuCount = [_menuItems count];
    if(menuCount == 0){
        STFail(@"Main menu has 0 items");
    }
    
    for(NSInteger i=0;i<menuCount;i++){
        NSDictionary *menuItem = _menuItems[i];
        STAssertNotNil(menuItem[@"title"], @"title key should exist");
        STAssertNotNil(menuItem[@"identifier"], @"identifier key should exist");
        STAssertNotNil(menuItem[@"icon"], @"icon key should exist");
    }
}

- (void)testTableHasCorrectRowsAndSections
{
    CTLMainMenuViewController *mainMenuViewController = [_storyboard instantiateInitialViewController];
    STAssertEquals(1,[mainMenuViewController numberOfSectionsInTableView:nil],@"");
    STAssertEquals((NSInteger)[_menuItems count],[mainMenuViewController tableView:mainMenuViewController.tableView numberOfRowsInSection:0], @"Number of menu item rows");
}

- (void)testMenuItemsInstantiateValidViewControllers
{
    NSInteger menuCount = [_menuItems count];
    for(NSInteger i=0;i<menuCount;i++){
        NSDictionary *menuItem = _menuItems[i];
        UINavigationController *navController = [_storyboard instantiateViewControllerWithIdentifier:menuItem[@"identifier"]];
        
        if(![navController isKindOfClass:[UINavigationController class]]){
            STFail(@"UIViewController with Storyboard ID: %@ is invalid", menuItem[@"identifier"]);
        }
        
        UIViewController *vc = navController.topViewController;
        STAssertTrue([vc canPerformAction:@selector(setMenuController:) withSender:vc], @"%@ does not implement delegate", menuItem[@"identifier"]);
    }
}

@end
